import AuthenticationServices

@available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
@available(watchOS, unavailable)
internal typealias RegistrationCredentialContinuation = CheckedContinuation<
    ASAuthorizationPublicKeyCredentialRegistration,
    Error
>
