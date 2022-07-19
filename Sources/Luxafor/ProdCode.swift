/* ProdCode.swift
 * Created by François Lamboley on 2022/07/19. */

import Foundation



/**
 ProdCode is a "Productivity" mode is supposed to work but it's present in some of the documentation.
 
 It seems to be a "quick" way of setting individual colours based on letters like 'G' for green and 'R' for red.
 It has to be enabled before it will accept these codes. */
public enum ProdCode : UInt8 {
	
	/**
	 Enable productivity mode.
	 No other codes are accepted while this one has not been sent. */
	case enable  = 0x45/*E*/
	/** Disable productivity mode. */
	case disable = 0x44/*D*/
	case red     = 0x52/*R*/
	case green   = 0x47/*G*/
	case blue    = 0x42/*B*/
	case cyan    = 0x43/*C*/
	case magenta = 0x4d/*M*/
	case yellow  = 0x59/*Y*/
	case white   = 0x57/*W*/
	case off     = 0x4f/*O*/
	
}
