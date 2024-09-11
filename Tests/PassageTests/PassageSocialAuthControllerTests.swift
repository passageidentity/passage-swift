import XCTest
@testable import Passage

final class PassageSocialAuthControllerTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        passage = Passage(appId: TestConfig.validUATAppId)
    }
    
    func testGetSocialAuthQueryParams() async {
        let socialAuthController = PassageSocialAuthController()
        let appId = TestConfig.validUATAppId
        
        // Verifier should be an empty string before calling getSocialAuthQueryParams
        XCTAssert(socialAuthController.verifier.isEmpty)
        
        // Get query parameters for GitHub Social Auth
        let connection = PassageSocialConnection.github
        let queryParams = socialAuthController.getSocialAuthQueryParams(
            appId: appId,
            connection: connection
        )
        
        // Verifier should NOT be an empty string after calling getSocialAuthQueryParams
        XCTAssert(!socialAuthController.verifier.isEmpty)
        
        // Query params should contain the following strings:
        XCTAssert(queryParams.contains("redirect_uri=passage-\(appId)://"))
        XCTAssert(queryParams.contains("state="))
        XCTAssert(queryParams.contains("code_challenge="))
        XCTAssert(queryParams.contains("code_challenge_method=S256"))
        XCTAssert(queryParams.contains("connection_type=\(connection.rawValue)"))
    }
    
    func testGetAuthUrl() async {
        let socialAuthController = PassageSocialAuthController()
        let connection = PassageSocialConnection.github
        let appId = TestConfig.validUATAppId
        let queryParams = socialAuthController.getSocialAuthQueryParams(
            appId: appId,
            connection: connection
        )
        let expectedAuthUrl = URL(string: "\(TestConfig.apiUrl)/apps/\(appId)/social/authorize?\(queryParams)")
        let authUrl = passage.social.getSocialAuthUrl(queryParams: queryParams)
        XCTAssertNotNil(authUrl)
        XCTAssertEqual(expectedAuthUrl, authUrl)
    }
    
    func testAppleAuthorizationFailure() async {
        do {
            // SIWA has not been configured for this iOS app, so iOS will throw an authorization error.
            let _ = try await passage.social.authorize(connection: .apple)
            XCTFail("should throw authorizationFailed error")
        } catch let error as SocialError {
            switch error {
            case .authorizationFailed:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("should throw authorizationFailed error")
            }
        } catch {
            XCTFail("should throw authorizationFailed error")
        }
    }
    
}
