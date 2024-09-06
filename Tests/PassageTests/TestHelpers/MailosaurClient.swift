import Foundation
import os

private struct MailosaurConfig {
    static let serverId = "ncor7c1m" // note: this is public information
    static let apiURL = "https://mailosaur.com/api/messages"
    var apiKey = ProcessInfo.processInfo.environment["MAILOSAUR_API_KEY"]!
}

private enum URLError: Error {
    case malformed(String)
}

private struct ListMessagesResponse: Codable {
    public var items: [ListMessage]
}

private struct ListMessage: Codable {
    public var id: String
    public var received: String
    public var type: String
    public var subject: String
    public var from: [NameEmail]
    public var to: [NameEmail]
    public var cc: [String]
    public var bcc: [String]
}

private struct NameEmail: Codable {
    public var name: String
    public var email: String
}

private struct GetMessageResponse: Codable {
    public var id: String
    public var received: String
    public var type: String
    public var subject: String
    public var from: [NameEmail]
    public var to: [NameEmail]
    public var cc: [String]
    public var bcc: [String]
    public var html: MessageHTML
}

private struct MessageHTML: Codable {
    public var body: String
    public var links: [MessageLink]
    public var codes: [MessageCode]
}

private struct MessageLink: Codable {
    public var href: String
    public var text: String
}

private struct MessageCode: Codable {
    public var value: String
}

internal struct MailosaurAPIClient {
    
    internal func getUniqueMailosaurEmailAddress() -> String {
        let date = Date().timeIntervalSince1970
        let identifier = "authentigator+\(date)@\(MailosaurConfig.serverId).mailosaur.net"
        return identifier
    }
    
    internal func getMostRecentMagicLink() async -> String? {
        guard let messages = try? await listMessages(),
              !messages.isEmpty,
              let message = try? await getMessage(id: messages[0].id),
              !message.html.links.isEmpty,
              let incomingURL = URL(string: message.html.links[0].href),
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let magicLink = components.queryItems?.filter({$0.name == "psg_magic_link"}).first?.value
        else { return nil }
        return magicLink
    }
    
    internal func getMostRecentOneTimePasscode() async -> String? {
        guard let messages = try? await listMessages(),
              !messages.isEmpty,
              let message = try? await getMessage(id: messages[0].id),
              !message.html.codes.isEmpty
        else { return nil }
        let oneTimePasscode = message.html.codes[0].value
        return oneTimePasscode
    }
    
    private func appUrl(_ path: String) throws -> URL {
        guard let url = URL(string: MailosaurConfig.apiURL + path) else {
            throw URLError.malformed("Bad url path")
        }
        return url
    }
    
    private var authHeader: String {
        let apiKey = "api:\(MailosaurConfig().apiKey)".data(using: .utf8)?.base64EncodedString() ?? ""
        return "Basic: \(apiKey)"
    }
    
    private func getMessage(id: String) async throws -> GetMessageResponse {
        let url = try appUrl("/" + id)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)

        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "GET"
        
        let (responseData, _ ) = try await URLSession.shared.data(for: request)
        let message = try JSONDecoder().decode(GetMessageResponse.self, from: responseData)
        return message
    }
    
    private func listMessages() async throws -> [ListMessage] {
        do {
            let url = try appUrl("?server=" + MailosaurConfig.serverId)
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)

            request.addValue(authHeader, forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "GET"
            
            let (responseData, _ ) = try await URLSession.shared.data(for: request)
            let messages = try JSONDecoder().decode(ListMessagesResponse.self, from: responseData)
            return messages.items
        } catch {
            print(error)
            return []
        }
    }
}
