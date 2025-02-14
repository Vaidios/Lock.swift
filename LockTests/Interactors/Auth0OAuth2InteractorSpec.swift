// Auth0OAuth2InteractorSpec.swift
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

import Quick
import Nimble
import Auth0
import OHHTTPStubs
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif

@testable import Lock

private let DomainURL = URL(fileURLWithPath: domain)
private let Timeout = NimbleTimeInterval.seconds(2)
private let AccessToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
private let IdToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
private let FacebookToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")

class Auth0OAuth2InteractorSpec: QuickSpec {

    override class func spec() {

        let authentication = MockAuthentication(clientId: clientId, domain: domain)

        var options: LockOptions!
        var credentials: Credentials?
        var nativeHandlers: [String: AuthProvider] = [:]
//        var authHandler: MockNativeAuthHandler!
        var interactor: OAuth2Authenticatable!
        var dispatcher: ObserverStore!

        beforeEach {
            credentials = nil
            options = LockOptions()
//            authHandler = MockNativeAuthHandler()
//            authHandler.authentication = authentication
            dispatcher = ObserverStore()
            dispatcher.onAuth = { credentials = $0 }
//            interactor = Auth0OAuth2Interactor(authentication: authentication, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
        }

        afterEach {
            Auth0Stubs.cleanAll()
        }

//        describe("web auth login") {
//
//            var error: OAuth2AuthenticatableError?
//
//            beforeEach {
//                error = nil
//            }
//
//            it("should set connection") {
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.connection) == "facebook"
//            }
//
//            it("should set scope") {
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.scope) == "openid"
//            }
//
//            it("should set connection scope for specified connection") {
//                options.connectionScope = ["facebook": "user_friends,email"]
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.parameters["connection_scope"]) == "user_friends,email"
//            }
//
//            it("should set connection scope for matching connections only") {
//                options.connectionScope = ["facebook": "user_friends,email",
//                                           "google-oauth2": "gmail,ads"]
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.parameters["connection_scope"]) == "user_friends,email"
//                interactor.start("google-oauth2", loginHint: nil, screenHint: nil,  useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.parameters["connection_scope"]) == "gmail,ads"
//            }
//
//            it("should not set audience if nil") {
//                options.audience = nil
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.audience).to(beNil())
//            }
//
//            it("should set audience") {
//                options.audience = "https://myapi.com/v1"
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.audience) == "https://myapi.com/v1"
//            }
//
//            it("should set leeway") {
//                options.leeway = 1000
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.leeway) == 1000
//            }
//
//            it("should set maxAge") {
//                options.maxAge = 1000
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.maxAge) == 1000
//            }
//
//            it("should set parameters") {
//                let state = UUID().uuidString
//                options.parameters = ["state": state as Any]
//                interactor = Auth0OAuth2Interactor(authentication: authentication, webAuth: authentication.webAuth!, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                expect(authentication.webAuth?.parameters["state"]) == state
//            }
//
//            it("should not yield error on success") {
//              authentication.webAuthResult = { return .success(mockCredentials()) }
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error = $0 }
//                expect(error).toEventually(beNil())
//            }
//
//            it("should call credentials callback") {
//                let expected = mockCredentials()
//              authentication.webAuthResult = { return .success(expected) }
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error = $0 }
//                expect(credentials).toEventually(equal(expected))
//            }
//
//            it("should handle cancel error") {
//              authentication.webAuthResult = { return .failure(WebAuthError.userCancelled) }
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error = $0 }
//                expect(error).toEventually(equal(OAuth2AuthenticatableError.cancelled))
//            }
//
//            it("should handle generic error") {
//                authentication.webAuthResult = { return .failure(WebAuthError.noBundleIdentifier) }
//                interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error = $0 }
//                expect(error).toEventually(equal(OAuth2AuthenticatableError.couldNotAuthenticate))
//            }
//
//        }

//        describe("native auth login") {
//
//            beforeEach {
//                nativeHandlers.removeAll()
////                nativeHandlers["facebook"] = authHandler
////                interactor = Auth0OAuth2Interactor(authentication: authentication, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//            }
//
//            afterEach {
//                _ = Auth0.resumeAuth(DomainURL, options: [:])
//            }
//
//            it("should yield no error on success") {
//                stub(condition: isOAuthAccessToken(domain) && hasAtLeast(["access_token": "SocialToken", "connection": "facebook"])) { _ in return Auth0Stubs.authentication() }.name = "Social Auth"
//                waitUntil(timeout: Timeout) { done in
//                    interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error in
//                        expect(error).to(beNil())
//                        done()
//                    }
////                    _ = authHandler.transaction.resume(DomainURL, options: [:])
//                }
//            }
//
//            it("should yield error on failure") {
//                stub(condition: isOAuthAccessToken(domain) && hasAtLeast(["access_token": "SocialToken", "connection": "facebook"])) { _ in return Auth0Stubs.failure() }.name = "Social Auth Fail"
//                waitUntil(timeout: Timeout) { done in
//                    interactor.start("facebook", loginHint: nil, screenHint: nil, useEphemeralSession: false) { error in
//                        expect(error).toNot(beNil())
//                        done()
//                    }
//                    _ = authHandler.transaction.resume(DomainURL, options: [:])
//                }
//            }
//
//            context("native provider unavailable") {
//
//                beforeEach {
//                    MockNativeAuthHandler.validProvider = false
//                    authentication.webAuth = nil
//                    nativeHandlers.removeAll()
//                    nativeHandlers["twitter"] = authHandler
//                    interactor = Auth0OAuth2Interactor(authentication: authentication, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
//                }
//                
//                it("should fallback to webAuth with connection") {
//                    interactor.start("twitter", loginHint: nil, screenHint: nil, useEphemeralSession: false, callback: { _ in })
//                    expect(authentication.webAuth?.connection) == "twitter"
//                }
//                
//            }
//            
//        }
    }
}

