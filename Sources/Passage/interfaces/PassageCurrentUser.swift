final public class PassageCurrentUser {
    
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    // MARK: - USER INFO METHODS
    
    /// Get Current User Info
    ///
    /// - Returns: `CurrentUser`
    /// - Throws: `CurrentUserError`
    public func userInfo() async throws -> CurrentUser {
        setAuthTokenHeader()
        do {
            let response = try await CurrentuserAPI.getCurrentuser(appId: appId)
            return response.user
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Change a user's email.
    ///
    /// An email change requires verification, so an email will be sent to the user which they must verify
    /// before the email change takes effect.
    ///
    /// - Parameters:
    ///   - newEmail: The user's new valid email address.
    ///   - language: Optional language string for localizing emails, if no language or an invalid
    ///   language is provided the application default language will be used.
    /// - Returns: `MagicLink`
    /// - Throws: `CurrentUserError`
    public func changeEmail(newEmail: String, language: String? = nil) async throws -> MagicLink {
        setAuthTokenHeader()
        do {
            let request = UpdateUserEmailRequest(language: language, newEmail: newEmail)
            let response = try await CurrentuserAPI
                .updateEmailCurrentuser(
                    appId: appId,
                    updateUserEmailRequest: request
                )
            return response.magicLink
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    public func metadata() async throws -> Metadata {
        setAuthTokenHeader()
        do {
            let response = try await CurrentuserAPI.getCurrentuserMetadata(appId: appId)
            return response.userMetadata
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    public func updateMetadata(newMetaData: Metadata) async throws -> CurrentUser {
        setAuthTokenHeader()
        do {
            let request = UpdateMetadataRequest(userMetadata: newMetaData)
            let response = try await CurrentuserAPI
                .updateCurrentuserMetadata(
                    appId: appId,
                    updateMetadataRequest: request
                )
            return response.user
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Change a user's phone number.
    ///
    /// A phone change requires verification, so an email will be sent to the user which they must verify
    /// before the email change takes effect.
    ///
    /// - Parameters:
    ///   - newPhone: The user's new valid E164 formatted phone number.
    ///   - language: Optional language string for localizing emails, if no language or an invalid
    ///   language is provided the application default language will be used.
    /// - Returns: `MagicLink`
    /// - Throws: `CurrentUserError`
    public func changePhone(newPhone: String, language: String? = nil) async throws -> MagicLink {
        setAuthTokenHeader()
        do {
            let request = UpdateUserPhoneRequest(language: language, newPhone: newPhone)
            let response = try await CurrentuserAPI
                .updatePhoneCurrentuser(
                    appId: appId,
                    updateUserPhoneRequest: request
                )
            return response.magicLink
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    // MARK: - PASSKEY METHODS
    
    /// List passkeys for the current authenticated user.
    ///
    /// - Returns: `[Passkey]`
    /// - Throws: `CurrentUserError`
    public func passkeys() async throws -> [Passkey] {
        setAuthTokenHeader()
        do {
            let response = try await CurrentuserAPI.getCurrentuserDevices(appId: appId)
            return response.devices
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Edit a user's passkey.
    ///
    /// - Parameters:
    ///   - passkeyId: The id of the passkey to edit.
    ///   - newFriendlyName: The passkey's new friently name.
    /// - Returns: `Passkey`
    /// - Throws: `CurrentUserError`
    public func editPasskey(passkeyId: String, newFriendlyName: String) async throws -> Passkey {
        setAuthTokenHeader()
        do {
            let request = UpdateDeviceRequest(friendlyName: newFriendlyName)
            let response = try await CurrentuserAPI
                .updateCurrentuserDevice(
                    appId: appId,
                    deviceId: passkeyId,
                    updateDeviceRequest: request
                )
            return response.device
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Add a passkey for a user.
    ///
    /// - Parameter options: Options to customize how your user's passkey is created
    /// - Returns: `AuthResult`
    /// - Throws: `CurrentUserError`
    @available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
    public func addPasskey(options: PasskeyCreationOptions? = nil) async throws -> AuthResult {
        setAuthTokenHeader()
        do {
            // Request a Registration Start Handshake from Passage server
            let authenticatorAttachment = options?.authenticatorAttachment
            let startRequest = CurrentUserDevicesStartRequest(
                authenticatorAttachment: authenticatorAttachment ?? .platform
            )
            let startResponse = try await CurrentuserAPI
                .postCurrentuserAddDeviceStart(
                    appId: appId,
                    currentUserDevicesStartRequest: startRequest
                )
            let includeSecurityKeyOption = authenticatorAttachment == .any
                || authenticatorAttachment == .crossPlatform
            // Use the Registration Start Handshake to prompt the app user to create a passkey
            let registerResponse = RegisterWebAuthnStartResponse(
                handshake: startResponse.handshake,
                user: startResponse.user
            )
            let registrationRequest = try PasskeyRegistrationRequest.from(registerResponse)
            let authController = PasskeyAuthorizationController()
            let credential = try await authController.requestPasskeyRegistration(
                registrationRequest: registrationRequest,
                includeSecurityKeyOption: includeSecurityKeyOption,
                autoUpgradeAccount: options?.isConditionalMediation == true
            )
            // Send the new Credential Handshake Response to Passage server
            let finishRequest = RegisterWebAuthnFinishRequest(
                handshakeId: startResponse.handshake.id,
                handshakeResponse: credential.response(),
                userId: startResponse.user?.id ?? ""
            )
            let finishResponse = try await RegisterAPI.registerWebauthnFinish(
                appId: appId,
                registerWebAuthnFinishRequest: finishRequest
            )
            return finishResponse.authResult
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Delete a user's passkey.
    ///
    /// This revokes and deletes the public key stored on the server.
    /// The user's private key will still exist on the user's device, but it will no longer be useful.
    /// - Parameter passkeyId: The id of the passkey to delete.
    /// - Throws: `CurrentUserError`
    public func deletePasskey(passkeyId: String) async throws {
        setAuthTokenHeader()
        do {
            try await CurrentuserAPI.deleteCurrentuserDevice(appId: appId, deviceId: passkeyId)
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    // MARK: - SOCIAL METHODS
    
    /// Get the user's Social connections.
    ///
    /// - Returns: `UserSocialConnections`
    /// - Throws: `CurrentUserError`
    public func socialConnections() async throws -> UserSocialConnections {
        setAuthTokenHeader()
        do {
            let response = try await CurrentuserAPI.getCurrentuserSocialConnections(appId: appId)
            return response.socialConnections
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    /// Delete a user's Social connection.
    ///
    /// - Parameter socialConnectionType: The type of social connection to delete. Example: `.apple`
    /// - Throws: `CurrentUserError`
    public func deleteSocialConnection(socialConnectionType: SocialConnection) async throws {
        setAuthTokenHeader()
        do {
            try await CurrentuserAPI.deleteCurrentuserSocialConnection(
                appId: appId,
                socialConnectionType: socialConnectionType
            )
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    public func logOut() async throws {
        do {
            let tokenStore = PassageTokenStore(appId: appId)
            if tokenStore.refreshToken != nil {
                try await tokenStore.revokeRefreshToken()
            }
            OpenAPIClientAPI.customHeaders["Authorization"] = nil
            tokenStore.clearTokenStore()
        } catch {
            throw CurrentUserError.convert(error: error)
        }
    }
    
    internal func setAuthTokenHeader(authToken: String? = nil) {
        let prefix = "Bearer "
        let token = authToken ??
            PassageTokenStore(appId: appId).authToken ??
            OpenAPIClientAPI.customHeaders["Authorization"]?.replacingOccurrences(of: prefix, with: "") ??
            ""
        OpenAPIClientAPI.customHeaders["Authorization"] = prefix + token
    }
    
}
