import Foundation

struct TestConfig {
    static let apiUrl = "https://auth-uat.passage.dev/v1"
    static let validUATAppId = "jlSg3Vr4MyKi1dcl3otVz9xa"
    static let unregisteredUserEmail = "unregistered-test-user@passage.id"
    static let registeredUserEmail = "ricky.padilla+user01@passage.id"
    
    static let magicLinkAppId = "czLTOVFIytGqrhRVoHV9o8Wo"
    static let magicLinkRegisteredUserEmail = "blayne.bayer@passage.id"
    static let magicLinkUnactivatedId = "ioM1TTG0eiWMrOq9FA7X5zMN"
    
    static let otpAppId = "pTBeTnbvm1z3U6hznMTD33Es"
    static let otpRegisteredEmail = "authentigator+1681334202.318723@passage.id"
    
    static let checkEmailTryCount = 8
    static let checkEmailWaitTime = UInt64(4 * Double(NSEC_PER_SEC))// nanoseconds
    
    static func getUniqueUserIdentifier() -> String {
        let date = Date().timeIntervalSince1970
        return "authentigator+\(date)@passage.id"
    }
}
