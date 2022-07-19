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
//			try await luxafor.setColor(on: .all, red: 0x07, green: 0x00, blue: 0x00)
			try await luxafor.turnOff(.all)
		}
	}
	
}
