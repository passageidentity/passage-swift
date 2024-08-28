import Foundation

/// `PassageTokenStore` is responsible for securely storing and managing authentication tokens
/// (auth token, refresh token, and ID token) in the keychain.
public class PassageTokenStore {
    
    private let keychain = PassageKeychainService()
    
    // Keys used to store tokens in the keychain.
    private static let authTokenKey = "passageAuthToken"
    private static let refreshTokenKey = "passageRefreshToken"
    private static let idTokenKey = "passageIdToken"
    
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    /// The Passage authentication token stored in the keychain.
    /// This token is used to authenticate requests to the server.
    public var authToken: String? {
        get {
            return keychain.getString(key: PassageTokenStore.authTokenKey)
        }
        set {
            if let newValue {
                keychain.addString(key: PassageTokenStore.authTokenKey, value: newValue)
            } else {
                keychain.deleteString(key: PassageTokenStore.authTokenKey)
            }
        }
    }
    
    /// The Passage refresh token stored in the keychain.
    /// This token is used to obtain a new auth token when the current one expires.
    public var refreshToken: String? {
        get {
            return keychain.getString(key: PassageTokenStore.refreshTokenKey)
        }
        set {
            if let newValue {
                keychain.addString(key: PassageTokenStore.refreshTokenKey, value: newValue)
            } else {
                keychain.deleteString(key: PassageTokenStore.refreshTokenKey)
            }
        }
    }
    
    /// The ID token stored in the keychain (Hosted apps only).
    /// This token is used for managing a Hosted app's web auth session.
    public var idToken: String? {
        get {
            return keychain.getString(key: PassageTokenStore.idTokenKey)
        }
        set {
            if let newValue {
                keychain.addString(key: PassageTokenStore.idTokenKey, value: newValue)
            } else {
                keychain.deleteString(key: PassageTokenStore.idTokenKey)
            }
        }
    }
    /// Stores the authentication tokens provided in the `AuthResult` object.
    /// - Parameter authResult: The result containing the auth and refresh tokens.
    public func setTokens(authResult: AuthResult) {
        authToken = authResult.authToken
        refreshToken = authResult.refreshToken
    }
    
    /// Clears all tokens from the keychain.
    private func clearTokenStore() {
        authToken = nil
        refreshToken = nil
        idToken = nil
    }
    
    /// Retrieves a valid authentication token, refreshing it if necessary.
    /// - Throws: An error if the token could not be refreshed or if there is no refresh token saved in the
    /// keychain.
    /// - Returns: A valid authentication token.
    public func getValidAuthToken() async throws -> String {
        guard let authToken else {
            throw TokenError.authTokenNotFound()
        }
        if isAuthTokenValid() {
            return authToken
        }
        let newAuthResult = try await refreshTokens()
        return newAuthResult.authToken
    }
    
    /// Refreshes the authentication tokens using the refresh token.
    /// - Throws: An error if the refresh operation fails or if there is no refresh token saved in the
    /// keychain.
    /// - Returns: The new `AuthResult` containing the authentication token and refresh token.
    public func refreshTokens() async throws -> AuthResult {
        guard let refreshToken else {
            throw TokenError.refreshTokenNotFound()
        }
        do {
            let request = RefreshAuthTokenRequest(refreshToken: refreshToken)
            let response = try await TokensAPI.refreshAuthToken(
                appId: appId,
                refreshAuthTokenRequest: request
            )
            let authResult = response.authResult
            setTokens(authResult: authResult)
            return authResult
        } catch {
            throw TokenError.convert(error: error)
        }
    }
    
    /// Revokes the current refresh token, removing it from the server.
    /// - Throws: An error if the revocation request fails.
    public func revokeRefreshToken() async throws {
        guard let refreshToken else {
            throw TokenError.refreshTokenNotFound()
        }
        do {
            try await TokensAPI.revokeRefreshToken(appId: appId, refreshToken: refreshToken)
        } catch {
            throw TokenError.convert(error: error)
        }
    }
    
    /// Validates the current authentication token by checking its expiration date.
    /// - Returns: A Boolean value indicating whether the authentication token is still valid.
    public func isAuthTokenValid() -> Bool {
        guard
            let tokenParts = authToken?.split(separator: "."),
            tokenParts.count == 3,
            let payloadData = String(tokenParts[1]).decodeBase64UrlSafeString(),
            let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
            let exp = payload["exp"] as? TimeInterval
        else {
            return false
        }
        let expirationDate = Date(timeIntervalSince1970: exp)
        return expirationDate > Date()
    }

}
