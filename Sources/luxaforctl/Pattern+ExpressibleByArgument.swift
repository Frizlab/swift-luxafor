/* Pattern+ExpressibleByArgument.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation

import ArgumentParser

import enum Luxafor.Pattern



extension Luxafor.Pattern : ExpressibleByArgument {
	
	public init?(argument: String) {
		switch argument {
			case "traffic-lights":    self = .trafficLights
			case "color-walk":        self = .colorWalk
			case "random":            self = .random
			case "random-fading":     self = .randomFading
			case "police":            self = .police
			case "random-quick-fade": self = .randomQuickFade
			case "colorful-police":   self = .colorfulPolice
			case "quick-rainbow":     self = .quickRainbow
				
			default:
				return nil
		}
	}
	
}
