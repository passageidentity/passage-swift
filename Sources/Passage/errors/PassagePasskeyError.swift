import AuthenticationServices

public enum PassagePasskeyError: PassageError {
    
    case authorizationFailed(message: String)
    case canceled(message: String)
    case discoverableLoginFailed(message: String)
    case invalidRequest(message: String)
    case webauthnLoginFailed(message: String)
    case unspecified(message: String)
    case userAlreadyExists(message: String)
    case userDoesNotExist(message: String)
    case userNotActive(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .authorizationFailed(message: let message),
            .canceled(message: let message),
            .discoverableLoginFailed(let message),
            .invalidRequest(let message),
            .webauthnLoginFailed(let message),
            .unspecified(let message),
            .userAlreadyExists(let message),
            .userDoesNotExist(let message),
            .userNotActive(message: let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> PassagePasskeyError {
        // Check if error is already proper
        if let error = error as? PassagePasskeyError {
            return error
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (_, errorData) = PassageErrorData.getData(from: errorResponse) {
            switch errorData.code {
            case Model400Code.request.rawValue:
                if errorData.error == "user: already exists." {
                    return .userAlreadyExists(message: errorData.error)
                } else {
                    return .invalidRequest(message: errorData.error)
                }
            case Model401Code.discoverableLoginFailed.rawValue:
                return .discoverableLoginFailed(message: errorData.error)
            case Model401Code.webauthnLoginFailed.rawValue:
                return .webauthnLoginFailed(message: errorData.error)
            case Model403Code.userNotActive.rawValue:
                return .userNotActive(message: errorData.error)
            case Model404Code.userNotFound.rawValue:
                return .userDoesNotExist(message: errorData.error)
            default: ()
            }
        }
        // Handle authorization error
        if let authError = error as? ASAuthorizationError {
            return authError.code == .canceled ?
                .canceled(message: error.localizedDescription) :
                .authorizationFailed(message: error.localizedDescription)
        }
        return .unspecified(message: error.localizedDescription)
    }
    
}
