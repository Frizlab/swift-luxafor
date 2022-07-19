/* Errors.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation



/* Hint: There is a mach_error_string function that exists (IOReturn code to string). */
public enum LuxaforError : Error {
	
	case cannotGetMatchingHIDDevices
	case cannotGetMaxReportSizeOfDevice
	case cannotOpenDevice(IOReturn)
	case tooManyBytesToSend
	case errorSettingReport(IOReturn)
	
}

typealias Err = LuxaforError
