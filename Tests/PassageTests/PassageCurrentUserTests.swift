import XCTest
@testable import Passage

final class PassageCurrentUserTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        passage = Passage(appId: TestConfig.validUATAppId)
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        // NOTE: Ideally we'd be able to set passage.tokenStore.authToken here, but
        // keychain access is limited in a test environment.
        passage.currentUser.setAuthTokenHeader(authToken: TestConfig().testAuthToken)
    }
    
    func testUserInfo() async {
        do {
            let userInfo = try await passage.currentUser.userInfo()
            XCTAssertEqual(userInfo.id, TestConfig.registeredUserId)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testChangeEmail() async {
        do {
            _ = try await passage.currentUser.changeEmail(newEmail: "ricky.padilla+user02@passage.id")
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testChangePhone() async {
        do {
            _ = try await passage.currentUser.changePhone(newPhone: "+15125874725")
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testListPasskeys() async {
        do {
            let passkeys = try await passage.currentUser.passkeys()
            XCTAssertTrue(!passkeys.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testEditPasskey() async {
        do {
            let passkeys = try await passage.currentUser.passkeys()
            guard !passkeys.isEmpty else {
                XCTFail("Expected more than 0 user passkeys.")
                return
            }
            let passkey = passkeys[0]
            let newFriendlyName = "\(Date().timeIntervalSince1970)"
            let updatedPasskey = try await passage.currentUser.editPasskey(
                passkeyId: passkey.id,
                newFriendlyName: newFriendlyName
            )
            XCTAssertEqual(updatedPasskey.friendlyName, newFriendlyName)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSocialConnections() async {
        do {
            let socialConnections = try await passage.currentUser.socialConnections()
            XCTAssertNil(socialConnections.apple)
            XCTAssertNil(socialConnections.github)
            XCTAssertNil(socialConnections.google)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testLogOut() async {
        do {
            XCTAssertNotNil(OpenAPIClientAPI.customHeaders["Authorization"])
            try await passage.currentUser.logOut()
            XCTAssertNil(OpenAPIClientAPI.customHeaders["Authorization"])
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
}
