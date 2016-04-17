//: Playground - noun: a place where people can play

import Cocoa

// Create an Int-based Signal.
let s = Signal<Int>()
s.subscribe { print("got: \($0)") }

// Derive a Signal that’s always 3 x the value of `s`. 
let times3 = s.map { 3 * $0 }
times3.subscribe { print("... x 3: \($0)") }

// Derive a Signal that only emits the even values of `3 * s`. 
let evens = times3.filter { 0 == $0 % 2 }
evens.subscribe { _ in print("... is even!") }

// Derive a Signal that emits the sum of the evens. 
let total = evens.reduce(0, combiner: +)
total.subscribe { print("... running total: \($0)") }

// Emit the numbers 1 through 5; check the console for the output of all of our signals!
for i in (1...5) { s.emit(i) }

//: [Next](@next)
