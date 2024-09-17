import AuthenticationServices

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
@available(watchOS, unavailable)
extension ASAuthorizationPublicKeyCredentialAssertion {
    
    /// Converts assertion credential into a handshake response formatted for Passage webauthn finish request.
    ///
    /// - Returns: CredentialAssertionResponse
    internal func response() -> CredentialAssertionResponse {
        let response = CredentialAssertionResponseResponse(
            authenticatorData: rawAuthenticatorData.encodeBase64UrlSafeString(),
            clientDataJSON: rawClientDataJSON.encodeBase64UrlSafeString(),
            signature: signature.encodeBase64UrlSafeString(),
            userHandle: String(data: userID, encoding: .utf8)
        )
        let credentialId = credentialID.encodeBase64UrlSafeString()
        return CredentialAssertionResponse(
            id: credentialId,
            rawId: credentialId,
            response: response,
            type: "public-key"
        )
    }
    
}
