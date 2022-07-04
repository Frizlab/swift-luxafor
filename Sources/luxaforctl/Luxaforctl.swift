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
struct Luxaforctl : ParsableCommand {
	
	static var logger: Logger = {
		var ret = Logger(label: "main")
		ret.logLevel = .debug
		return ret
	}()
	
	func run() throws {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		LuxaforConfig.logger?.logLevel = .debug
		
		for luxafor in try Luxafor.find() {
			print(luxafor)
		}
	}
	
}
