import Foundation

public enum PassagePasskeyAuthorizationError: Error {
    case userCanceled
    case failed
    case webauthnError
    case unknown
    
    public var description: String {
        switch self {
        case .userCanceled:
            return "The user canceled the request."
        case .failed:
            return "The authorization request failed."
        case .webauthnError:
            return "The authorization webauthn response is incomplete."
        case .unknown:
            return "An unknown authorization error occurred."
        }
    }
    
}
