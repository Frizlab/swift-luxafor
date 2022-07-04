// swift-tools-version:5.5
import PackageDescription



let package = Package(
	name: "Luxafor",
	platforms: [.macOS(.v12)],
	products: [
		.library(name: "Luxafor", targets: ["Luxafor"]),
		.executable(name: "luxaforctl", targets: ["luxaforctl"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.3"),
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
		.package(url: "https://github.com/xcode-actions/clt-logger.git", from: "0.3.6")
	],
	targets: [
		.target(name: "Luxafor", dependencies: [
			.product(name: "Logging", package: "swift-log")
		]),
		.executableTarget(name: "luxaforctl", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.product(name: "CLTLogger",     package: "clt-logger"),
			.product(name: "Logging",       package: "swift-log"),
			.target(name: "Luxafor")
		])
	]
)
