/* Off.swift
 * Created by François Lamboley on 2022/07/20. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import Luxafor



struct Red : AsyncParsableCommand {
	
	@OptionGroup
	var rootOptions: Luxaforctl.Options
	
	@Option(help: "Percentage of brightness of the red. Must be between 0 and 100 (both included).")
	var brightness: Float = 3
	
	@Option
	var leds: Leds = .all
	
	@Option(help: "The fade duration when setting the color. The unit is unknown. Must be between 0 and 255 (both included).")
	var fadeDuration: UInt8?
	
	func validate() throws {
		guard brightness >= 0, brightness <= 100 else {
			throw ValidationError("Invalid brightness (must be between 0 and 100).")
		}
	}
	
	func run() async throws {
		for luxafor in try Luxaforctl.getLuxafors(for: rootOptions) {
			try await luxafor.setColor(on: leds, red: UInt8(0xff * brightness/100), green: 0x00, blue: 0x00, fadeDuration: fadeDuration)
		}
	}
	
}
