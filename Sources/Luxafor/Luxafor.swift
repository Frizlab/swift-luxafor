/*
 * Luxafor.swift
 *
 * Created by François Lamboley on 2022/07/04.
 */

import Foundation
import IOUSBHost



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
