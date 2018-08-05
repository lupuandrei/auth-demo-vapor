// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "authDemoWeb",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0-rc.5"),
        .package(url: "https://github.com/vapor/fluent-mysql", from: "3.0.1"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.5"),

      
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "Authentication", "Redis", "FluentMySQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

