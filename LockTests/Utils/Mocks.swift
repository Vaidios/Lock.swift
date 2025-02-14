// Mocks.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import Auth0

@testable import Lock

class MockLockController: LockViewController {

    var presenting: UIViewController?
    var presented: UIViewController?
    var presentable: Presentable?

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        completion?()
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        completion?()
        self.presented = viewControllerToPresent
    }

    override func present(_ presentable: Presentable?, title: String?) {
        self.presentable = presentable
        self.headerView.title = title
    }

    override var presentingViewController: UIViewController? {
        return self.presenting
    }
}


class MockAuthPresenter: AuthPresenter {

    var authView = AuthCollectionView(connections: [], mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:])  { _ in }

    override func newViewToEmbed(withInsets insets: UIEdgeInsets, isLogin: Bool) -> AuthCollectionView {
        return self.authView
    }

}

class MockNavigator: Navigable {
    var route: Route?
    var resetted: Bool = false
    var presented: UIViewController? = nil
    var connections: Connections? = nil
    var unrecoverableError: Error? = nil
    var headerTitle: String? = "Auth0"
    var root: Presentable? = nil

    func navigate(_ route: Route) {
        self.route = route
    }

    func resetScroll(_ animated: Bool) {
        self.resetted = true
    }

    func scroll(toPosition: CGPoint, animated: Bool) {
    }


    func present(_ controller: UIViewController) {
        self.presented = controller
    }

    func reload(with connections: Connections) {
        self.connections = connections
    }

    func exit(withError error: Error) {
        self.unrecoverableError = error
    }

    func header(withTitle title: String, animated: Bool) {
        self.headerTitle = title
    }

    func onBack() -> () {
    }
}

