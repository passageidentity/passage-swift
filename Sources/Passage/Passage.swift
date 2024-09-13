import Foundation

/// The `Passage` class provides access to various authentication mechanisms and user management
/// features for your Passage app.
public class Passage {
    
    /// The unique identifier of your Passage app.
    private let appId: String
    
    /// Provides access to your Passage app info and functions.
    public let app: PassageApp
    
    /// Handles all functionality related to passkey authentication, enabling upi to easily integrate
    /// passkey support into your application.
    public let passkey: PassagePasskey
    
    /// Manages magic link authentication, allowing users to authenticate by tapping a link sent to their
    /// email or phone.
    public let magicLink: PassageMagicLink
    
    /// Manages one-time passcode (OTP) authentication, allowing users to authenticate using a code
    /// sent to their phone or email.
    public let oneTimePasscode: PassageOneTimePasscode
    
    /// Handles social login integrations, such as signing in with Apple, Google, etc.
    public let social: PassageSocial
    
    /// Provides support for hosted login and registration pages, enabling the use of Passage’s hosted
    /// authentication flows.
    public let hosted: PassageHosted
    
    /// Contains functions to get and update information about the currently authenticated user.
    public let currentUser: PassageCurrentUser
    
    /// Handles token storage and retrieval, used for securely storing and managing authentication tokens
    /// like JWTs.
    public let tokenStore: PassageTokenStore
    
    /// Initializes a new instance of the `Passage` class with the given application ID.
    ///
    /// - Parameter appId: The unique identifier for the Passage application.
    public init(appId: String) {
        self.appId = appId
        PassageClientService.setup()
        app = PassageApp(appId: appId)
        passkey = PassagePasskey(appId: appId)
        magicLink = PassageMagicLink(appId: appId)
        oneTimePasscode = PassageOneTimePasscode(appId: appId)
        social = PassageSocial(appId: appId)
        hosted = PassageHosted(appId: appId)
        currentUser = PassageCurrentUser(appId: appId)
        tokenStore = PassageTokenStore(appId: appId)
    }
    
}
