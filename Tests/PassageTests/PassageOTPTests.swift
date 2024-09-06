import XCTest
@testable import Passage

final class PassageOTPTests: XCTestCase {
    
    var passage: Passage!
    
    override func setUp() {
        super.setUp()
        OpenAPIClientAPI.basePath = TestConfig.apiUrl
        passage = Passage(appId: TestConfig.otpAppId)
    }
    
    func testSendRegisterOneTimePasscodeValid() async {
        do {
            let identifier = TestConfig.getUniqueUserIdentifier()
            _ = try await passage.oneTimePasscode.register(identifier: identifier)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSendRegisterOneTimePasscodeInvalid() async {
        do {
            _ = try await passage.oneTimePasscode.register(identifier: "INVALID_IDENTIFIER")
            XCTFail("should throw invalidRequest error")
        } catch let error as OneTimePasscodeError {
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
    
    func testSendLoginOneTimePasscodeValid() async {
        do {
            _ = try await passage.oneTimePasscode.login(identifier: TestConfig.otpRegisteredEmail)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func testSendLoginOneTimePasscodeInvalid() async {
        do {
            _ = try await passage.oneTimePasscode.login(identifier: "INVALID_IDENTIFIER")
            XCTFail("should throw invalidRequest error")
        } catch let error as OneTimePasscodeError {
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

    func testActivateOneTimePasscode() async {
        do {
            let mailosaurApiClient = MailosaurAPIClient()
            let identifier = mailosaurApiClient.getUniqueMailosaurEmailAddress()
            let otp = try await passage.oneTimePasscode.register(identifier: identifier)
            var oneTimePasscode: String? = nil
            for _ in 1...TestConfig.checkEmailTryCount {
                try? await Task.sleep(nanoseconds: TestConfig.checkEmailWaitTime)
                oneTimePasscode = await mailosaurApiClient.getMostRecentOneTimePasscode()
                if oneTimePasscode != nil {
                    break
                }
            }
            XCTAssertNotNil(oneTimePasscode)
            guard let oneTimePasscode else { return }
            _ = try await passage.oneTimePasscode.activate(otp: oneTimePasscode, id: otp.otpId)
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }

    
}
