import Foundation

internal struct PasskeyRegistrationRequest {
    let relyingPartyIdentifier: String
    let challenge: Data
    let userName: String
    let userId: Data
    
    /// Converts a Passage webauthn start response into a passkey registration request to provide to OS.
    ///
    /// - Parameter response: Response from calling Passage webauthn start.
    ///
    /// - Returns: DTO for prompting user to register with a passkey.
    internal static func from(
        _ response: RegisterWebAuthnStartResponse
    ) throws -> PasskeyRegistrationRequest {
        guard
            let publicKey = response.handshake.challenge.publicKey,
            let rpId = publicKey.rp?.id,
            let challenge = publicKey.challenge?.decodeBase64UrlSafeString(),
            let user = publicKey.user,
            let userId = user.id,
            let userName = user.name
        else {
            throw PassagePasskeyAuthorizationError.webauthnError
        }
        return PasskeyRegistrationRequest(
            relyingPartyIdentifier: rpId,
            challenge: challenge,
            userName: userName,
            userId: Data(userId.utf8)
        )
    }
    
}
