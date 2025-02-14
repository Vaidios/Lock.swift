// LockSpec.swift
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
import Quick
import Nimble
import Auth0

@testable import Lock

class LockSpec: QuickSpec {

    override class func spec() {

        var lock: Lock!
        var authentication: Authentication!
        var webAuth: WebAuth!

        describe("init") {

            it("should init clasic mode") {
                lock = Lock.classic(clientId: clientId, domain: domain)
                expect(lock.classicMode) == true
            }

            it("should init passwordless mode") {
                lock = Lock.passwordless(clientId: clientId, domain: domain)
                expect(lock.classicMode) == false
            }
        }

        beforeEach {
            authentication = Auth0.authentication(clientId: clientId, domain: domain)
            webAuth = MockWebAuth()
            lock = Lock(authentication: authentication, webAuth: webAuth)
        }

        describe("options") {

            it("should allow settings options") {
                _ = lock.withOptions { $0.closable = true }
                expect(lock.options.closable) == true
            }

            it("should have defaults if never called") {
                expect(lock.options.closable) == false
            }

            it("should use the latest options") {
                _ = lock.withOptions { $0.closable = true }
                _ = lock.withOptions { $0.closable = false }
                expect(lock.options.closable) == false
            }

            it("should return itself") {
                expect(lock.withOptions { _ in } ) == lock
            }
            
            context("loggable") {
                
                it("should be disabled by default") {
                    expect(lock.authentication.logger).to(beNil())
                    expect(lock.webAuth.logger).to(beNil())
                }
                
                it("should enable logging") {
                    _ = lock.withOptions { $0.logHttpRequest = true }
                    expect(lock.authentication.logger).toNot(beNil())
                    expect(lock.webAuth.logger).toNot(beNil())
                }
                
            }
        }

        describe("withConnections") {

            it("should allow settings connections") {
                _ = lock.withConnections { $0.database(name: "MyDB", requiresUsername: false) }
                expect(lock.connections.database?.name) == "MyDB"
            }

            it("should have defaults if never called") {
                expect(lock.connections.database).to(beNil())
            }

            it("should use the latest options") {
                _ = lock.withConnections { $0.database(name: "MyDB", requiresUsername: false) }
                _ = lock.withConnections { $0.database(name: "AnotherDB", requiresUsername: false) }
                expect(lock.connections.database?.name) == "AnotherDB"
            }

            it("should return itself") {
                expect(lock.withConnections { _ in } ) == lock
            }

        }

        describe("present") {

            var controller: MockViewController!

            beforeEach {
                controller = MockViewController()
            }

            it("should present lock viewcontroller") {
                lock.present(from: controller)
                expect(controller.presented).notTo(beNil())
            }

            it("should fail if options are invalid") {
                _ = lock.withOptions { $0.allow = [] }
                waitUntil { done in
                    lock
                        .onError { _ in
                            done()
                        }
                        .present(from: controller)
                }
            }
        }

        describe("onAction") {

            it("should register onAuth callback") {
                var credentials: Credentials? = nil
                let callback: (Credentials) -> () = { credentials = $0 }
                let _ = lock.onAuth(callback: callback)
                lock.observerStore.onAuth(mockCredentials())
                expect(credentials).toNot(beNil())
            }

            it("should register onError callback") {
                var error: Error? = nil
                let callback: (Error) -> () = { error = $0 }
                let _ = lock.onError(callback: callback)
                lock.observerStore.onFailure(NSError(domain: "com.auth0", code: 0, userInfo: [:]))
                expect(error).toNot(beNil())
            }

            it("should register onSignUp callback") {
                var email: String? = nil
                var attributes: [String: Any]? = nil
                let callback: (String, [String: Any]) -> () = { email = $0; attributes = $1 }
                let _ = lock.onSignUp(callback: callback)
                lock.observerStore.onSignUp("mail@mail.com", [:])
                expect(email).toNot(beNil())
                expect(attributes).toNot(beNil())
            }

            it("should register onCancel callback") {
                var executed = false
                let callback: () -> () = { executed = true }
                let _ = lock.onCancel(callback: callback)
                lock.observerStore.onCancel()
                expect(executed) == true
            }

            it("should register onForgotPassword callback") {
                var email: String? = nil
                let callback: (String) -> () = { email = $0 }
                let _ = lock.onForgotPassword(callback: callback)
                lock.observerStore.onForgotPassword("mail@mail.com")
                expect(email) == "mail@mail.com"
            }

            it("should register onPasswordless callback") {
                var email: String? = nil
                let callback: (String) -> () = { email = $0 }
                let _ = lock.onPasswordless(callback: callback)
                lock.observerStore.onPasswordless("mail@mail.com")
                expect(email) == "mail@mail.com"
            }

        }

//
//        describe("native handler") {
//
//            it("should regsiter native handler") {
//                let nativeHandler = MockNativeAuthHandler()
//                let name = "facebook"
//                _ = lock.nativeAuthentication(forConnection: name, handler: nativeHandler)
//                expect(lock.nativeHandlers[name]).toNot(beNil())
//            }
//
//            it("should regsiter native handler to multiple connections") {
//                let nativeHandler = MockNativeAuthHandler()
//                _ = lock.nativeAuthentication(forConnection: "facebook", handler: nativeHandler)
//                _ = lock.nativeAuthentication(forConnection: "facebookcorp", handler: nativeHandler)
//                expect(lock.nativeHandlers["facebook"]).toNot(beNil())
//                expect(lock.nativeHandlers["facebookcorp"]).toNot(beNil())
//            }
//
//        }

        describe("style") {

            beforeEach {
                _ = lock.withStyle {
                    $0.title = "Test Title"
                    $0.primaryColor = UIColor.green
                    $0.logo = UIImage(named: "ic_auth0", in: Lock.bundle)
                }
            }

            it("title should be match custom title") {
                expect(lock.style.title).to(equal("Test Title"))
            }
            
            it("primary color should be match custom color") {
                expect(lock.style.primaryColor).to(equal(UIColor.green))
            }
            
            it("logo should be match custom UIImage") {
                expect(lock.style.logo).to(equal(UIImage(named: "ic_auth0", in: Lock.bundle)))
            }
            
        }
        
        it("should allow to continue activity") {
            expect(Lock.continueAuth(using: NSUserActivity(activityType: "test"))) == false
        }
        
    }
}



