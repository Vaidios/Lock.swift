// PasswordPolicySpec.swift
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

@testable import Lock

let aValidPassword = "valid password"
let anInvalidPassword = "invalid password"
let passwordKey = "password"
let policyKey = "policy"

class PasswordPolicySpec: QuickSpec {

    override class func spec() {

        describe("none") {
            let policy = PasswordPolicy.none()

            ["1", "a random password", "with 1 number", "bad", "password", "a very strong password with more than 10 chars."].forEach { password in
                it("is a valid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                }
            }

            ["", nil].forEach { password in
                it("is an invalid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                }
            }

            context("custom password complexity") {

                let policy = PasswordPolicy.none(withOptions: ["min_length": 4])

                ["1234", "a random password", "with 1 number", "bad1", "password", "a very strong password with more than 10 chars."].forEach { password in
                    it("is a valid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                    }
                }

                ["bad", nil].forEach { password in
                    it("is an invalid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                    }
                }

            }

        }

        describe("low") {
            let policy = PasswordPolicy.low()

            ["123456", "a random password", "password", "a very strong password with more than 10 chars."].forEach { password in
                it("is a valid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                }
            }

            ["", nil, "short", "bad"].forEach { password in
                it("is an invalid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                }
            }

            context("custom password complexity") {

                let policy = PasswordPolicy.low(withOptions: ["min_length": 3])

                ["1234", "a random password", "with 1 number", "bad1", "password", "a very strong password with more than 10 chars."].forEach { password in
                    it("is a valid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                    }
                }

                ["ba", nil].forEach { password in
                    it("is an invalid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                    }
                }

            }

        }

        describe("fair") {
            let policy = PasswordPolicy.fair()

            ["1ValidPassword", "A very strong password with more than 10 chars.", "ONEtwo34"].forEach { password in
                it("is a valid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                }
            }

            ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase", "MISSING 1 LOWERCASE", "missing A digit"].forEach { password in
                it("is an invalid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                }
            }

            context("custom password complexity") {

                let policy = PasswordPolicy.fair(withOptions: ["min_length": 10])

                ["1ValidPassword", "A very strong password with more than 10 chars.", "ONEtwo34fivesix"].forEach { password in
                    it("is a valid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                    }
                }

                ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase", "MISSING 1 LOWERCASE", "missing A digit"].forEach { password in
                    it("is an invalid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                    }
                }

            }

        }

        describe("good") {
            let policy = PasswordPolicy.good()

            ["1ValidPassword", "ValidPassword!", "A very strong password with more than 10 chars.", "ONEtwo3&", "password1*", "PASSWORD2_"].forEach { password in
                it("is a valid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                }
            }

            ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase or symbol", "MISSING 1 LOWERCASE OR SYMBOL", "missing A digit or symbol", "1234567890+_)*^"].forEach { password in
                it("is an invalid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                }
            }

            context("custom password complexity") {

                let policy = PasswordPolicy.good(withOptions: ["min_length": 12])

                ["1ValidPassword", "A very strong password with more than 10 chars.", "ONEtwo34fivesix"].forEach { password in
                    it("is a valid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                    }
                }

                ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase", "MISSING 1 LOWERCASE", "missing A digit"].forEach { password in
                    it("is an invalid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                    }
                }

            }

        }

        describe("excellent") {
            let policy = PasswordPolicy.excellent() 

            ["1ValidPassword", "ValidPassword!", "A very strong password with more than 10 chars.", "ONEtwo3&()", "password1*", "PASSWORD2_"].forEach { password in
                it("is a valid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                }
            }

            ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase or symbol", "MISSING 1 LOWERCASE OR SYMBOL", "missing A digit or symbol", "1234567890+_)*^", "multipleAAA"].forEach { password in
                it("is an invalid password") {
                    expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                }
            }

            context("custom password complexity") {

                let policy = PasswordPolicy.excellent(withOptions: ["min_length": 15])

                ["1ValidPasswordformeislong", "A very strong password with more than 10 chars.", "ONEtwo34fivesixnine"].forEach { password in
                    it("is a valid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: true, forPassword: password))
                    }
                }

                ["", nil, "short", "bad", "only lowercase letters", "ONLY UPPERCASE LETTERS", "123456789", "missing 1 uppercase", "MISSING 1 LOWERCASE", "missing A digit"].forEach { password in
                    it("is an invalid password") {
                        expect(policy.on(password)).to(beRuleResult(valid: false, forPassword: password))
                    }
                }

            }

        }

    }
}

func beRuleResult(valid: Bool, forPassword password: String?) -> Predicate<[RuleResult]> {
    return Predicate<[RuleResult]>.define("be a rule result of password <\(String(describing: password))> valid <\(valid)>") { expression, failureMessage -> MatcherResult in
        if let actual = try expression.evaluate() {
            if actual.reduce(true, {$0 && $1.valid}) == valid {
                return MatcherResult(status: .matches, message: failureMessage)
            }
        }
        return MatcherResult(status: .doesNotMatch, message: failureMessage)
    }
}
