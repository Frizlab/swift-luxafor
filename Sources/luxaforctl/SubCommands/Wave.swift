/* Wave.swift
 * Created by François Lamboley on 2022/07/20. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import enum Luxafor.Wave



struct Wave : AsyncParsableCommand {
	
	@OptionGroup
	var rootOptions: Luxaforctl.Options
	
	@Argument
	var wave: Luxafor.Wave
	
	@Argument
	var red: UInt8
	
	@Argument
	var green: UInt8
	
	@Argument
	var blue: UInt8
	
	@Argument
	var repeatCount: UInt8
	
	@Argument
	var waveDuration: UInt8
	
	func run() async throws {
		for luxafor in try Luxaforctl.getLuxafors(for: rootOptions) {
			try await luxafor.startWave(wave, red: red, green: green, blue: blue, duration: waveDuration, repeatCount: repeatCount)
		}
	}
	
}
