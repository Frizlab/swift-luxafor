/* Pattern.swift
 * Created by François Lamboley on 2022/07/20. */

import Foundation

import ArgumentParser
import CLTLogger
import Logging

import enum Luxafor.Pattern



struct Pattern : AsyncParsableCommand {
	
	@OptionGroup
	var rootOptions: Luxaforctl.Options
	
	@Argument
	var pattern: Luxafor.Pattern
	
	@Argument
	var repeatCount: UInt8
	
	func run() async throws {
		for luxafor in try Luxaforctl.getLuxafors(for: rootOptions) {
			try await luxafor.startPattern(pattern, repeatCount: repeatCount)
		}
	}
	
}
