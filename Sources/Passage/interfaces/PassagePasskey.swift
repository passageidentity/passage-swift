import Foundation

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
public final class PassagePasskey {
    
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    /// Register a user using a passkey.
    ///
    /// - Parameters:
    ///   - identifier: The user's email, phone number, or other unique id
    ///   - options: Options to customize how your user's passkey is created
    /// - Returns: `AuthResult`
    /// - Throws: `PassagePasskeyError`
    public func register(
        identifier: String,
        options: PasskeyCreationOptions? = nil
    ) async throws -> AuthResult {
        do {
            // Request a Registration Start Handshake from Passage server
            let startRequest = RegisterWebAuthnStartRequest(
                identifier: identifier,
                authenticatorAttachment: options?.authenticatorAttachment
            )
            let startResponse = try await RegisterAPI.registerWebauthnStart(
                appId: appId,
                registerWebAuthnStartRequest: startRequest
            )
            // Use the Registration Start Handshake to prompt the app user to create a passkey
            let registrationRequest = try PasskeyRegistrationRequest.from(startResponse)
            let authController = PasskeyAuthorizationController()
            let credential = try await authController.requestPasskeyRegistration(
                registrationRequest: registrationRequest
            )
            // Send the new Credential Handshake Response to Passage server
            let finishRequest = RegisterWebAuthnFinishRequest(
                handshakeId: startResponse.handshake.id,
                handshakeResponse: credential.response(),
                userId: identifier
            )
            let finishResponse = try await RegisterAPI.registerWebauthnFinish(
                appId: appId,
                registerWebAuthnFinishRequest: finishRequest
            )
            return finishResponse.authResult
        } catch {
            throw PassagePasskeyError.convert(error: error)
        }
    }

    /// Login a user using a passkey.
    ///
    /// - Parameter identifier: The user's email, phone number, or other unique id
    /// - Returns: `AuthResult`
    /// - Throws: `PassagePasskeyError`
    public func login(identifier: String? = nil) async throws -> AuthResult {
        do {
            // Request an Assertion Start Handshake from Passage server
            let startRequest = LoginWebAuthnStartRequest(identifier: identifier)
            let startResponse = try await LoginAPI.loginWebauthnStart(
                appId: appId,
                loginWebAuthnStartRequest: startRequest
            )
            // Use the Assertion Start Handshake to prompt the app user to select a passkey
            let assertionRequest = try PasskeyAssertionRequest.from(startResponse)
            let authController = PasskeyAuthorizationController()
            let credential = try await authController.requestPasskeyAssertion(
                assertionRequest: assertionRequest
            )
            // Send the Credential Handshake Response to Passage server
            let finishRequest = LoginWebAuthnFinishRequest(
                handshakeId: startResponse.handshake.id,
                handshakeResponse: credential.response(),
                userId: identifier
            )
            let finishResponse = try await LoginAPI.loginWebauthnFinish(
                appId: appId,
                loginWebAuthnFinishRequest: finishRequest
            )
            return finishResponse.authResult
        } catch {
            throw PassagePasskeyError.convert(error: error)
        }
        
    }
    
    /// Request to autofill a text field with passkey log in using user's QuickType bar.
    ///
    /// - Parameters:
    ///   - onSuccess: The method that should be called on success.
    ///   - onError: The method that should be called on error.
    #if os(iOS) || os(visionOS)
    public func requestAutoFill(
        onSuccess: @escaping (AuthResult) -> Void,
        onError: @escaping (PassagePasskeyError) -> Void
    ) {
        Task {
            do {
                // Request an Assertion Start Handshake from Passage server
                let startRequest = LoginWebAuthnStartRequest()
                let startResponse = try await LoginAPI.loginWebauthnStart(
                    appId: appId,
                    loginWebAuthnStartRequest: startRequest
                )
                // Use the Assertion Start Handshake to prompt the app user to select the
                // passkey provided in the keyboard autofill.
                let assertionRequest = try PasskeyAssertionRequest.from(startResponse)
                let authController = PasskeyAuthorizationController()
                let credential = try await authController
                    .requestPasskeyAssertionAutoFill(
                        assertionRequest: assertionRequest
                    )
                // Send the Credential Handshake Response to Passage server
                let finishRequest = LoginWebAuthnFinishRequest(
                    handshakeId: startResponse.handshake.id,
                    handshakeResponse: credential.response(),
                    userId: nil
                )
                let finishResponse = try await LoginAPI.loginWebauthnFinish(
                    appId: appId,
                    loginWebAuthnFinishRequest: finishRequest
                )
                onSuccess(finishResponse.authResult)
            } catch {
                onError(PassagePasskeyError.convert(error: error))
            }
        }
    }
    #endif
    
}
