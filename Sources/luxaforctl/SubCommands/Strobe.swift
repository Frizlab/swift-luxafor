/* Strobe.swift
 * Created by François Lamboley on 2022/07/20. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import Luxafor



struct Strobe : AsyncParsableCommand {
	
	@OptionGroup
	var rootOptions: Luxaforctl.Options
	
	@Option
	var leds: Leds = .all
	
	@Argument
	var red: UInt8
	
	@Argument
	var green: UInt8
	
	@Argument
	var blue: UInt8
	
	@Argument
	var repeatCount: UInt8
	
	@Argument
	var intervalDuration: UInt8
	
	func run() async throws {
		for luxafor in try Luxaforctl.getLuxafors(for: rootOptions) {
			try await luxafor.startStrobe(on: leds, red: red, green: green, blue: blue, duration: intervalDuration, repeatCount: repeatCount)
		}
	}
	
}
