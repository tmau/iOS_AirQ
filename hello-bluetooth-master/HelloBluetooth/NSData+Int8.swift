import Foundation

extension Data {
	//________________________________CHANGE STARTS________________________________
//	static func dataWithValue(value: Int8) -> Data {
//		let d3 = 61
//		let h1 = String(d3, radix: 16)
//		print(h1) // "3d"
//		var variableValue = value
//		return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
//	}
//
//	func int8Value() -> Int8 {
//		return Int8(bitPattern: self[0])
//	}
	//________________________________CHANGE ENDS________________________________
    static func dataWithValue(value: Int8) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }

    func int8Value() -> UInt8 {
		if (self == nil) {
			return 0
		}
		return UInt8(bitPattern: Int8(self[0]))
    }
}
