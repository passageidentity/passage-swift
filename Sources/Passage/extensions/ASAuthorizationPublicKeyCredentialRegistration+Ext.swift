import AuthenticationServices

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
extension ASAuthorizationPublicKeyCredentialRegistration {
    
    /// Converts registration credential into a handshake response formatted for Passage webauthn finish request.
    ///
    /// - Returns: CredentialCreationResponse
    internal func response() -> CredentialCreationResponse {
        let response = CredentialCreationResponseResponse(
            attestationObject: rawAttestationObject?.encodeBase64UrlSafeString(),
            clientDataJSON: rawClientDataJSON.encodeBase64UrlSafeString()
        )
        let credentialId = credentialID.encodeBase64UrlSafeString()
        return CredentialCreationResponse(
            id: credentialId,
            rawId: credentialId,
            response: response,
            type: "public-key"
        )
    }
    
}
