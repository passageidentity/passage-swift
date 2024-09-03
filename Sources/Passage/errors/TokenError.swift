import Foundation

public enum TokenError: PassageError {
    
    case authTokenNotFound(message: String = "auth token not found in keychain")
    case refreshTokenNotFound(message: String = "refresh token not found in keychain")
    case invalidRequest(message: String)
    case unauthorized(message: String)
    case unspecified(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .authTokenNotFound(let message),
            .refreshTokenNotFound(let message),
            .invalidRequest(let message),
            .unauthorized(let message),
            .unspecified(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> TokenError {
        // Check if error is already proper
        if let tokenError = error as? TokenError {
            return tokenError
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (code, errorData) = PassageErrorData.getData(from: errorResponse) {
            if errorData.code == Model400Code.request.rawValue {
                return .invalidRequest(message: errorData.error)
            } else if code == 401 {
                return .unauthorized(message: errorData.error)
            }
        }
        return .unspecified(message: error.localizedDescription)
    }
    
}
