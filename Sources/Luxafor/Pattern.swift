/* Pattern.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation



public enum Pattern : UInt8 {
	
	case trafficLights   = 0x01
	case colorWalk       = 0x02
	case random          = 0x03
	case randomFading    = 0x04
	case police          = 0x05
	case randomQuickFade = 0x06
	case colorfulPolice  = 0x07
	case quickRainbow    = 0x08
	
}
