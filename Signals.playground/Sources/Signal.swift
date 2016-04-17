import Foundation
import Dispatch

internal struct Emission <T> {
	let timestamp: NSTimeInterval
	let value: T
}

public class Signal <T> {
	public typealias BlockType = T -> ()
	typealias EmissionBlockType = Emission<T> -> ()
	var blocks: [EmissionBlockType] = []
	
	public init() {}
	
	public func emit(value: T) {
		let timestamp = NSDate.timeIntervalSinceReferenceDate()
		let emission = Emission(timestamp: timestamp, value: value)
		for block in blocks {
			block(emission)
		}
	}
	
	func subscribeTime(block: EmissionBlockType) {
		blocks.append(block)
	}
	public func subscribe(block: BlockType) {
		subscribeTime { emission in block(emission.value) }
	}
	public func subscribe(signal: Signal<T>) {
		subscribe { signal.emit($0) }
	}
}


// Holds onto the last value emitted.
internal class HoldingSignal <T> : Signal <T> {
	var hold: T?
	init(hold: T) {
		self.hold = hold
	}
	override init() {
		self.hold = nil
	}
	
	override func emit(value: T) {
		self.hold = value
		super.emit(value)
	}
}


public class SequenceSignal <T> : Signal <T> {
	var items: [T]
	public init(items: [T]) {
		self.items = items
	}
	
	override func subscribeTime(block: EmissionBlockType) {
		for item in items {
			block(Emission(timestamp: 0, value: item))
		}
		
		blocks.append(block)
	}
}


public extension Signal {
	public func map <U> (f: T -> U) -> Signal<U> {
		let signal = Signal<U>()
		self.subscribe { x in 
			signal.emit(f(x))
		}
		return signal
	}
	
	public func filter(predicate: T -> Bool) -> Signal<T> {
		let signal = Signal<T>()
		self.subscribe { x in
			if predicate(x) {
				signal.emit(x)
			}
		}
		return signal
	}
	
	public func reduce <U> (initial: U, combiner: (U, T) -> U) -> Signal<U> {
		let signal = HoldingSignal<U>(hold: initial)
		self.subscribe { x in
			signal.emit(combiner(signal.hold!, x))
		}
		return signal
	}
}

// Allows two Signals to map together into a single Signal, using a combiner.
public func map2 <T, U, V> (lhs: Signal<T>, _ rhs: Signal<U>, combiner: (T, U) -> V) -> Signal<V> {
	let last_left = HoldingSignal<T>()
	lhs.subscribe(last_left)
	let last_right = HoldingSignal<U>()
	rhs.subscribe(last_right)
	
	let signal = Signal<V>()
	let do_combiner = {
		if let l = last_left.hold, r = last_right.hold {
			signal.emit(combiner(l, r))
		}
	}
	last_left.subscribe { _ in do_combiner() }
	last_right.subscribe { _ in do_combiner() }
	
	return signal
}
// Convenience functions for doing Boolean operations with Bool-based signals.
public func and(lhs: Signal<Bool>, _ rhs: Signal<Bool>) -> Signal<Bool> {
	return map2(lhs, rhs) { $0 && $1 }
}
public func or(lhs: Signal<Bool>, _ rhs: Signal<Bool>) -> Signal<Bool> {
	return map2(lhs, rhs) { $0 || $1 }
}
public func xor(lhs: Signal<Bool>, _ rhs: Signal<Bool>) -> Signal<Bool> {
	return map2(lhs, rhs) { ($0 && !$1) || (!$0 && $1) }
}




public func signal_sum <T, U> (lhs: Signal <T>, rhs: Signal <U>) -> Signal <Either<T, U>> {
	let s = Signal<Either<T, U>>()
	
	// Whenever either signal emits a value, post it to the combined signal.
	lhs.subscribe { (val: T) in
		s.emit(Either<T, U>.Left(val))
	}
	rhs.subscribe { (val: U) in
		s.emit(Either<T, U>.Right(val))
	}
	
	return s
}
public func + <T, U> (lhs: Signal <T>, rhs: Signal <U>) -> Signal <Either<T, U>> {
	return signal_sum(lhs, rhs: rhs)
}


public func signal_product <T, U> (lhs: Signal <T>, rhs: Signal <U>) -> Signal <(T, U)> {
	return map2(lhs, rhs) { ($0, $1) }
}
public func * <T, U> (lhs: Signal <T>, rhs: Signal <U>) -> Signal <(T, U)> {
	return signal_product(lhs, rhs: rhs)
}


public extension Signal {
	public func zipWith(other: Signal<T>, f: (T, T) -> T) -> Signal<T> {
		let left_and_right = self * other
		let composite = Signal<T>()
		left_and_right.subscribe { (left: T, right: T) in
			let combined: T = f(left, right)
			composite.emit(combined)
		}
		return composite
	}
}


class ThrottledSignal <T> : HoldingSignal <T> {
	let interval: NSTimeInterval
	var timer: Timer? = nil
	
	init(interval: NSTimeInterval) {
		self.interval = interval
		super.init()
		self.actuallyEmitAfterInterval()
	}
	
	override func emit(value: T) {
		self.hold = value
		
		// If we do not have a timer, create one.
		if nil == self.timer {
			self.actuallyEmitAfterInterval()
		}
	}
	
	func actuallyEmitAfterInterval() {
		self.timer = Timer(oneShotAfterInterval: self.interval) {
			if let value = self.hold {
				super.emit(value)
			}
			self.timer = nil
		}
		self.timer!.start()
	}
}

public extension Signal {
	// Ensures that downstream subscriber blocks aren't called more than once every 'interval' seconds.
	// Note that this will throw away intermediate states and only pass the last-emitted value!
	public func throttle(by interval: NSTimeInterval) -> Signal<T> {
		let throttled = ThrottledSignal<T>(interval: interval)
		self.subscribe(throttled)
		return throttled
	}
}


