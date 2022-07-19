/* Led.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation



public enum Leds : UInt8 {
	
	case all = 0xff
	
	case back  = 0x42
	case front = 0x41
	
	case led1 = 0x01
	case led2 = 0x02
	case led3 = 0x03
	case led4 = 0x04
	case led5 = 0x05
	case led6 = 0x06
	
}