func mockInput(_ type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockMessagePresenter: MessagePresenter {
    var message: String? = nil
    var error: LocalizableError? = nil

    func showSuccess(_ message: String) {
        self.message = message
    }

    func showError(_ error: LocalizableError) {
        self.error = error
    }

    func hideCurrent() {
        self.error = nil
        self.message = nil
    }
}

class MockInputField: InputField {
    var valid: Bool? = nil

    override func showError(_ error: String?, noDelay: Bool) {
        self.valid = false
    }

    override func showValid() {
        self.valid = true
    }
}

class MockMultifactorInteractor: MultifactorAuthenticatable {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var code: String? = nil

    var onLogin: () -> CredentialAuthError? = { return nil }

    func login(_ callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }

    func setMultifactorCode(_ code: String?) throws {
        guard code != "invalid" else { throw NSError(domain: "", code: 0, userInfo: nil) }
        self.code = code
    }
}

class MockAuthInteractor: OAuth2Authenticatable {
    func start(_ connection: String, loginHint: String? = nil, screenHint: String? = nil, useEphemeralSession: Bool = false, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
    }
}

class MockDBInteractor: DatabaseAuthenticatable, DatabaseUserCreator {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var identifier: String? = nil
    var email: String? = nil
    var password: String? = nil
    var username: String? = nil
    var custom: [String: String] = [:]

    var validEmail: Bool = false
    var validUsername: Bool = false

    var onLogin: () -> CredentialAuthError? = { return nil }
    var onSignUp: () -> DatabaseUserCreatorError? = { return nil }

    func login(_ callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }

    func create(_ callback: @escaping (DatabaseUserCreatorError?, CredentialAuthError?) -> ()) {
        callback(onSignUp(), onLogin())
    }

    func update(_ attribute: UserAttribute, value: String?) throws {
        guard value != "invalid" else {
            if case .email = attribute {
                self.validEmail = false
            }
            if case .username = attribute {
                self.validUsername = false
            }
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        switch attribute {
        case .email:
            self.email = value
        case .username:
            self.username = value
        case .password:
            self.password = value
        case .emailOrUsername:
            self.email = value
            self.username = value
        case .custom(let name, _):
            self.custom[name] = value
        }
    }
}

class MockConnectionsLoader: RemoteConnectionLoader {

    var connections: Connections? = nil
    var error: UnrecoverableError? = nil

    func load(_ callback: @escaping (UnrecoverableError?, Connections?) -> ()) {
        callback(error, connections)
    }
}

class MockAuthentication: Authentication {
    
    private var authentication: Authentication

    public var clientId: String

    public var url: URL

    var logger: Auth0.Logger?

    var telemetry: Telemetry

    var webAuth: MockWebAuth?
    
    var webAuthResult: () -> Swift.Result<Credentials, WebAuthError> = { return .failure(WebAuthError.unknown) }

    required init(clientId: String, domain: String) {
        self.authentication = Auth0.authentication(clientId: clientId, domain: domain)
        self.url = self.authentication.url
        self.clientId = self.authentication.clientId
        self.telemetry = self.authentication.telemetry
        self.webAuth = MockWebAuth()
    }

    func webAuth(withConnection connection: String) -> WebAuth {
        return webAuth!.connection(connection)
    }

    func tokenInfo(token: String) -> Request<UserInfo, AuthenticationError> {
        return self.authentication.userInfo(withAccessToken: token)
    }

    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError> {
        return self.authentication.resetPassword(email: email, connection: connection)
    }

    func userInfo(token: String) -> Request<UserInfo, AuthenticationError> {
        return self.authentication.userInfo(withAccessToken: token)
    }

    func tokenExchange(withParameters parameters: [String : Any]) -> Request<Credentials, AuthenticationError> {
        return self.authentication.codeExchange(withCode: "", codeVerifier: "", redirectURI: "")
    }

    func login(withOTP otp: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        return self.authentication.login(withOTP: otp, mfaToken: mfaToken)
    }

    func login(withOOBCode oobCode: String, mfaToken: String, bindingCode: String?) -> Request<Credentials, AuthenticationError> {
        return self.authentication.login(withOOBCode: oobCode, mfaToken: mfaToken, bindingCode: bindingCode)
    }

    func login(withRecoveryCode recoveryCode: String, mfaToken: String) -> Request<Credentials, AuthenticationError> {
        return self.authentication.login(withRecoveryCode: recoveryCode, mfaToken: mfaToken)
    }

    func multifactorChallenge(mfaToken: String, types: [String]?, channel: String?, authenticatorId: String?) -> Request<Challenge, AuthenticationError> {
        return self.authentication.multifactorChallenge(mfaToken: mfaToken, types: types, authenticatorId: authenticatorId)
    }

    func codeExchange(withCode code: String, codeVerifier: String, redirectURI: String) -> Request<Credentials, AuthenticationError> {
        return self.authentication.codeExchange(withCode: code, codeVerifier: codeVerifier, redirectURI: redirectURI)
    }

    func renew(withRefreshToken refreshToken: String) -> Request<Credentials, AuthenticationError> {
        return self.authentication.renew(withRefreshToken: refreshToken)
    }

    func login(usernameOrEmail username: String, password: String, multifactorCode: String?, connection: String, scope: String, parameters: [String : Any]) -> Request<Credentials, AuthenticationError> {
        return self.authentication.login(usernameOrEmail: username, password: password, realmOrConnection: "", scope: scope)
    }

    func revoke(refreshToken: String) -> Request<Void, AuthenticationError> {
        return self.authentication.revoke(refreshToken: refreshToken)
    }

    func userInfo(withAccessToken accessToken: String) -> Request<UserInfo, AuthenticationError> {
        return self.authentication.userInfo(withAccessToken: accessToken)
    }
    
    func jwks() -> Request<JWKS, AuthenticationError> {
        return self.authentication.jwks()
    }
    
}

import Combine

class MockWebAuth: WebAuth {
    func start(_ callback: @escaping (Auth0.WebAuthResult<Auth0.Credentials>) -> Void) {
        
    }
    
    func start() async throws -> Auth0.Credentials {
        return .init()
    }
    
    func start() -> AnyPublisher<Auth0.Credentials, Auth0.WebAuthError> {
        return Fail(error: Auth0.WebAuthError.unknown).eraseToAnyPublisher()
    }
    
    func provider(_ provider: @escaping Auth0.WebAuthProvider) -> Self {
        return self
    }
    
    func onClose(_ callback: (() -> Void)?) -> Self {
        return self
    }
    

    var clientId: String = "CLIENT_ID"
    var url: URL = URL(string: "google.com")!

    var connection: String? = nil
    var parameters: [String: String] = [:]
    var scope: String? = nil
    var audience: String? = nil
    var issuer: String? = nil
    var leeway: Int? = nil
    var maxAge: Int? = nil

    var result: () -> Swift.Result<Credentials, AuthenticationError> = { return .failure(AuthenticationError(info: [:], statusCode: 500)) }
    var telemetry: Telemetry = Telemetry()
    var logger: Auth0.Logger? = nil

    func connection(_ connection: String) -> Self {
        self.connection = connection
        return self
    }

    func useUniversalLink() -> Self {
        return self
    }
    
    func useEphemeralSession() -> Self {
        return self
    }

    func state(_ state: String) -> Self {
        return self
    }

    func connectionScope(_ connectionScope: String) -> Self {
        self.parameters["connection_scope"] = connectionScope
        return self
    }

    func parameters(_ parameters: [String : String]) -> Self {
        parameters.forEach { self.parameters[$0] = $1 }
        return self
    }

    func redirectURL(_ redirectURL: URL) -> Self {
        return self
    }

    func usingImplicitGrant() -> Self {
        return self
    }

    func scope(_ scope: String) -> Self {
        self.scope = scope
        return self
    }

    func start(_ callback: @escaping (Swift.Result<Credentials, AuthenticationError>) -> ()) {
        callback(self.result())
    }

    func nonce(_ nonce: String) -> Self {
        return self
    }

    func audience(_ audience: String) -> Self {
        self.audience = audience
        return self
    }

    func issuer(_ issuer: String) -> Self {
        self.issuer = issuer
        return self
    }

    func leeway(_ leeway: Int) -> Self {
        self.leeway = leeway
        return self
    }

    func maxAge(_ maxAge: Int) -> Self {
        self.maxAge = maxAge
        return self
    }
    
    func invitationURL(_ invitationURL: URL) -> Self {
       return self
   }
       
   func organization(_ organization: String) -> Self {
       return self
   }

    func clearSession(federated: Bool, callback: @escaping (Bool) -> Void) {
        callback(true)
    }

    func useLegacyAuthentication() -> Self {
        return self
    }
    
    func useLegacyAuthentication(withStyle style: UIModalPresentationStyle) -> Self {
        return self
    }
    
}

class MockOAuth2: OAuth2Authenticatable {

    var connection: String? = nil
    var onStart: () -> OAuth2AuthenticatableError? = { return nil }
    var parameters: [String: String] = [:]
    var useEphemeralSession: Bool = false

    func start(_ connection: String, loginHint: String? = nil, screenHint: String? = nil, useEphemeralSession: Bool = false, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
        self.connection = connection
        self.parameters["login_hint"] = loginHint
        self.parameters["screen_hint"] = screenHint
        self.useEphemeralSession = useEphemeralSession
        callback(self.onStart())
    }

}

class MockViewController: UIViewController {

    var presented: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.presented = viewControllerToPresent
    }

    override var presentedViewController: UIViewController? {
        return self.presented ?? super.presentedViewController
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        self.presented = nil
        completion?()
    }
}

//class MockNativeAuthHandler: AuthProvider {
//
//    var transaction: MockNativeAuthTransaction!
//    var authentication: Authentication!
//    static var validProvider: Bool = true
//
//    func login(withConnection connection: String, scope: String, parameters: [String : Any]) -> NativeAuthTransaction {
//        let transaction = MockNativeAuthTransaction(connection: connection, scope: scope, parameters: parameters, authentication: self.authentication)
//        self.transaction = transaction
//        return transaction
//    }
//
//    static func isAvailable() -> Bool {
//        return MockNativeAuthHandler.validProvider
//    }
//}

//class MockNativeAuthTransaction: NativeAuthTransaction {
//    var connection: String
//    var scope: String
//    var parameters: [String : Any]
//    var authentication: Authentication
//
//    init(connection: String, scope: String, parameters: [String: Any], authentication: Authentication) {
//        self.connection = connection
//        self.scope = scope
//        self.parameters = parameters
//        self.authentication = authentication
//    }
//
//    var delayed: NativeAuthTransaction.Callback = { _ in }
//
//    func auth(callback: @escaping NativeAuthTransaction.Callback) {
//        self.delayed = callback
//    }
//
//    func cancel() {
//      self.delayed(.failure(WebAuthError.userCancelled))
//        self.delayed = { _ in }
//    }
//
//    func resume(_ url: URL, options: [A0URLOptionsKey : Any]) -> Bool {
//        self.delayed(self.onNativeAuth())
//        self.delayed = { _ in }
//        return true
//    }
//
//    /// Test Hooks
//    var onNativeAuth: () -> Swift.Result<NativeAuthCredentials, Error> = {
//      return .success(NativeAuthCredentials(token: "SocialToken", extras: [:]))
//    }
//}

func mockCredentials() -> Credentials {
    return Credentials(accessToken: UUID().uuidString, tokenType: "Bearer")
}

class MockPasswordlessActivity: PasswordlessUserActivity {

    var messagePresenter: MessagePresenter?
    var onAuth: (String) -> Void = { _ in }
    var current: PasswordlessAuthTransaction?
    var code: String = "123456"

    func withMessagePresenter(_ messagePresenter: MessagePresenter?) -> Self {
        self.messagePresenter = messagePresenter
        return self
    }

    func continueAuth(withActivity userActivity: NSUserActivity) -> Bool {
        self.onAuth(code)
        self.current = nil
        return true
    }

    func store(_ transaction: PasswordlessAuthTransaction) {
        self.current = transaction
    }

}

class MockPasswordlessInteractor: PasswordlessAuthenticatable {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var identifier: String? = nil
    var validIdentifier: Bool = false
    var code: String? = nil
    var validCode: Bool = false
    var countryCode: CountryCode? 

    var onLogin: () -> CredentialAuthError? = { return nil }
    var onRequest: () -> PasswordlessAuthenticatableError? = { return nil }

    func update(_ type: InputField.InputType, value: String?) throws {
    }

    func request(_ connection: String, callback: @escaping (PasswordlessAuthenticatableError?) -> ()) {
        callback(onRequest())
    }

    func login(_ connection: String, callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }
}
