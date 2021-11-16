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
        .package(name: "mParticle-Apple-SDK",
                 url: "https://github.com/mParticle/mparticle-apple-sdk",
                 .upToNextMajor(from: "8.3.0")),
        .package(name: "KochavaCore",
                 url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaCore", .upToNextMajor(from: "4.0.0")),
        .package(name: "KochavaTracker", url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaTracker.git", .upToNextMajor(from: "4.0.0")),
        .package(name: "KochavaAdNetwork", url: "https://github.com/Kochava/Apple-SwiftPackage-KochavaAdNetwork.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Kochava",
            dependencies: ["mParticle-Apple-SDK", "KochavaCore", "KochavaTracker", "KochavaAdNetwork"],
            path: "mParticle-Kochava",
            publicHeadersPath: "."),
    ]
)
