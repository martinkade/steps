// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation"),
        .package(name: "firebase_database", path: "../.packages/firebase_database"),
        .package(name: "firebase_core", path: "../.packages/firebase_core")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "firebase-database", package: "firebase_database"),
                .product(name: "firebase-core", package: "firebase_core")
            ]
        )
    ]
)
