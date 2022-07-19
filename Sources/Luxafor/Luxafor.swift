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
					Conf.logger?.info("Skipping device because we cannot create a Luxafor object with it.", metadata: ["device": "\(device)", "error": "\(error)"])
					return nil
				}
			}
	}
	
	/** I don’t know the unit of the duration. */
	public func turnOff(_ leds: Leds, fadeDuration: UInt8? = nil) throws {
		try setColor(on: leds, red: 0x00, green: 0x00, blue: 0x00, fadeDuration: fadeDuration)
	}
	
	/** I don’t know the unit of the duration. */
	public func setColor(on leds: Leds, red: UInt8, green: UInt8, blue: UInt8, fadeDuration: UInt8? = nil) throws {
		/* Original project (from which we are forked) used 0x00 for the last two bytes, or when fade is not set, but apparently Luxafor sends 0x10.0
		 * I don’t think this changes anything.
		 * (We gathered this by launching the Luxafor.app/Contents/MacOS/Luxafor in a Terminal; we get logs of what is sent and received.) */
		try send(bytes: [fadeDuration == nil ? 0x01 : 0x02, leds.rawValue, red, green, blue, fadeDuration ?? 0x10, 0x10, 0x10])
	}
	
	/**
	 A `repeatCount` of 0 means the strobe will not stop.
	 I don’t know the unit of the duration. */
	public func startStrobe(on leds: Leds, red: UInt8, green: UInt8, blue: UInt8, duration: UInt8, repeatCount: UInt8) throws {
		try send(bytes: [0x03, leds.rawValue, red, green, blue, duration, 0x00, repeatCount])
	}
	
	/**
	 A `repeatCount` of 0 means the wave will not stop.
	 I don’t know the unit of the duration. */
	public func startWave(_ wave: Wave, red: UInt8, green: UInt8, blue: UInt8, duration: UInt8, repeatCount: UInt8) throws {
		try send(bytes: [0x04, wave.rawValue, red, green, blue, 0x00, repeatCount, duration])
	}
	
	/** A `repeatCount` of 0 means the wave will not stop. */
	public func startPattern(_ pattern: Pattern, repeatCount: UInt8) throws {
		/* Original project (from which we are forked) used 0x00 for the last five bytes, but apparently Luxafor sends 0x10.
		 * I don’t think this changes anything.
		 * (We gathered this by launching the Luxafor.app/Contents/MacOS/Luxafor in a Terminal; we get logs of what is sent and received.) */
		try send(bytes: [0x06, pattern.rawValue, repeatCount, 0x10, 0x10, 0x10, 0x10, 0x10])
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
	
	internal func send(bytes: [UInt8]) throws {
		guard !bytes.isEmpty else {
			return
		}
		
		guard bytes.count <= maxReportSize else {
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
			throw Err.errorSettingReport(ret)
		}
	}
	
}
