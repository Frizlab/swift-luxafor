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
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.3")
	],
	targets: [
		.target(name: "Luxafor"),
		.executableTarget(name: "luxaforctl", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			.target(name: "Luxafor")
		])
	]
)
