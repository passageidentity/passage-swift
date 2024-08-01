import Foundation

public typealias PassageAppInfo = App
public typealias PublicUserInfo = User

public class PassageApp {
    
    let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    public func info() async throws -> PassageAppInfo {
        do {
           let appInfoResponse = try await AppsAPI.getApp(appId: appId)
           return appInfoResponse.app
       } catch {
           throw AppInfoError.convert(error: error)
       }
    }
    
    public func userExists(identifier: String) async throws -> PublicUserInfo? {
        do {
            let safeId = identifier
                .addingPercentEncoding(
                    withAllowedCharacters: .alphanumerics) ?? ""
            let response = try await UsersAPI
                .checkUserIdentifier(
                    appId: appId,
                    identifier: safeId
                )
            return response.user
        } catch {
            throw AppInfoError.convert(error: error)
        }
    }
    
}
