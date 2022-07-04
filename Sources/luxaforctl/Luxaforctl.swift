/*
 * Luxaforctl.swift
 *
 * Created by François Lamboley on 2022/07/04.
 */

import Foundation

import ArgumentParser
import Luxafor



@main
struct Luxaforctl : ParsableCommand {
	
	func run() throws {
		for luxafor in try Luxafor.find() {
			print(luxafor)
		}
	}
	
}
