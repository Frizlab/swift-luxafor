/* Luxaforctl.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import Luxafor



@main
struct Luxaforctl : AsyncParsableCommand {
	
	static var configuration: CommandConfiguration = .init(
		subcommands: [Off.self, Red.self, Green.self, Color.self, Strobe.self, Pattern.self, Wave.self]
	)
	
	struct Options : ParsableArguments {
		
		/* Note: I’d have liked to retrieve serial number or any identifier that would have allowed to send the device to a specified Luxafor, but I was not able to get one. */
		@Flag(help: "By default we fail the command if more than one Luxafor is connected to the computer. Set this to send the command to all connected Luxafors when more than one are connected.")
		var enableMultipleLuxafor: Bool = false
		
	}
	
	static /*lazy*/ var logger: Logger = {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		LuxaforConfig.logger?.logLevel = .debug
		
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	static func getLuxafors(for options: Options) throws -> [Luxafor] {
		let luxafors = try Luxafor.find()
		guard !luxafors.isEmpty else {
			throw Err(message: "No Luxafor devices found.")
		}
		guard luxafors.count == 1 || options.enableMultipleLuxafor else {
			throw Err(message: "Found \(luxafors.count) Luxafor devices; bailing out. Re-run with --enable-multiple-luxafor to send the command to all of them.")
		}
		return luxafors
	}
	
	struct Err : Error, CustomStringConvertible {
		var message: String
		var description: String {return message}
	}
	
}
