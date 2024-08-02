import Foundation

public enum PassageAppError: PassageError {
    
    case appNotFound
    case invalidRequest
    case unspecified
    
    public static func convert(error: Error) -> PassageAppError {
        // Check if error is already proper
        if let passageAppError = error as? PassageAppError {
            return passageAppError
        }
        // Handle client error
        if let errorResponse = error as? ErrorResponse {
            guard let (_, errorData) = PassageErrorData.getData(from: errorResponse) else {
                return .unspecified
            }
            return switch errorData.code {
            case Model404Code.appNotFound.rawValue: .appNotFound
            case Model400Code.request.rawValue: .invalidRequest
            default: .unspecified
            }
        }
        return .unspecified
    }
    
}
