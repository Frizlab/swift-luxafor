/* Color.swift
 * Created by François Lamboley on 2022/07/20. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import Luxafor



struct Color : AsyncParsableCommand {
	
	@OptionGroup
	var rootOptions: Luxaforctl.Options
	
	@Option
	var leds: Leds = .all
	
	@Option(help: "The fade duration when setting the color. The unit is unknown. Must be between 0 and 255 (both included).")
	var fadeDuration: UInt8?
	
	@Argument
	var red: UInt8
	
	@Argument
	var green: UInt8
	
	@Argument
	var blue: UInt8
	
	func run() async throws {
		for luxafor in try Luxaforctl.getLuxafors(for: rootOptions) {
			try await luxafor.setColor(on: leds, red: red, green: green, blue: blue, fadeDuration: fadeDuration)
		}
	}
	
}
