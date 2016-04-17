import Foundation

internal class InternalBox<Value> {
	var n: Value
	init(n: Value) {
		self.n = n
	}
}

public struct MutableBox<Value> {
	var m: InternalBox<Value>
	
	public var n: Value {
		get {
			return m.n
		}
		set {
			m.n = newValue
		}
	}
	
	public init(n: Value) {
		self.m = InternalBox(n: n)
	}
}
