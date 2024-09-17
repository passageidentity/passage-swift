#if os(macOS)
import Foundation
#elseif os(watchOS)
import WatchKit
#else
import UIKit
#endif

internal struct PassageClientService {
    
    private static let packageVersionNumber = "1.0.0"
    
    internal static func setup() {
        // Check if should override client api base path
        if let clientApiBasePath = getClientApiBasePath() {
            OpenAPIClientAPI.basePath = clientApiBasePath
        }
        // Set custom headers
        OpenAPIClientAPI.customHeaders["Passage-Version"] = "swift \(packageVersionNumber)"
        OpenAPIClientAPI.customHeaders["User-Agent"] = getUserAgentInfo()
    }
    
    private static func getClientApiBasePath() -> String? {
         guard
             let plistPath = Bundle.main.path(forResource: "Passage", ofType: "plist"),
             let plistData = FileManager.default.contents(atPath: plistPath),
             let plistContent = try? PropertyListSerialization
                 .propertyList(from: plistData, format: nil) as? [String: Any]
         else {
             return nil
         }
         return plistContent["clientApiBasePath"] as? String
     }
    
    private static func getUserAgentInfo() -> String {
        let name = "Passage Swift"
        let prefix = "\(name)/\(packageVersionNumber)"
        #if os(iOS)
        // iOS, iPadOS, and visionOS (visionOS uses UIKit, so treated under iOS)
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let model = device.model
        return "\(prefix) (iOS; Version \(systemVersion); Device \(model))"
        #elseif os(macOS)
        let processInfo = ProcessInfo.processInfo
        let osVersion = processInfo.operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        return "\(prefix) (macOS; Version \(osVersionString); Device Mac)"
        #elseif os(tvOS)
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        return "\(prefix) (tvOS; Version \(systemVersion); Device AppleTV)"
        #elseif os(watchOS)
        let device = WKInterfaceDevice.current()
        let systemVersion = device.systemVersion
        let model = device.model
        return "\(prefix) (watchOS; Version \(systemVersion); Device \(model))"
        #else
        // Fallback in case an unknown platform is encountered
        return "\(prefix) (Unknown Platform)"
        #endif
    }
    
}
