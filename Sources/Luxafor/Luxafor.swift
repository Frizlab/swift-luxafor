/* Luxafor.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation
import IOKit.hid


/* Random link that helped: https://www.beyondlogic.org/usbnutshell/usb5.shtml */


/**
 A `Luxafor` object.
 
 - Note: This is an actor because internally we hold a reference to an IOHIDDevice which is probably not-concurrent-safe (not sure though).
 If later we learn the IOHIDDevice is safe in a concurrent environment we could probably demote the Luxafor to a simple class.
 We’d still need the class type because we close the device when the Luxafor is not used anymore. */
public final actor Luxafor {
	
	/** The vendor ID for Luxafor. Should not be needed by clients. */
	public static let  vendorID = 0x04d8 /* Microchip Technology Inc. */
	/** The product ID for Luxafor. Should not be needed by clients. */
	public static let productID = 0xf372 /* Luxafor flag */
	
	public static func find() throws -> [Luxafor] {
		let matchDirectory = [
			kIOHIDVendorIDKey: Self.vendorID,
			kIOHIDProductIDKey: Self.productID
		]
		
		let manager = IOHIDManagerCreate(/*allocator: */nil, /*options: */0/*kIOHIDManagerOptionNone*/)
		IOHIDManagerSetDeviceMatching(manager, matchDirectory as CFDictionary)
		guard let res = IOHIDManagerCopyDevices(manager) else {
			throw Err.cannotGetMatchingHIDDevices
		}
		return (res as NSSet)
			.compactMap{ device in
				let device = device as! IOHIDDevice
				do {
					return try Self(device: device)
				} catch {
					/* We release the objects for which we cannot create an IOUSBHostDevice. */
					Conf.logger?.info("Skipping device because we cannot create a Luxafor object with it.", metadata: ["device": "\(device)", "error": "\(error)"])
					return nil
				}
			}
	}
	
	public func yolo() throws {
		let bytes: [UInt8] = [
			0x01, /* Command (1 or 2, set color, 2 w/ fade) */
			0xff, /* LED selection (all ff=all) */
			0x00, /* Red */
			0x07, /* Green */
			0x00, /* Blue */
			0x10, /* Fade time (if != 0 first byte should be set to 0x02) */
			0x10, /* Unknown */
			0x10  /* Unknown */]
//		let bytes: [UInt8] = [
//			0x06, /* Command (pattern) */
//			0x08, /* Pattern (1-8) */
//			0x01, /* Repeat (0 is forever) */
//			0x00, /* Unknown */
//			0x00, /* Unknown */
//			0x00, /* Unknown */
//			0x00, /* Unknown */
//			0x00  /* Unknown */]
		if bytes.count > maxReportSize {
			throw Err.tooManyBytesToSend
		}
		let ret = bytes.withUnsafeBytes{ ptr in
			IOHIDDeviceSetReport(
				device, kIOHIDReportTypeOutput,
				/*reportID: */0,
				ptr.baseAddress!.assumingMemoryBound(to: UInt8.self), ptr.count
			)
		}
		guard ret == kIOReturnSuccess else {
			print(String(cString: mach_error_string(ret)!))
			throw Err.errorSettingReport(ret)
		}
		print("ok")
	}
	
	/* *************
	   MARK: Private
	   ************* */
	
	internal init(device: IOHIDDevice) throws {
		guard let sizeCF = IOHIDDeviceGetProperty(device, kIOHIDMaxInputReportSizeKey as CFString),
				let size = sizeCF as? Int
		else {
			throw Err.cannotGetMaxReportSizeOfDevice
		}
		
		/* Open the device to be able to send it data. */
		let ret = IOHIDDeviceOpen(device, /*options: */0/*No options: we do not (and cannot) seize the device.*/)
		guard ret == kIOReturnSuccess else {
			throw Err.cannotOpenDevice(ret)
		}
		
		self.device = device
		self.maxReportSize = size
	}
	
	deinit {
		let ret = IOHIDDeviceClose(device, /*options: */0)
		if ret != kIOReturnSuccess {
			Conf.logger?.error("Cannot close HID device.", metadata: ["device": "\(device)", "return_code": "\(ret)"])
		}
	}
	
	internal let device: IOHIDDevice
	internal let maxReportSize: Int
	
}
