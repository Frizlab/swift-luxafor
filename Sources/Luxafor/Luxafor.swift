/*
 * Luxafor.swift
 *
 * Created by François Lamboley on 2022/07/04.
 */

import Foundation
import IOUSBHost



/**
 A `Luxafor` object.
 
 - Note: This is an actor because internally we hold a reference to an io\_object\_t which is probably not-concurrent-safe (not sure though).
 If later we learn the io\_object\_t is safe in a concurrent environment we could probably demote the Luxafor to a simple class.
 We’d still need the class type because we release the io\_object\_t when the Luxafor is not used anymore. */
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
		defer {IOObjectRelease(iterator)}
		
		return getAll(from: iterator).map(Luxafor.init(ioObject:))
	}
	
	/* *************
	   MARK: Private
	   ************* */
	
	internal init(ioObject: io_object_t) {
		self.ioObject = ioObject
	}
	
	deinit {
		IOObjectRelease(ioObject)
	}
	
	internal let ioObject: io_object_t
	
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
			res.forEach{ IOObjectRelease($0) }
			
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
	
}
