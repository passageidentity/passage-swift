import XCTest
@testable import Passage

final class PassageAppTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        passage = Passage(appId: TestConfig.validUATAppId)
    }
    
    func testAppInfoFound() async {
        do {
            let appInfo = try await passage.app.info()
            XCTAssertTrue(appInfo.id == TestConfig.validUATAppId)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    func testAppInfoNotFound() async {
        do {
            let invalidPassage = Passage(appId: "INVALID_APP_ID")
            _ = try await invalidPassage.app.info()
            XCTFail("passage.app.info should have thrown an appNotFound error.")
        } catch let error as PassageAppError {
            switch error {
            case .appNotFound:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("passage.app.info should have thrown an appNotFound error.")
            }
        } catch {
            XCTFail("passage.app.info should have thrown an appNotFound error.")
        }
    }
    
    func testUserDoesExist() async {
        do {
            let user = try await passage.app.userExists(identifier: TestConfig.registeredUserEmail)
            XCTAssertNotNil(user)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testUserDoesNotExist() async {
        do {
            let user = try await passage.app.userExists(identifier: TestConfig.unregisteredUserEmail)
            XCTAssertNil(user)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testCreateUserSuccess() async {
        do {
            let identifier = TestConfig.getUniqueUserIdentifier()
            _ = try await passage.app.createUser(identifier: identifier)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testCreatUserFailure() async {
        do {
            _ = try await passage.app.createUser(identifier: "INVALID_USER_IDENTIFIER")
            XCTFail("passage.app.info should have thrown an invalidRequest error.")
        } catch let error as PassageAppError {
            switch error {
            case .invalidRequest:
                // Test passes because the error case is correct
                break
            default:
                XCTFail("passage.app.info should have thrown an invalidRequest error.")
            }
        } catch {
            XCTFail("passage.app.info should have thrown an invalidRequest error.")
        }
    }

}
