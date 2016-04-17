//: [Previous](@previous)

import Foundation
import XCPlayground

// Create a Signal and throttle it to only fire once every three seconds, at most.
let a = Signal<Bool>().throttle(by: 3.0)
// Create another Signal that fires whenever it’s sent a value.
let b = Signal<Bool>()

// Create a Signal of the logical-AND of a and b
and(a, b).subscribe { print("a and b: \($0)") }
// Create a Signal of the logical-OR of a and b
or(a, b).subscribe { print("a or b: \($0)") }
// Create a Signal of the logical-XOR of a and b
xor(a, b).subscribe { print("a xor b: \($0)") }

// Produce a bunch of random Boolean values...
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
Timer(repeatingEvery: 1.0, block: {
	a.emit(0 == rand() % 2)
	b.emit(0 == rand() % 2)
}).start()

//: [Next](@next)
