import AuthenticationServices
#if os(iOS)
import SafariServices

final internal class HostedAuthorizationController: NSObject {
    
    // MARK: - INSTANCE PROPERTIES
    
    private var appId: String
    private var authOrigin: String
    private var bundleId: String
    internal private(set) var verifier = ""
    private var clientState = ""
    private var safariViewController: SFSafariViewController?
    private var webAuthSession: ASWebAuthenticationSession?
    private var hostedContinuation: CheckedContinuation<String, Error>?
    private var hostedLogoutContinuation: CheckedContinuation<Void, Error>?
    private lazy var callbackUrlString: String = {
        return "\(authOrigin)/ios/\(bundleId)/callback"
    }()
    private lazy var logoutUrlString: String = {
        return "\(authOrigin)/ios/\(bundleId)/logout"
    }()
    
    // MARK: - INITIALIZERS
    
    internal init(appId: String, authOrigin: String) throws {
        self.appId = appId
        self.authOrigin = authOrigin
        guard let bundleId = Bundle.main.bundleIdentifier else {
            throw HostedAuthorizationError.cannotAccessAppBundleId()
        }
        self.bundleId = bundleId
    }
    
    // MARK: - INTERNAL INSTANCE METHODS
    
    @MainActor
    @available(iOS 17.4, macOS 14.4, *)
    func startWebAuth() async throws -> String {
        let url = try getHostedStartUrl()
        guard
            let callbackUrl = URL(string: callbackUrlString),
            let host = callbackUrl.host()
        else {
            throw HostedAuthorizationError.invalidHostedCallbackUrl()
        }
        let callback = ASWebAuthenticationSession
            .Callback
            .https(
                host: host,
                path: callbackUrl.path()
            )
        return try await withCheckedThrowingContinuation { continuation in
            webAuthSession = ASWebAuthenticationSession(
                url: url,
                callback: callback
            ) { [weak self] callbackURL, error in
                guard error == nil else {
                    if let authError = error as? ASWebAuthenticationSessionError,
                       authError.code == .canceledLogin {
                        continuation.resume(throwing: HostedAuthorizationError.canceled())
                    } else {
                        continuation.resume(throwing: error!)
                    }
                    return
                }
                guard
                    let self,
                    let callbackURL,
                    let code = try? self.handleCallbackUrl(callbackUrl: callbackURL)
                else {
                    continuation.resume(throwing: HostedAuthorizationError.invalidHostedCallbackUrl())
                    return
                }
                continuation.resume(returning: code)
            }
            webAuthSession?.presentationContextProvider = self
            webAuthSession?.start()
        }
    }
    
