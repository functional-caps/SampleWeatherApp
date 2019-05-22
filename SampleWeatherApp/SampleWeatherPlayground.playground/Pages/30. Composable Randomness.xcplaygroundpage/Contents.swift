//: [Previous](@previous)

import Foundation

arc4random()

arc4random() % 6 + 1
arc4random_uniform(6) + 1

func arc4random_uniform(between a: UInt32, and b: UInt32) -> UInt32 {
    return arc4random_uniform(b + 1 - a) + a
}

arc4random_uniform(between: 1984, and: 2018)

enum Move: CaseIterable {
    case rock, paper, scissors
}

Move.allCases

Move.allCases[Int(arc4random_uniform(UInt32(Move.allCases.count)))]

func arc4random_uniform<A>(element xs: [A]) -> A {
    return xs[Int(arc4random_uniform(UInt32(xs.count)))]
}

arc4random_uniform(element: Move.allCases)

UInt32.random(in: 1984 ... 2018)
UInt32.random(in: .min ... .max)

UInt.random(in: 1984 ... 2018)
UInt.random(in: .min ... .max)

Int.random(in: 1984 ... 2018)
Int.random(in: .min ... .max)

print(Move.allCases.randomElement())
print([].randomElement())

Double.random(in: 0...1)
Bool.random()

// ended at 12:32 rethinking randomness

//: [Next](@next)
