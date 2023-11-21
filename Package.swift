// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Lock",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Lock", targets: ["Lock"])
    ],
    dependencies: [
        .package(url: "https://github.com/auth0/Auth0.swift.git", "1.39.1" ..< "2.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", "7.0.0" ..< "8.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", "13.0.0" ..< "14.0.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", "9.0.0" ..< "10.0.0"),
    ],
    targets: [
        .target(
            name: "Lock",
            dependencies: [
                .product(name: "Auth0", package: "Auth0.swift"),
            ],
            path: "Lock",
            exclude: ["Info.plist"],
            resources: [
                .process("Lock.xcassets"),
                .process("passwordless_country_codes.plist")
            ]),
        .testTarget(
            name: "LockTests",
            dependencies: [
                "Lock",
                "Quick",
                "Nimble",
                .product(name: "Auth0", package: "Auth0.swift"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            path: "LockTests",
            exclude: ["Info.plist"])
    ]
)
