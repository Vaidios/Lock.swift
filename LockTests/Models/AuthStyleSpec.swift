// AuthStyleSpec.swift
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

import UIKit
import Quick
import Nimble

@testable import Lock

private let NameKey = "name"
private let IconKey = "icon_name"
private let StyleKey = "style"

private let FirstClassStyleExample = "style"

func forStyle(_ style: AuthStyle, name: String, iconName: String) -> [String: Any] {
    return [
        StyleKey: style,
        NameKey: name,
        IconKey: iconName
    ]
}

class AuthStyleSpecSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: QCKConfiguration) {
        sharedExamples(FirstClassStyleExample) { (context: SharedExampleContext) in

            let style = context()[StyleKey] as! AuthStyle
            let name = context()[NameKey] as! String
            let iconName = context()[IconKey] as! String

            describe("for \(name.lowercased())") {
                it("should have correct name") {
                    expect(style.name) == name
                }

                it("should have a color") {
                    expect(style.normalColor) != UIColor.a0_orange
                }

                it("should have icon") {
                    expect(style.image) == UIImage(named: iconName, in: Lock.bundle)
                }
            }
        }
    }
}

class AuthStyleSpec: QuickSpec {

    override class func spec() {

        describe("init") {
            let strategy = AuthStyle(name: "a name")

            it("should build with a name") {
                expect(strategy.name) == "a name"
            }

            it("should have default image") {
                expect(strategy.image) == UIImage(named: "ic_auth_auth0", in: Lock.bundle)
            }

            it("should have default color") {
                expect(strategy.normalColor) == UIColor.a0_orange
            }

            it("should have default highligted color") {
                expect(strategy.highlightedColor) == UIColor.a0_orange.a0_darker(0.3)
            }

            it("should have default foreground color") {
                expect(strategy.foregroundColor) == UIColor.white
            }

            it("should not have default border color") {
                expect(strategy.borderColor).to(beNil())
            }

        }

        describe("titles") {

            it("should provide login title") {
                let strategy = AuthStyle(name: "facebook")
                expect(strategy.localizedLoginTitle) == "Sign in with facebook"
            }

            it("should provide signup title") {
                let strategy = AuthStyle(name: "facebook")
                expect(strategy.localizedSignUpTitle) == "Sign up with facebook"
            }

        }

        describe("first class connections") {

            [
                forStyle(.Amazon, name: "Amazon", iconName: "ic_auth_amazon"),
                forStyle(.Aol, name: "AOL", iconName: "ic_auth_aol"),
                forStyle(.Apple, name: "Apple", iconName: "ic_auth_apple"),
                forStyle(.Baidu, name: "百度", iconName: "ic_auth_baidu"),
                forStyle(.Bitbucket, name: "Bitbucket", iconName: "ic_auth_bitbucket"),
                forStyle(.Dropbox, name: "Dropbox", iconName: "ic_auth_dropbox"),
                forStyle(.Dwolla, name: "Dwolla", iconName: "ic_auth_dwolla"),
                forStyle(.Ebay, name: "Ebay", iconName: "ic_auth_ebay"),
                forStyle(.Evernote, name: "Evernote", iconName: "ic_auth_evernote"),
                forStyle(.EvernoteSandbox, name: "Evernote (sandbox)", iconName: "ic_auth_evernote"),
                forStyle(.Exact, name: "Exact", iconName: "ic_auth_exact"),
                forStyle(.Facebook, name: "Facebook", iconName: "ic_auth_facebook"),
                forStyle(.Fitbit, name: "Fitbit", iconName: "ic_auth_fitbit"),
                forStyle(.Github, name: "GitHub", iconName: "ic_auth_github"),
                forStyle(.Google, name: "Google", iconName: "ic_auth_google"),
                forStyle(.Instagram, name: "Instagram", iconName: "ic_auth_instagram"),
                forStyle(.Linkedin, name: "LinkedIn", iconName: "ic_auth_linkedin"),
                forStyle(.Miicard, name: "miiCard", iconName: "ic_auth_miicard"),
                forStyle(.Paypal, name: "PayPal", iconName: "ic_auth_paypal"),
                forStyle(.PaypalSandbox, name: "PayPal (sandbox)", iconName: "ic_auth_paypal"),
                forStyle(.PlanningCenter, name: "Planning Center", iconName: "ic_auth_planningcenter"),
                forStyle(.RenRen, name: "人人", iconName: "ic_auth_renren"),
                forStyle(.Salesforce, name: "Salesforce", iconName: "ic_auth_salesforce"),
                forStyle(.SalesforceCommunity, name: "Salesforce Community", iconName: "ic_auth_salesforce"),
                forStyle(.SalesforceSandbox, name: "Salesforce (sandbox)", iconName: "ic_auth_salesforce"),
                forStyle(.Shopify, name: "Shopify", iconName: "ic_auth_shopify"),
                forStyle(.Soundcloud, name: "SoundCloud", iconName: "ic_auth_soundcloud"),
                forStyle(.TheCity, name: "The City", iconName: "ic_auth_thecity"),
                forStyle(.TheCitySandbox, name: "The City (sandbox)", iconName: "ic_auth_thecity"),
                forStyle(.ThirtySevenSignals, name: "Basecamp", iconName: "ic_auth_thirtysevensignals"),
                forStyle(.Twitter, name: "Twitter", iconName: "ic_auth_twitter"),
                forStyle(.Vkontakte, name: "VKontakte", iconName: "ic_auth_vk"),
                forStyle(.Microsoft, name: "Microsoft Account", iconName: "ic_auth_microsoft"),
                forStyle(.Wordpress, name: "WordPress", iconName: "ic_auth_wordpress"),
                forStyle(.Yahoo, name: "Yahoo!", iconName: "ic_auth_yahoo"),
                forStyle(.Yammer, name: "Yammer", iconName: "ic_auth_yammer"),
                forStyle(.Yandex, name: "Yandex", iconName: "ic_auth_yandex"),
                forStyle(.Weibo, name: "新浪微博", iconName: "ic_auth_weibo"),
                ].forEach { style in
                    itBehavesLike(FirstClassStyleExample) { return style }
                }
        }

        describe("style for strategy") {

            it("should default to auth0 style") {
                let style = AuthStyle.style(forStrategy: "random", connectionName: "connection")
                expect(style.name) == "connection"
                expect(style.normalColor) == UIColor.a0_orange
            }

            [
                ("ad", AuthStyle.Microsoft),
                ("adfs", AuthStyle.Microsoft),
                ("amazon", AuthStyle.Amazon),
                ("aol", AuthStyle.Aol),
                ("apple", AuthStyle.Apple),
                ("baidu", AuthStyle.Baidu),
                ("bitbucket", AuthStyle.Bitbucket),
                ("dropbox", AuthStyle.Dropbox),
                ("dwolla", AuthStyle.Dwolla),
                ("ebay", AuthStyle.Ebay),
                ("evernote", AuthStyle.Evernote),
                ("evernote-sandbox", AuthStyle.EvernoteSandbox),
                ("exact", AuthStyle.Exact),
                ("facebook", AuthStyle.Facebook),
                ("fitbit", AuthStyle.Fitbit),
                ("github", AuthStyle.Github),
                ("google-oauth2", AuthStyle.Google),
                ("instagram", AuthStyle.Instagram),
                ("linkedin", AuthStyle.Linkedin),
                ("miicard", AuthStyle.Miicard),
                ("paypal", AuthStyle.Paypal),
                ("paypal-sandbox", AuthStyle.PaypalSandbox),
                ("planningcenter", AuthStyle.PlanningCenter),
                ("renren", AuthStyle.RenRen),
                ("salesforce", AuthStyle.Salesforce),
                ("salesforce-community", AuthStyle.SalesforceCommunity),
                ("salesforce-sandbox", AuthStyle.SalesforceSandbox),
                ("shopify", AuthStyle.Shopify),
                ("soundcloud", AuthStyle.Soundcloud),
                ("thecity", AuthStyle.TheCity),
                ("thecity-sandbox", AuthStyle.TheCitySandbox),
                ("thirtysevensignals", AuthStyle.ThirtySevenSignals),
                ("twitter", AuthStyle.Twitter),
                ("vkontakte", AuthStyle.Vkontakte),
                ("windowslive", AuthStyle.Microsoft),
                ("wordpress", AuthStyle.Wordpress),
                ("yahoo", AuthStyle.Yahoo),
                ("yammer", AuthStyle.Yammer),
                ("yandex", AuthStyle.Yandex),
                ("waad", AuthStyle.Google),
                ("weibo", AuthStyle.Weibo),
            ].forEach { (strategy, expected) in
                it("should match \(strategy) style") {
                    let style = AuthStyle.style(forStrategy: strategy, connectionName: "connection1")
                    expect(style) == expected
                }
            }
        }

        describe("style button color states") {

            let style: Style = Style.Auth0

            it("should have orange for normal") {
                expect(style.primaryButtonColor(forState: .normal)) == UIColor.a0_orange
            }

            it("should be darker for highlighted") {
                let baseColor = UIColor.a0_orange
                expect(style.primaryButtonColor(forState: .highlighted)) == baseColor.a0_darker(0.20)
            }

            it("should match disabled color") {
                expect(style.primaryButtonColor(forState: .disabled)) == UIColor(red: 0.8902, green: 0.898, blue: 0.9059, alpha: 1.0 )
            }

            it("should match disabled color") {
                expect(style.primaryButtonTintColor(forState: .disabled)) == UIColor(red: 0.5725, green: 0.5804, blue: 0.5843, alpha: 1.0 )
            }

            it("should match tint disabled color") {
                expect(style.primaryButtonTintColor(forState: .normal)) == UIColor.white
            }

        }
    }
}

extension AuthStyle: Equatable, CustomStringConvertible {
    public var description: String { return "AuthStyle(name=\(name))" }
}

public func ==(lhs: AuthStyle, rhs: AuthStyle) -> Bool {
    return lhs.name == rhs.name && lhs.normalColor == rhs.normalColor && lhs.highlightedColor == rhs.highlightedColor && lhs.foregroundColor == rhs.foregroundColor && lhs.image == rhs.image
}
