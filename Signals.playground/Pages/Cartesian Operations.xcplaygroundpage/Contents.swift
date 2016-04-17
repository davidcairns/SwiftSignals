//: [Previous](@previous)

import Foundation
import XCPlayground

// Create a Signal and throttle it to only fire once every three seconds, at most.
let a = Signal<Bool>().throttle(by: 3.0)
// Create another Signal that fires whenever it’s sent a value.
let b = Signal<Bool>()

// Create a Signal of the Cartesian product of a and b.
signal_product(a, rhs: b).subscribe { print("product: \($0)") }
// Create a Signal of the Sum of a and b.
signal_sum(a, rhs: b).subscribe { print("sum: \($0)") }


// Produce a bunch of random Boolean values...
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
Timer(repeatingEvery: 1.0, block: {
	a.emit(0 == rand() % 2)
	b.emit(0 == rand() % 2)
}).start()

//: [Next](@next)
