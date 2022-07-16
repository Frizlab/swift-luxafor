/* Errors.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation



public enum LuxaforError : Error {
	
	case kernelError(kern_return_t)
	case noDeviceDescriptor
	case noConfigurationDescriptor
	case invalidInterfacesCount
	case cannotGetInteraceDescriptor
	case foundTooManyOrNoMatchingInterfaces
	
}

typealias Err = LuxaforError
