import AuthenticationServices

public enum CurrentUserError: PassageError {
    
    case authorizationFailed(message: String)
    case canceled(message: String)
    case userNotActive(message: String)
    case invalidRequest(message: String)
    case userNotFound(message: String)
    case unauthorized(message: String)
    case unspecified(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .authorizationFailed(message: let message),
            .canceled(message: let message),
            .userNotActive(message: let message),
            .invalidRequest(message: let message),
            .userNotFound(let message),
            .unauthorized(let message),
            .unspecified(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> CurrentUserError {
        // Check if error is already proper
        if let userError = error as? CurrentUserError {
            return userError
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (statusCode, errorData) = PassageErrorData.getData(from: errorResponse) {
            switch errorData.code {
            case Model400Code.request.rawValue: return .invalidRequest(message: errorData.error)
            case Model403Code.userNotActive.rawValue: return .userNotActive(message: errorData.error)
            case Model404Code.userNotFound.rawValue: return .userNotFound(message: errorData.error)
            default: ()
            }
            if statusCode == 401 {
                return .unauthorized(message: errorData.error)
            }
            return .unspecified(message: errorData.error)
        }
        // Handle authorization error
        if let authError = error as? ASAuthorizationError {
            return authError.code == .canceled ?
                .canceled(message: error.localizedDescription) :
                .authorizationFailed(message: error.localizedDescription)
        }
        return .unspecified(message: "unspecified error")
    }
    
}
