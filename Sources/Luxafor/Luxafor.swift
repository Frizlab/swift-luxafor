/* Luxafor.swift
 * Created by François Lamboley on 2022/07/04. */

import Foundation
import IOUSBHost


/* Random link that helped: https://www.beyondlogic.org/usbnutshell/usb5.shtml */


/**
 A `Luxafor` object.
 
 - Note: This is an actor because internally we hold a reference to an IOUSBHostDevice which is probably not-concurrent-safe (not sure though).
 If later we learn the IOUSBHostDevice is safe in a concurrent environment we could probably demote the Luxafor to a simple class.
 We’d still need the class type because we `destroy()` the IOUSBHostDevice when the Luxafor is not used anymore. */
public final actor Luxafor {
	
	/** The vendor ID for Luxafor. Should not be needed by clients. */
	public static let  vendorID = 0x04d8 /* Microchip Technology Inc. */
	/** The product ID for Luxafor. Should not be needed by clients. */
	public static let productID = 0xf372 /* Luxafor flag */
	
	public static func find() throws -> [Luxafor] {
		/* The method is refined for Swift they say (hence the two underscore prefix), but the refined method cannot be found.
		 * The dictionary produced by this method is:
		 *    let matchingDic: [String: Any] = [
		 *       IOUSBHostMatchingPropertyKey.vendorID.rawValue:  Self.vendorID,
		 *       IOUSBHostMatchingPropertyKey.productID.rawValue: Self.productID,
		 *       "IOProviderClass": "IOUSBHostDevice"
		 *    ]
		 */
		let matchingDic = IOUSBHostDevice.__createMatchingDictionary(
			withVendorID: NSNumber(value: Self.vendorID), productID: NSNumber(value: Self.productID),
			bcdDevice: nil, deviceClass: nil, deviceSubclass: nil, deviceProtocol: nil, speed: nil, productIDArray: nil
		).takeUnretainedValue()
		
		var iterator: io_iterator_t = .zero
		let ret = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDic, &iterator)
		guard ret == KERN_SUCCESS else {throw Err.kernelError(ret)}
		defer {releaseIOObject(iterator)}
		
		return getAll(from: iterator)
			.compactMap{ object in
				/* The init is supposed to be refined for Swift too.
				 * Once again the refined method cannot be found. */
				do {
					return try IOUSBHostDevice(__ioService: object, options: [/*Nothing: We do not (and cannot) capture the device.*/], queue: nil, interestHandler: nil)
				} catch {
					/* We release the objects for which we cannot create an IOUSBHostDevice. */
					Conf.logger?.info("Skipping IOService object because an IOUSBHostDevice cannot be created with it.", metadata: ["object": "\(object)", "error": "\(error)"])
					releaseIOObject(object)
					return nil
				}
			}
			.map(Luxafor.init(device:))
	}
	
	public func yolo() throws {
		guard let deviceDescriptor = device.deviceDescriptor?.pointee else {
			throw Err.noDeviceDescriptor
		}
		guard let configPtr = device.configurationDescriptor else {
			throw Err.noConfigurationDescriptor
		}
		guard configPtr.pointee.bNumInterfaces == 1 else {
			throw Err.invalidInterfacesCount
		}
		guard let interfaceDescription = IOUSBGetNextInterfaceDescriptor(configPtr, nil/* Current descriptor: nil. We get first (and only) descriptor */)?.pointee else {
			throw Err.cannotGetInteraceDescriptor
		}
		
		/* Same as IOUSBHostDevice.__createMatchingDictionary (in find() method), we could create the dictionary manually too.
		 * The "IOProviderClass" key would be set to "IOUSBHostInterface". */
		let matchingDic = IOUSBHostInterface.__createMatchingDictionary(
			withVendorID: NSNumber(value: deviceDescriptor.idVendor),
			productID: NSNumber(value: deviceDescriptor.idProduct),
			bcdDevice: NSNumber(value: deviceDescriptor.bcdDevice),
			interfaceNumber: NSNumber(value: interfaceDescription.bInterfaceNumber),
			configurationValue: NSNumber(value: configPtr.pointee.bConfigurationValue),
			interfaceClass: NSNumber(value: interfaceDescription.bInterfaceClass),
			interfaceSubclass: NSNumber(value: interfaceDescription.bInterfaceSubClass),
			interfaceProtocol: NSNumber(value: interfaceDescription.bInterfaceProtocol),
			speed: nil,
			productIDArray: nil
		).takeUnretainedValue()
		
		var iterator: io_iterator_t = .zero
		let ret = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDic, &iterator)
		guard ret == KERN_SUCCESS else {throw Err.kernelError(ret)}
		defer {Self.releaseIOObject(iterator)}
		
		let allInterfaceObjects = Self.getAll(from: iterator)
		guard let firstInterfaceObject = allInterfaceObjects.first, allInterfaceObjects.count == 1 else {
			throw Err.foundTooManyOrNoMatchingInterfaces
		}
		
		let interface = try IOUSBHostInterface(__ioService: firstInterfaceObject, options: [/*Nothing: We do not (and cannot) capture the device.*/], queue: nil, interestHandler: nil)
		defer {interface.destroy()}
		print(interface)
		
		/* Aaaaand we hit a dead-end.
		 * The IOUSBHostInterface init fails with error “Exclusive open of usb object failed.”
		 * Then I saw the Luxafor flag is HID; so we’ll use the much lighter HID version of USB; and things should go well.
		 * If we succeeded in getting the IOUSBHostInterface object, we could’ve created the pipes necessary to write the the device.
		 * See https://github.com/didactek/deft-simple-usb/blob/951a3c907390342ba13c9006351c575caf02fd11/Sources/HostFWUSB/HostFWUSBDevice.swift#L70
		 *
		 * After some research, I found this: https://github.com/didactek/deft-mcp2221#hid-vs-iousbhost
		 * So yeah, we HAVE TO use HID methods to access HID devices on macOS. */
	}
	
	/* *************
	   MARK: Private
	   ************* */
	
	internal init(device: IOUSBHostDevice) {
		self.device = device
	}
	
	deinit {
		device.destroy()
	}
	
	internal let device: IOUSBHostDevice
	
	private static func getAll(from iterator: io_iterator_t) -> [io_object_t] {
		guard IOIteratorIsValid(iterator) != 0 else {
			/* It seems the kernel returns an invalid iterator when the list is empty 🤷‍♂️ */
			return []
		}
		
		var res = [io_object_t]()
		do {
			while let next = try getNext(from: iterator) {
				res.append(next)
			}
			return res
		} catch is IterationResetRequired {
			res.forEach(releaseIOObject(_:))
			
			/* I do hope the doc is correct and resetting the iterator will make it work again.
			 * If not, we’ll end up with an infinite loop… */
			IOIteratorReset(iterator)
			return getAll(from: iterator)
		} catch {
			fatalError("Invalid error thrown from getNext(from:) internal method: \(error)")
		}
	}
	
	private struct IterationResetRequired : Error {}
	private static func getNext(from iterator: io_iterator_t) throws -> io_object_t? {
		let next = IOIteratorNext(iterator)
		if next != 0 {
			/* We got a value, we can return it without further ado. */
			return next
		}
		
		guard IOIteratorIsValid(iterator) != 0 else {
			/* If the iterator is invalid, we should reset it and restart the iteration. */
			throw IterationResetRequired()
		}
		
		return nil
	}
	
	private static func releaseIOObject(_ object: io_object_t) {
		let ret = IOObjectRelease(object)
		if ret != KERN_SUCCESS {
			Conf.logger?.error("Error releasing an io_object_t.", metadata: ["object": "\(object)", "error_number": "\(ret)"])
		}
	}
	
}
