import AnyCodable

/// A class representing the Passage application, allowing interaction with the application's API.
public class PassageApp {
    
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    /// Fetches information about the Passage app.
    /// - Returns: A PassageAppInfo struct containing the app's details.
    /// - Throws: `PassageAppError` if the API call fails.
    public func info() async throws -> PassageAppInfo {
        do {
           let appInfoResponse = try await AppsAPI.getApp(appId: appId)
           return appInfoResponse.app
       } catch {
           throw PassageAppError.convert(error: error)
       }
    }
    
    /// Checks if a user exists for a given identifier.
    ///
    /// - Parameter identifier: The identifier (e.g., email or phone number) to check for existence.
    /// - Returns: A PublicUserInfo struct if the user exists, or `nil` if not.
    /// - Throws: `PassageAppError` if the request is invalid or an error occurs during the API call.
    public func userExists(identifier: String) async throws -> PublicUserInfo? {
        do {
            guard let safeId = identifier
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            else {
                throw PassageAppError.invalidRequest(message: "invalid identifier")
            }
            let response = try await UsersAPI
                .checkUserIdentifier(
                    appId: appId,
                    identifier: safeId
                )
            return response.user
        } catch {
            throw PassageAppError.convert(error: error)
        }
    }
    
    /// Creates a new user with the specified identifier and optional metadata.
    /// - Parameters:
    ///   - identifier: The identifier (e.g., email or  phone number) for the new user.
    ///   - userMetadata: Optional metadata to associate with the user.
    /// - Returns: A PublicUserInfo struct representing the newly created user.
    /// - Throws: `PassageAppError` if an error occurs during user creation or the API call fails.
    public func createUser(
        identifier: String,
        userMetadata: AnyCodable? = nil
    ) async throws -> PublicUserInfo {
        do {
            let params = CreateUserParams(
                identifier: identifier,
                userMetadata: userMetadata
            )
            let response = try await UsersAPI.createUser(
                appId: appId,
                createUserParams: params
            )
            return response.user
        } catch {
            throw PassageAppError.convert(error: error)
        }
    }
    
}
