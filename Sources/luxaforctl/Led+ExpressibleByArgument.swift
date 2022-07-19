/* Led+ExpressibleByArgument.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation

import ArgumentParser

import Luxafor



extension Leds : ExpressibleByArgument {
	
	public init?(argument: String) {
		switch argument {
			case "all":   self = .all
			case "back":  self = .back
			case "front": self = .front
			case "led1":  self = .led1
			case "led2":  self = .led2
			case "led3":  self = .led3
			case "led4":  self = .led4
			case "led5":  self = .led5
			case "led6":  self = .led6
				
			default:
				return nil
		}
	}
	
}
