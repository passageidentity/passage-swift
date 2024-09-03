
final public class PassageCurrentUser {
    
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    public func userInfo() async throws -> CurrentUser {
        do {
            let response = try await CurrentuserAPI.getCurrentuser(appId: appId)
            return response.user
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func changeEmail(newEmail: String, language: String? = nil) async throws -> MagicLink {
        do {
            let request = UpdateUserEmailRequest(language: language, newEmail: newEmail)
            let response = try await CurrentuserAPI.updateEmailCurrentuser(appId: appId, updateUserEmailRequest: request)
            return response.magicLink
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func changePhone(newPhone: String, language: String? = nil) async throws -> MagicLink {
        do {
            let request = UpdateUserPhoneRequest(language: language, newPhone: newPhone)
            let response = try await CurrentuserAPI.updatePhoneCurrentuser(appId: appId, updateUserPhoneRequest: request)
            return response.magicLink
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    // MARK: - PASSKEY METHODS
    
    public func passkeys() async throws -> [Passkey] {
        do {
            let response = try await CurrentuserAPI.getCurrentuserDevices(appId: appId)
            return response.devices
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func editPasskey(passkeyId: String, newFriendlyName: String) async throws -> Passkey {
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
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    @available(iOS 16.0, macOS 12.0, tvOS 16.0, visionOS 1.0, *)
    public func addPasskey(options: PasskeyCreationOptions? = nil) async throws -> AuthResult {
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
            let includeSecurityKeyOption = authenticatorAttachment == .any || authenticatorAttachment == .crossPlatform
            // Use the Registration Start Handshake to prompt the app user to create a passkey
            let registerResponse = RegisterWebAuthnStartResponse(
                handshake: startResponse.handshake,
                user: startResponse.user
            )
            let registrationRequest = try PasskeyRegistrationRequest.from(registerResponse)
            let authController = PasskeyAuthorizationController()
            let credential = try await authController.requestPasskeyRegistration(
                registrationRequest: registrationRequest,
                includeSecurityKeyOption: options?.authenticatorAttachment == .crossPlatform
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
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func deletePasskey(passkeyId: String) async throws {
        do {
            try await CurrentuserAPI.deleteCurrentuserDevice(appId: appId, deviceId: passkeyId)
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    // MARK: - SOCIAL METHODS
    
    public func socialConnections() async throws -> UserSocialConnections {
        do {
            let response = try await CurrentuserAPI.getCurrentuserSocialConnections(appId: appId)
            return response.socialConnections
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func deleteSocialConnection(socialConnectionType: SocialConnection) async throws {
        do {
            try await CurrentuserAPI.deleteCurrentuserSocialConnection(
                appId: appId,
                socialConnectionType: socialConnectionType
            )
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func metadata() async throws -> Metadata {
        do {
            let response = try await CurrentuserAPI.getCurrentuserMetadata(appId: appId)
            return response.userMetadata
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
    public func updateMetadata(newMetaData: Metadata) async throws -> CurrentUser {
        do {
            let request = UpdateMetadataRequest(userMetadata: newMetaData)
            let response = try await CurrentuserAPI.updateCurrentuserMetadata(appId: appId, updateMetadataRequest: request)
            return response.user
        } catch {
            throw PassageAppError.unspecified(message: "") // TODO: Replace
        }
    }
    
}
