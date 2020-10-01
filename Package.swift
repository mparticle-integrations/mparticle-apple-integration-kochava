// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "mParticle-Kochava",
    platforms: [
            .iOS("10.3"),
            .tvOS("10.2"),
        ],
    products: [
        .library(
            name: "mParticle-Kochava",
            targets: ["mParticle-Kochava"]),
    ],
    dependencies: [
        .package(name: "mParticle-Apple-SDK", url: "git@github.com:mParticle/mparticle-apple-sdk.git", from: "8.0.1"),
        .package(
                    name: "KochavaCore",
                    url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaCore",
                    from: "4.0.0"
                ),
        .package(name: "KochavaTracker", url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaTracker.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "mParticle-Kochava",
            dependencies: ["mParticle-Apple-SDK","KochavaCore", "KochavaTracker"],
            path: "mParticle-Kochava",
            publicHeadersPath: "."),
    ],
    cxxLanguageStandard: .cxx11
)
