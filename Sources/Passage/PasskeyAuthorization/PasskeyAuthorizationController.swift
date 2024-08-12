import AuthenticationServices

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
internal class PasskeyAuthorizationController:
    NSObject,
    ASAuthorizationControllerDelegate {
    
    private var registrationCredentialContinuation: RegistrationCredentialContinuation?
    
    private var assertionCredentialContinuation: AssertionCredentialContinuation?
    
    internal func requestPasskeyRegistration(
        registrationRequest: PasskeyRegistrationRequest,
        includeSecurityKeyOption: Bool = false
    ) async throws -> ASAuthorizationPublicKeyCredentialRegistration {
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: registrationRequest.relyingPartyIdentifier
        )
        let platformRegistrationRequest = publicKeyCredentialProvider
            .createCredentialRegistrationRequest(
                challenge: registrationRequest.challenge,
                name: registrationRequest.userName,
                userID: registrationRequest.userId
            )
        // To match other webauthn "cross-platform" behaviors, we always include a Platform provider
        // request, never JUST a Security Key provider request.
        var requests: [ASAuthorizationRequest] = [ platformRegistrationRequest ]
        #if os(iOS) || os(macOS)
        if includeSecurityKeyOption {
            let securityKeyCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(
                relyingPartyIdentifier: registrationRequest.relyingPartyIdentifier
            )
            let securityKeyRegistrationRequest = securityKeyCredentialProvider
                .createCredentialRegistrationRequest(
                    challenge: registrationRequest.challenge,
                    displayName: registrationRequest.userName,
                    name: registrationRequest.userName,
                    userID: registrationRequest.userId
                )
            securityKeyRegistrationRequest.credentialParameters = [
                ASAuthorizationPublicKeyCredentialParameters(
                    algorithm: ASCOSEAlgorithmIdentifier.ES256
                )
            ]
            requests.append(securityKeyRegistrationRequest)
        }
        #endif
        let authController = ASAuthorizationController(authorizationRequests: requests)
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
        return try await withCheckedThrowingContinuation(
            { [weak self] (continuation: RegistrationCredentialContinuation) in
                self?.registrationCredentialContinuation = continuation
            }
        )
    }
    
    internal func requestPasskeyAssertion(
        assertionRequest: PasskeyAssertionRequest
    ) async throws -> ASAuthorizationPublicKeyCredentialAssertion {
        // Handle platform request
        let platformCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: assertionRequest.relyingPartyIdentifier
        )
        let platformAssertionRequest = platformCredentialProvider
            .createCredentialAssertionRequest(
                challenge: assertionRequest.challenge
            )
        // Handle security key request
        #if os(iOS) || os(macOS)
        let securityKeyCredentialProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(
            relyingPartyIdentifier: assertionRequest.relyingPartyIdentifier
        )
        let securityKeyAssertionRequest = securityKeyCredentialProvider
            .createCredentialAssertionRequest(
                challenge: assertionRequest.challenge
            )
        #endif
        // Setting `allowedCredentials` lets us specify which account the offered passkeys
        // should be tied to.
        // If this is not set, iOS will show all of the potential accounts' passkeys.
        if let allowedCredentials = assertionRequest.allowedCredentials, !allowedCredentials.isEmpty {
            platformAssertionRequest.allowedCredentials = allowedCredentials
                .compactMap { $0.id.decodeBase64UrlSafeString() }
                .map { ASAuthorizationPlatformPublicKeyCredentialDescriptor(
                    credentialID: $0
                ) }
            #if os(iOS) || os(macOS)
            securityKeyAssertionRequest.allowedCredentials = allowedCredentials
                .map {
                    ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(
                        credentialID: $0.id.decodeBase64UrlSafeString() ?? Data(),
                        transports:
                            $0.transports?.map {
                                ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport($0)
                            } ?? []
                    )
                }
            #endif
        }
        var authorizationRequests: [ASAuthorizationRequest] = [platformAssertionRequest]
        #if os(iOS) || os(macOS)
        if securityKeyAssertionRequest.allowedCredentials.first?.transports.isEmpty == false {
            authorizationRequests.append(securityKeyAssertionRequest)
        }
        #endif
        let authController = ASAuthorizationController(authorizationRequests: authorizationRequests)
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
        return try await withCheckedThrowingContinuation(
            { [weak self] (continuation: AssertionCredentialContinuation) in
                self?.assertionCredentialContinuation = continuation
            }
        )
    }
    
    // MARK: ASAuthorizationControllerDelegate Methods
    
    internal func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let registrationCredential as ASAuthorizationPublicKeyCredentialRegistration:
            registrationCredentialContinuation?.resume(returning: registrationCredential)
        case let assertionCredential as ASAuthorizationPublicKeyCredentialAssertion:
            assertionCredentialContinuation?.resume(returning: assertionCredential)
        default:
            ()
        }
    }
    
    internal func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        assertionCredentialContinuation?.resume(throwing: error)
    }
    
}

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
extension PasskeyAuthorizationController: ASAuthorizationControllerPresentationContextProviding {
    
    #if os(iOS) || os(visionOS)
    @available(iOS 16.0, visionOS 1.0, *)
    internal func requestPasskeyAssertionAutoFill (
        assertionRequest: PasskeyAssertionRequest
    ) async throws -> ASAuthorizationPublicKeyCredentialAssertion {
        // Autofill requests can only use a Platform provider, no need to support Security Key provider.
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
            relyingPartyIdentifier: assertionRequest.relyingPartyIdentifier
        )
        let authAssertionRequest = publicKeyCredentialProvider
            .createCredentialAssertionRequest(
                challenge: assertionRequest.challenge
            )
        let authController = ASAuthorizationController(
            authorizationRequests: [ authAssertionRequest ]
        )
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performAutoFillAssistedRequests()
        return try await withCheckedThrowingContinuation(
            { [weak self] (continuation: AssertionCredentialContinuation) in
                self?.assertionCredentialContinuation = continuation
            }
        )
    }
    #endif
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding Methods
    
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(macOS)
        return NSApp.windows.last(where: \.isKeyWindow) ?? ASPresentationAnchor()
        #else
        return UIApplication.shared.windows.last(where: \.isKeyWindow) ?? ASPresentationAnchor()
        #endif
    }
    
}
