import XCTest
@testable import Passage

final class PassageMagicLinkTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        passage = Passage(appId: TestConfig.magicLinkAppId)
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        try await passage.currentUser.logOut()
    }
    
    func testMagicLinkRegisterValid() async {
        do {
            let identifier = TestConfig.getUniqueUserIdentifier()
            _ = try await passage.magicLink.register(identifier: identifier)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testMagicLinkRegisterInvalid() async {
        do {
            _ = try await passage.magicLink.register(identifier: "INVALID_IDENTIFIER")
            XCTFail("should throw invalidRequest error")
        } catch let error as MagicLinkError {
            switch error {
            case .invalidRequest:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("should throw invalidRequest error")
            }
        } catch {
            XCTFail("should throw invalidRequest error")
        }
    }
    
    func testMagicLinkLoginValid() async {
        do {
            let identifier = TestConfig.magicLinkRegisteredUserEmail
            _ = try await passage.magicLink.login(identifier: identifier)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testMagicLinkLoginInvalid() async {
        do {
            _ = try await passage.magicLink.login(identifier: "INVALID_IDENTIFIER")
            XCTFail("should throw invalidRequest error")
        } catch let error as MagicLinkError {
            switch error {
            case .invalidRequest:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("should throw invalidRequest error")
            }
        } catch {
            XCTFail("should throw invalidRequest error")
        }
    }
    
    func testGetMagicLinkStatus() async {
        do {
            _ = try await passage.magicLink.status(id: TestConfig.magicLinkUnactivatedId)
            XCTFail("should throw magicLinkNotFound error")
        } catch let error as MagicLinkError {
            switch error {
            case .magicLinkNotFound:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("should throw magicLinkNotFound error")
            }
        } catch {
            XCTFail("should throw magicLinkNotFound error")
        }
    }

    func testActivateMagicLinkValid() async {
        do {
            let mailosaurApiClient = MailosaurAPIClient()
            let identifier = mailosaurApiClient.getUniqueMailosaurEmailAddress()
            let response = try await passage.magicLink.register(identifier: identifier)
            var magicLink: String? = nil
            for _ in 1...TestConfig.checkEmailTryCount {
                try? await Task.sleep(nanoseconds: TestConfig.checkEmailWaitTime)
                magicLink = await mailosaurApiClient.getMostRecentMagicLink()
                if magicLink != nil {
                    break
                }
            }
            XCTAssertNotNil(magicLink)
            guard let magicLink else { return }
            // Should be able to exchange magic link for auth result
            _ = try await passage.magicLink.activate(magicLink: magicLink)
            // After activation, getMagicLinkStatus should return auth result, too.
            _ = try await passage.magicLink.status(id: response.id)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testActivateMagicLinkInvalid() async {
        do {
            let _ = try await passage.magicLink.activate(magicLink: "INVALID_MAGIC_LINK")
            XCTFail("should throw magicLinkNotFound error")
        } catch let error as MagicLinkError {
            switch error {
            case .magicLinkNotFound:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("should throw magicLinkNotFound error")
            }
        } catch {
            XCTFail("should throw magicLinkNotFound error")
        }
    }
    
}
