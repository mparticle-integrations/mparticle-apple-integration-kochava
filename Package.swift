// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "mParticle-Kochava",
    platforms: [
        .iOS("12.4"),
        .tvOS("12.4"),
    ],
    products: [
        .library(
            name: "mParticle-Kochava",
            targets: ["mParticle-Kochava"]),
    ],
    dependencies: [
        .package(name: "mParticle-Apple-SDK",
                 url: "https://github.com/mParticle/mparticle-apple-sdk",
                 .upToNextMajor(from: "8.3.0")),
        .package(name: "KochavaCore",
                 url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaCore", .upToNextMajor(from: "4.0.0")),
        .package(name: "KochavaTracker", url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaTracker.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Kochava",
            dependencies: ["mParticle-Apple-SDK", "KochavaCore", "KochavaTracker"],
            path: "mParticle-Kochava",
            publicHeadersPath: "."),
    ]
)
