import Foundation

/// A class allowing interaction with the Passage One-Time Passcode API.
public class PassageOneTimePasscode {
    
    private let appId: String
    private let tokenStore: PassageTokenStore
    
    init(appId: String) {
        self.appId = appId
        tokenStore = PassageTokenStore(appId: appId)
    }
    
    /// Creates and sends a one-time passcode to register the user. The user will receive an email or text
    /// with the code.
    ///
    /// - Parameters:
    ///   - identifier: user's email or phone number
    ///   - language: optional language string for localizing emails, if no lanuage or an invalid language
    ///   is provided the application default lanuage will be used
    /// - Returns: `OneTimePasscodeResponse` includes the one-time passcode ID, which will be
    /// used to activate the one-time passcode
    /// - Throws: `OneTimePasscodeError`
    public func register(
        identifier: String,
        language: String? = nil
    ) async throws -> OneTimePasscodeResponse {
        do {
           let request = RegisterOneTimePasscodeRequest(
               identifier: identifier,
               language: language
           )
           return try await RegisterAPI
               .registerOneTimePasscode(
                   appId: appId,
                   registerOneTimePasscodeRequest: request
               )
       } catch {
           throw OneTimePasscodeError.convert(error: error)
       }
    }
    
    /// Creates and send a one-time passcode to login the user. The user will receive an email or text with
    /// the code.
    ///
    /// - Parameters:
    ///   - identifier: user's email or phone number
    ///   - language: optional language string for localizing emails, if no lanuage or an invalid language is
    ///   provided the application default lanuage will be used
    /// - Returns: `OneTimePasscodeResponse` includes the one-time passcode ID, which will be used
    /// to activate the one-time passcode
    /// - Throws: `OneTimePasscodeError`
    public func login(identifier: String, language: String? = nil) async throws -> OneTimePasscodeResponse {
        do {
            let request = LoginOneTimePasscodeRequest(
                identifier: identifier,
                language: language
            )
            return try await LoginAPI
                .loginOneTimePasscode(
                    appId: appId,
                    loginOneTimePasscodeRequest: request
                )
        } catch {
            throw OneTimePasscodeError.convert(error: error)
        }
    }
    
    /// Completes a one-time passcode flow by activating the one-time passcode.
    ///
    /// - Parameter otp: string - The one-time provided by your user
    /// - Parameter id: string - The one-time passcode id returned from login or register method
    /// - Returns: `AuthResult` The AuthResult struct contains the user's authentication token.
    /// - Throws: `OneTimePasscodeError`
    @discardableResult
    public func activate(otp: String, id: String) async throws -> AuthResult {
        do {
            let request = ActivateOneTimePasscodeRequest(
                otp: otp,
                otpId: id
            )
            let response = try await OTPAPI.activateOneTimePasscode(
                appId: appId,
                activateOneTimePasscodeRequest: request
            )
            tokenStore.setTokens(authResult: response.authResult)
            return response.authResult
        } catch {
            throw OneTimePasscodeError.convert(error: error)
        }
    }

}
