/* Errors.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation



public enum LuxaforError : Error {
	
	case cannotGetMatchingHIDDevices
	case cannotGetMaxReportSizeOfDevice
	case cannotOpenDevice(IOReturn)
	case tooManyBytesToSend
	case errorSettingReport(IOReturn)
	
}

typealias Err = LuxaforError
