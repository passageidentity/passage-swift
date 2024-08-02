import Foundation

public enum MagicLinkError: PassageError {
    
    case invalidRequest(message: String)
    case magicLinkNotFound(message: String)
    case unspecified(message: String)
    case userAlreadyExists(message: String)
    case userNotActive(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .invalidRequest(message: let message),
            .magicLinkNotFound(let message),
            .unspecified(let message),
            .userAlreadyExists(let message),
            .userNotActive(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> MagicLinkError {
        // Check if error is already proper
        if let error = error as? MagicLinkError {
            return error
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (_, errorData) = PassageErrorData.getData(from: errorResponse)
        {
            switch errorData.code {
            case Model400Code.request.rawValue:
                if errorData.error == "user: already exists." {
                    return .userAlreadyExists(message: errorData.error)
                } else {
                    return .invalidRequest(message: errorData.error)
                }
            case Model403Code.userNotActive.rawValue:
                return .userNotActive(message: errorData.error)
            case Model404Code.magicLinkNotFound.rawValue:
                return .magicLinkNotFound(message: errorData.error)
            default: ()
            }
        }
        return .unspecified(message: "unspecified error")
    }
    
}
