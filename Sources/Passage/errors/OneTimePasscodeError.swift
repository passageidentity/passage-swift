import Foundation

public enum OneTimePasscodeError: PassageError {
    
    case exceededAttempts(message: String)
    case invalidRequest(message: String)
    case unspecified(message: String)
    case userAlreadyExists(message: String)
    case userDoesNotExist(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .exceededAttempts(message: let message),
            .invalidRequest(message: let message),
            .unspecified(let message),
            .userAlreadyExists(let message),
            .userDoesNotExist(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> OneTimePasscodeError {
        // Check if error is already proper
        if let error = error as? OneTimePasscodeError {
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
            case Model404Code.userNotFound.rawValue:
                return .userDoesNotExist(message: errorData.error)
            case "exceeded_attempts":
                return .exceededAttempts(message: errorData.error)
            default: ()
            }
        }
        return .unspecified(message: "unspecified error")
    }
    
}
