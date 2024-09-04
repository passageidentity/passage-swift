import AuthenticationServices

public enum SocialError: PassageError {
    
    case authorizationFailed(message: String)
    case connectionNotSetupForPassageApp(message: String)
    case inactiveUser(message: String)
    case invalidRequest(message: String)
    case invalidUrl(message: String)
    case missingAppleCredentials(message: String)
    case missingAuthCode(message: String)
    case unspecified(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .authorizationFailed(message: let message),
            .connectionNotSetupForPassageApp(message: let message),
            .inactiveUser(let message),
            .invalidRequest(let message),
            .invalidUrl(let message),
            .missingAppleCredentials(let message),
            .missingAuthCode(let message),
            .unspecified(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> SocialError {
        // Check if error is already proper
        if let socialError = error as? SocialError {
            return socialError
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (_, errorData) = PassageErrorData.getData(from: errorResponse) {
            switch errorData.code {
            case Model400Code.request.rawValue: return .invalidRequest(message: errorData.error)
            case Model403Code.identifierNotVerified.rawValue: return .inactiveUser(message: errorData.error)
            default: ()
            }
        }
        // Handle authorization error
        if error is ASAuthorizationError {
            return .authorizationFailed(message: error.localizedDescription)
        }
        return .unspecified(message: error.localizedDescription)
    }
    
}
