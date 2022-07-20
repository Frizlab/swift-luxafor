/* Wave+ExpressibleByArgument.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation

import ArgumentParser

import enum Luxafor.Wave



extension Luxafor.Wave : ExpressibleByArgument {
	
	public init?(argument: String) {
		switch argument {
			case "1": self = .v1
			case "2": self = .v2
			case "3": self = .v3
			case "4": self = .v4
			case "5": self = .v5
				
			default:
				return nil
		}
	}
	
}
