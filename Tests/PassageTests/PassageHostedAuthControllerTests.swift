import XCTest
@testable import Passage

final class PassageHostedAuthControllerTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        passage = Passage(appId: TestConfig.validUATAppId)
    }
    
    func testGetHostedStartUrl() async {
        do {
            let appId = TestConfig.validUATAppId
            let authOrigin = TestConfig.uatAuthOrigin
            let hostedAuthController = try HostedAuthorizationController(
                appId: appId,
                authOrigin: authOrigin
            )
            // Verifier should be an empty string before calling getHostedStartUrl
            XCTAssert(hostedAuthController.verifier.isEmpty)
            let hostedStartUrl = try hostedAuthController.getHostedStartUrl().absoluteString
            // Verifier should NOT be an empty string after calling getHostedStartUrl
            XCTAssert(!hostedAuthController.verifier.isEmpty)
            // URL should contain the following:
            XCTAssert(hostedStartUrl.contains("/authorize"))
            XCTAssert(
                hostedStartUrl.contains(
                    "redirect_uri=\(authOrigin)/ios/com.apple.dt.xctest.tool/callback"
                )
            )
            XCTAssert(hostedStartUrl.contains("state=")) // value is dynamic
            XCTAssert(hostedStartUrl.contains("code_challenge=")) // value is dynamic
            XCTAssert(hostedStartUrl.contains("code_challenge_method=S256"))
            XCTAssert(hostedStartUrl.contains("client_id=\(appId)"))
            XCTAssert(hostedStartUrl.contains("scope=openid"))
            XCTAssert(hostedStartUrl.contains("response_type=code"))
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testGetHostedFinishUrl() async {
        do {
            let appId = TestConfig.validUATAppId
            let authOrigin = TestConfig.uatAuthOrigin
            let hostedAuthController = try HostedAuthorizationController(
                appId: appId,
                authOrigin: authOrigin
            )
            let testAuthCode = "TEST_AUTH_CODE"
            let hostedFinishUrl = try hostedAuthController
                .getHostedFinishUrl(authCode: testAuthCode)
                .absoluteString
            // URL should contain the following:
            XCTAssert(hostedFinishUrl.contains("/token"))
            XCTAssert(
                hostedFinishUrl.contains(
                    "redirect_uri=\(authOrigin)/ios/com.apple.dt.xctest.tool/callback"
                )
            )
            XCTAssert(hostedFinishUrl.contains("grant_type=authorization_code"))
            XCTAssert(hostedFinishUrl.contains("code=\(testAuthCode)"))
            XCTAssert(hostedFinishUrl.contains("code_verifier="))
            XCTAssert(hostedFinishUrl.contains("client_id=\(appId)"))
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testGetLogoutUrl() async {
        do {
            let appId = TestConfig.validUATAppId
            let authOrigin = TestConfig.uatAuthOrigin
            let hostedAuthController = try HostedAuthorizationController(
                appId: appId,
                authOrigin: authOrigin
            )
            let testIdToken = "TEST_ID_TOKEN"
            let hostedFinishUrl = try hostedAuthController
                .getLogoutUrl(idToken: testIdToken)
                .absoluteString
            print(hostedFinishUrl)
            // URL should contain the following:
            XCTAssert(hostedFinishUrl.contains("/logout"))
            XCTAssert(
                hostedFinishUrl.contains(
                    "post_logout_redirect_uri=\(authOrigin)/ios/com.apple.dt.xctest.tool/logout"
                )
            )
            XCTAssert(hostedFinishUrl.contains("state=")) // value is dynamic
            XCTAssert(hostedFinishUrl.contains("id_token_hint=\(testIdToken)"))
            XCTAssert(hostedFinishUrl.contains("client_id=\(appId)"))
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
