/*
 * Luxaforctl.swift
 *
 * Created by François Lamboley on 2022/07/04.
 */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import Luxafor



@main
struct Luxaforctl : AsyncParsableCommand {
	
	@Option
	var leds: Leds = .all
	
	static var logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	func run() async throws {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		LuxaforConfig.logger?.logLevel = .debug
		
		for luxafor in try Luxafor.find() {
			try await luxafor.startStrobe(on: .all, red: 255, green: 255, blue: 255, duration: 0x09, repeatCount: 3)
		}
	}
	
}
