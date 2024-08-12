import Foundation

/// Options to customize how your user's passkey is created.
@available(iOS 16.0, macOS 12.0, watchOS 9.0, visionOS 1.0, tvOS 16.0, *)
public struct PasskeyCreationOptions {
    
    /// Set to `.crossPlatform` to provide option for user  to store credential on a physical Security Key.
    public let authenticatorAttachment: AuthenticatorAttachment?
    
    /// Set to `true` to create a passkey without asking the user.
    ///
    /// NOTE: Only applicable on iOS 18.0+.
    public let isConditionalMediation: Bool?
    
    public init(authenticatorAttachment: AuthenticatorAttachment?, isConditionalMediation: Bool?) {
        self.authenticatorAttachment = authenticatorAttachment
        self.isConditionalMediation = isConditionalMediation
    }
    
}
