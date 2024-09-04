import Foundation

public enum PassageAppError: PassageError {
    
    case appNotFound(message: String)
    case invalidRequest(message: String)
    case unspecified(message: String)
    
    public var errorDescription: String {
        switch self {
        case .appNotFound(let message),
             .invalidRequest(let message),
             .unspecified(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> PassageAppError {
        // Check if error is already proper
        if let passageAppError = error as? PassageAppError {
            return passageAppError
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse,
           let (_, errorData) = PassageErrorData.getData(from: errorResponse) {
            switch errorData.code {
            case Model404Code.appNotFound.rawValue:
                return .appNotFound(message: errorData.error)
            case Model400Code.request.rawValue:
                return .invalidRequest(message: errorData.error)
            default: ()
            }
        }
        return .unspecified(message: "unspecified error")
    }
    
}
