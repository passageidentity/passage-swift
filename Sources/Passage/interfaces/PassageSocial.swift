import Foundation

/// A class for enabling user authentication via social providers like Apple, Google, and GitHub.
public class PassageSocial {
    
    private let appId: String
    private let tokenStore: PassageTokenStore
    
    init(appId: String) {
        self.appId = appId
        tokenStore = PassageTokenStore(appId: appId)
    }
    #if os(iOS) || os(macOS) || os(visionOS)
    /// Authorizes user via a supported third-party social provider.
    ///
    /// Using `PassageSocialConnection.apple` connection triggers the native Sign in with Apple
    /// UI, while all other connections trigger a secure web view.
    ///
    /// - Parameters:
    ///   - connection: PassageSocialConnection - the Social connection to use for authorization
    ///   - prefersEphemeralWebBrowserSession: Bool - Set
    ///   prefersEphemeralWebBrowserSession to true to request that the browser doesn’t share cookies
    ///   or other browsing data between the authentication session and the user’s normal browser session.
    ///   Defaults to false.
    /// - Returns: `AuthResult`
    /// - Throws: `SocialAuthError`
    @discardableResult
    public func authorize(
       connection: PassageSocialConnection,
       prefersEphemeralWebBrowserSession: Bool = false
    ) async throws -> AuthResult {
       do {
           let socialAuthController = PassageSocialAuthController()
           if connection == .apple {
               let (authCode, idToken) = try await socialAuthController.signInWithApple()
               let request = IdTokenRequest(
                   code: authCode,
                   idToken: idToken,
                   connectionType: .apple
               )
               let response = try await OAuth2API
                   .exchangeSocialIdToken(
                       appId: appId,
                       idTokenRequest: request
                   )
               return response.authResult
           } else {
               let queryParams = socialAuthController.getSocialAuthQueryParams(
                   appId: appId,
                   connection: connection
               )
               guard let authUrl = getSocialAuthUrl(queryParams: queryParams) else {
                   throw SocialError.invalidUrl(message: "invalid url")
               }
               let urlScheme = PassageSocialAuthController.getCallbackUrlScheme(appId: appId)
               let authCode = try await socialAuthController.openSecureWebView(
                   url: authUrl,
                   callbackURLScheme: urlScheme,
                   prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
               )
               let verifier = socialAuthController.verifier
               let response = try await OAuth2API
                   .exchangeSocialToken(
                       appId: appId,
                       code: authCode,
                       verifier: verifier
                   )
               tokenStore.setTokens(authResult: response.authResult)
               return response.authResult
           }
       } catch {
           throw SocialError.convert(error: error)
       }
    }
    
    internal func getSocialAuthUrl(queryParams: String) -> URL? {
        return URL(string: "\(OpenAPIClientAPI.basePath)/apps/\(appId)/social/authorize?\(queryParams)")
    }
    #endif

}

