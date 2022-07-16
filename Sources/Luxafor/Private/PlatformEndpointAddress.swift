/* PlatformEndpointAddress.swift
 * Created by François Lamboley on 2022/07/16.
 * Adapted from https://github.com/didactek/deft-simple-usb/blob/ff3c03596abcdcda232884e09ee47075c10382c1/Sources/SimpleUSB/PlatformEndpointAddress.swift */

import Foundation



struct PlatformEndpointAddress<RawValue : FixedWidthInteger> {
	
	let rawValue: RawValue
	
	init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	/** Checks the endpoint descriptor direction bit (bit 7) for "in" or "out." */
	var isWritable: Bool {
		return rawValue & directionMask == EndpointDirection.output.rawValue
	}
	
	private enum EndpointDirection : RawValue {
		
		/* Table 9-13. Standard Endpoint Descriptor. */
		case input  = 0b1000_0000
		case output = 0b0000_0000
		
	}
	
	/* USB 2.0 - 9.6.6 Endpoint: Bit 7 is direction IN/OUT. */
	private let directionMask = RawValue(EndpointDirection.input.rawValue | EndpointDirection.output.rawValue)
	
}
