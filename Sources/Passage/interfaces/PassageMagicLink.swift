import Foundation

/// A class allowing interaction with the Passage Magic Link API.
public class PassageMagicLink {
    
    private let appId: String
    private let tokenStore: PassageTokenStore
    
    init(appId: String) {
        self.appId = appId
        tokenStore = PassageTokenStore(appId: appId)
    }
    
    /// Creates and sends a magic link to register the user. The user will receive an email or text to
    /// complete the registration.
    ///
    /// - Parameters:
    ///   - identifier: user's email or phone number
    ///   - language: optional language string for localizing emails, if no lanuage or an invalid
    ///   language is provided the application default lanuage will be used
    /// - Returns: `MagicLink` Iincludes the magic link ID, which can be used to check if the
    /// magic link has been activate or not, using the status() method
    /// - Throws: `MagicLinkError`
    public func register(identifier: String, language: String? = nil) async throws -> MagicLink {
        do {
           let request = RegisterMagicLinkRequest(
               identifier: identifier,
               language: language
           )
           let response = try await RegisterAPI
               .registerMagicLink(
                   appId: appId,
                   user: request
               )
           return response.magicLink
       } catch {
           throw MagicLinkError.convert(error: error)
       }
    }
    
    /// Creates and send a magic link to login the user. The user will receive an email or text to
    /// complete the login.
    ///
    /// - Parameters:
    ///   - identifier: user's email or phone number
    ///   - language: optional language string for localizing emails, if no lanuage or an invalid
    ///   language is provided the application default lanuage will be used
    /// - Returns: `MagicLink` Iincludes the magic link ID, which can be used to check if the
    /// magic link has been activate or not, using the status() method
    /// - Throws: `MagicLinkError`
    public func login(identifier: String, language: String? = nil) async throws -> MagicLink {
        do {
            let request = LoginMagicLinkRequest(
                identifier: identifier,
                language: language
            )
            let response = try await LoginAPI
                .loginMagicLink(
                    appId: appId,
                    loginMagicLinkRequest: request
                )
            return response.magicLink
        } catch {
            throw MagicLinkError.convert(error: error)
        }
    }
    
    /// Completes a magic link login flow by activating the magic link.
    ///
    /// - Parameter magicLink: full magic link (sent via email or text to the user)
    /// - Returns: `AuthResult` The AuthResult struct contains the user's  authentication token.
    /// - Throws: `MagicLinkError`
    @discardableResult
    public func activate(magicLink: String) async throws -> AuthResult {
        do {
            let request = ActivateMagicLinkRequest(magicLink: magicLink)
            let response = try await MagicLinkAPI
                .activateMagicLink(
                    appId: appId,
                    activateMagicLinkRequest: request
                )
            tokenStore.setTokens(authResult: response.authResult)
            return response.authResult
        } catch {
            throw MagicLinkError.convert(error: error)
        }
    }
    
    /// Checks the status of a magic link to see if it has been activated.
    ///
    /// - Parameter id: ID of the magic link (from response body of login or register with magic link)
    /// - Returns: If magic link has been activated, an `AuthResult` struct containing the user's
    /// authentication token will be returned.
    /// - Throws: `MagicLinkError`
    public func status(id: String) async throws -> AuthResult {
        do {
            let request = GetMagicLinkStatusRequest(id: id)
            let response = try await MagicLinkAPI
                .magicLinkStatus(
                    appId: appId,
                    getMagicLinkStatusRequest: request
                )
            tokenStore.setTokens(authResult: response.authResult)
            return response.authResult
        } catch {
            throw MagicLinkError.convert(error: error)
        }
    }
}
