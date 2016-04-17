//: [Previous](@previous)

import Foundation

// Create an Int-based Signal.
let s = Signal<Int>()

// Chain all of these Signals together without having to create all the intermediates.
let total = s.map({ 3 * $0 })
				.filter({ 0 == $0 % 2 })
				.reduce(0, combiner: +)
total.subscribe { print("... running total: \($0)") }

// Emit the numbers 1 through 5; check the console for the output of all of our signals!
for i in (1...10) { s.emit(i) }

//: [Next](@next)
