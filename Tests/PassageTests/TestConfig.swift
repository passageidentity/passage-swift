import Foundation

struct TestConfig {
    static let apiUrl = "https://auth-uat.passage.dev/v1"
    static let validUATAppId = "jlSg3Vr4MyKi1dcl3otVz9xa"
    static let unregisteredUserEmail = "unregistered-test-user@passage.id"
    static let registeredUserEmail = "ricky.padilla+user01@passage.id"
    static func getUniqueUserIdentifier() -> String {
        let date = Date().timeIntervalSince1970
        return "authentigator+\(date)@passage.id"
    }
}
