import AuthenticationServices

public enum HostedAuthorizationError: PassageError {
    
    case authorizationFailed(message: String)
    case canceled(message: String = "user canceled authentication")
    case cannotAccessAppBundleId(message: String = "cannot access app bundle id")
    case cannotAccessAppInfo(message: String = "cannot access passage app info")
    case cannotAccessAppRootViewController(message: String = "cannot access app root view controller")
    case invalidHostedAuthUrl(message: String = "hosted auth url is invalid")
    case invalidHostedCallbackUrl(message: String = "hosted callback url is invalid")
    case invalidHostedLogoutUrl(message: String = "hosted logout url is invalid")
    case invalidHostedTokenUrl(message: String = "hosted token url is invalid")
    case missingIdToken(message: String = "missing id token")
    case serverError(message: String)
    case unauthorized(message: String)
    case unspecified(message: String)
    
    public var errorDescription: String {
        switch self {
        case
            .authorizationFailed(let message),
            .canceled(let message),
            .cannotAccessAppBundleId(let message),
            .cannotAccessAppInfo(let message),
            .cannotAccessAppRootViewController(let message),
            .invalidHostedAuthUrl(let message),
            .invalidHostedCallbackUrl(let message),
            .invalidHostedLogoutUrl(let message),
            .invalidHostedTokenUrl(let message),
            .missingIdToken(let message),
            .serverError(let message),
            .unauthorized(let message),
            .unspecified(let message):
            return message
        }
    }
    
    public static func convert(error: Error) -> HostedAuthorizationError {
        // Check if error is already proper
        if let error = error as? HostedAuthorizationError {
            return error
        }
        // Handle authorization error
        if error is ASAuthorizationError {
            return .authorizationFailed(message: error.localizedDescription)
        }
        return .unspecified(message: error.localizedDescription)
    }
}
