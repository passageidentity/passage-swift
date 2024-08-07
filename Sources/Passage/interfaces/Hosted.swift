import Foundation

/// A class for enabling user authentication via a secure hosted web view.
#if os(iOS)
public class Hosted {
    
    private let appId: String
    private var authOrigin: String?
    
    init(appId: String) {
        self.appId = appId
    }
    
    /// Authentication method for Passage Hosted apps
    ///
    /// If your Passage app is Hosted, use this method to register and log in your user. This method will open up a Passage login experience
    /// in a secure web view (users on iOS 17.4+ will get `ASWebAuthenticationSession` for the web view, while users on older versions
    /// will get `SFSafariViewController`).
    ///
    /// - Returns: `AuthResult`
    /// - Throws: `HostedAuthorizationError`
    public func authorize() async throws -> AuthResult {
        if authOrigin == nil {
            authOrigin = try? await PassageApp(appId: appId).info().authOrigin
        }
        guard let authOrigin else {
            throw HostedAuthorizationError.cannotAccessAppInfo()
        }
        let hostedAuthController = try HostedAuthorizationController(
            appId: appId,
            authOrigin: authOrigin
        )
        let authCode: String
        if #available(iOS 17.4, *) {
            authCode = try await hostedAuthController.startWebAuth()
        } else {
            authCode = try await hostedAuthController.startWebAuthSafari()
        }
        let (authResult, idToken) = try await hostedAuthController.finishWebAuth(authCode: authCode)
        // TODO: Save tokens to device.
        return authResult
    }

}
#endif
