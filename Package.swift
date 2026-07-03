// Package.swift
// HermesAgent - Swift Package Manager

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HermesAgent",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "HermesAgent",
            targets: ["HermesAgent"]),
    ],
    targets: [
        .target(
            name: "HermesAgent",
            dependencies: []),
        .testTarget(
            name: "HermesAgentTests",
            dependencies: ["HermesAgent"]),
    ]
)