    @MainActor
    internal func startWebAuthSafari() async throws -> String {
        let url = try getHostedStartUrl()
        safariViewController = SFSafariViewController(url: url)
        let window = getAnchor()
        guard
            let safariViewController,
            let appViewController = window.rootViewController
        else {
            throw HostedAuthorizationError.cannotAccessAppRootViewController()
        }
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .pageSheet
        appViewController.present(safariViewController, animated: true)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.hostedContinuation = continuation
        }
    }
    
    internal func finishWebAuth(authCode: String) async throws -> (AuthResult, String) {
        let url = try getHostedFinishUrl(authCode: authCode)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HostedAuthorizationError.serverError(message: response.description)
        }
        switch httpResponse.statusCode {
        case 400: throw HostedAuthorizationError.invalidHostedTokenUrl()
        case 401: throw HostedAuthorizationError.unauthorized(message: response.description)
        case 500: throw HostedAuthorizationError.serverError(message: response.description)
        default: ()
        }
        let decoder = JSONDecoder()
        guard let result = try? decoder.decode(HostedAuthResult.self, from: data) else {
            throw HostedAuthorizationError.invalidHostedTokenUrl()
        }
        let authResult = AuthResult(
            authToken: result.accessToken,
            redirectUrl: "",
            refreshToken: result.refreshToken,
            refreshTokenExpiration: nil
        )
        return (authResult, result.idToken)
    }
    
    @MainActor
    @available(iOS 17.4, macOS 14.4, *)
    internal func logout(idToken: String) async throws {
        let url = try getLogoutUrl(idToken: idToken)
        guard
            let logoutUrl = URL(string: logoutUrlString),
            let host = logoutUrl.host()
        else {
            throw HostedAuthorizationError.invalidHostedLogoutUrl()
        }
        let callback = ASWebAuthenticationSession
            .Callback
            .https(
                host: host,
                path: logoutUrl.path()
            )
        return try await withCheckedThrowingContinuation { continuation in
            webAuthSession = ASWebAuthenticationSession(
                url: url,
                callback: callback
            ) { [weak self] callbackURL, error in
                guard error == nil else {
                    if let authError = error as? ASWebAuthenticationSessionError,
                       authError.code == .canceledLogin {
                        continuation.resume(throwing: HostedAuthorizationError.canceled())
                    } else {
                        continuation.resume(throwing: error!)
                    }
                    return
                }
                guard
                    let callbackURL,
                    callbackURL.absoluteString.contains(self?.logoutUrlString ?? "")
                else {
                    continuation.resume(throwing: HostedAuthorizationError.invalidHostedLogoutUrl())
                    return
                }
                continuation.resume(returning: ())
            }
            webAuthSession?.presentationContextProvider = self
            webAuthSession?.prefersEphemeralWebBrowserSession = false
            webAuthSession?.start()
        }
    }
    
    @MainActor
    internal func logoutSafari(idToken: String) async throws {
        let url = try getLogoutUrl(idToken: idToken)
        let window = getAnchor()
        safariViewController = SFSafariViewController(url: url)
        guard let safariViewController else {
            throw HostedAuthorizationError.cannotAccessAppRootViewController()
        }
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .pageSheet
        window.rootViewController?.present(safariViewController, animated: true)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.hostedLogoutContinuation = continuation
        }
    }
    
    // MARK: - INTERNAL INSTANCE METHODS

    internal func getHostedStartUrl() throws -> URL {
        let baseUrl = "\(authOrigin)/authorize?"
        clientState = WebAuthenticationUtils.getRandomString(length: 32)
        verifier = WebAuthenticationUtils.getRandomString(length: 32)
        let codeChallenge = WebAuthenticationUtils.sha256Hash(verifier)
        let codeChallengeMethod = "S256"
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = [
            URLQueryItem(name: "redirect_uri", value: callbackUrlString),
            URLQueryItem(name: "state", value: clientState),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: codeChallengeMethod),
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "scope", value: "openid"),
            URLQueryItem(name: "response_type", value: "code")
        ]
        guard let url = urlComponents?.url else {
            throw HostedAuthorizationError.invalidHostedAuthUrl()
        }
        return url
    }
    
    internal func getHostedFinishUrl(authCode: String) throws -> URL {
        let urlString = "\(authOrigin)/token"
        guard var urlComponents = URLComponents(string: urlString) else {
            throw HostedAuthorizationError.invalidHostedTokenUrl()
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "code_verifier", value: verifier),
            URLQueryItem(name: "redirect_uri", value: callbackUrlString)
        ]
        guard let url = urlComponents.url else {
            throw HostedAuthorizationError.invalidHostedTokenUrl()
        }
        return url
    }
    
    internal func getLogoutUrl(idToken: String) throws -> URL {
        let urlString = "\(authOrigin)/logout"
        guard var urlComponents = URLComponents(string: urlString) else {
            throw HostedAuthorizationError.invalidHostedLogoutUrl()
        }
        clientState = WebAuthenticationUtils.getRandomString(length: 32)
        urlComponents.queryItems = [
            URLQueryItem(name: "id_token_hint", value: idToken),
            URLQueryItem(name: "client_id", value: appId),
            URLQueryItem(name: "state", value: clientState),
            URLQueryItem(name: "post_logout_redirect_uri", value: logoutUrlString)
        ]
        guard let url = urlComponents.url else {
            throw HostedAuthorizationError.invalidHostedLogoutUrl()
        }
        return url
    }
    
    private func handleCallbackUrl(callbackUrl: URL) throws -> String {
        guard
            let components = NSURLComponents(url: callbackUrl, resolvingAgainstBaseURL: true),
            let code = components.queryItems?.filter({$0.name == "code"}).first?.value,
            let state = components.queryItems?.filter({$0.name == "state"}).first?.value,
            state == clientState
        else {
            throw HostedAuthorizationError.invalidHostedCallbackUrl()
        }
        return code
    }
    
    @MainActor
    private func getAnchor() -> ASPresentationAnchor {
        return UIApplication.shared.windows.last(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
    
}

extension HostedAuthorizationController:
    ASWebAuthenticationPresentationContextProviding,
    SFSafariViewControllerDelegate {
    
    // MARK: - SFSafariViewControllerDelegate METHODS
    
    internal func safariViewController(
        _ controller: SFSafariViewController,
        initialLoadDidRedirectTo url: URL
    ) {
        if url.absoluteString.contains(callbackUrlString) {
            do {
                let code = try handleCallbackUrl(callbackUrl: url)
                hostedContinuation?.resume(returning: code)
            } catch {
                hostedLogoutContinuation?
                    .resume(throwing: HostedAuthorizationError.invalidHostedLogoutUrl())
            }
            controller.dismiss(animated: true, completion: nil)
        } else if url.absoluteString.contains(logoutUrlString) {
            hostedLogoutContinuation?.resume(returning: ())
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding METHODS
    
    @MainActor
    internal func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return getAnchor()
    }
    
}
#endif
