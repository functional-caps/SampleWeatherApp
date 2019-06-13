//: [Previous](@previous)

import Foundation

struct Gen<A> {
    let run: () -> A
}

import Darwin
let random = Gen(run: arc4random)

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

extension Gen
where A: BinaryFloatingPoint, A.RawSignificand: FixedWidthInteger {
    
    static func float(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { .random(in: range) }
    }
}

import UIKit
Gen<CGFloat>.float(in: 0...1)

extension Gen where A: FixedWidthInteger {
    
    static func int(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { .random(in: range) }
    }
}

extension Gen where A == Bool {
    static let bool = Gen { .random() }
}

extension Gen {
    
    static func element(of xs: [A]) -> Gen<A?> {
        return Gen<A?> { xs.randomElement() }
    }
}

extension Gen {
    
    func array(of count: Gen<Int>) -> Gen<[A]> {
        return count.map { count in
            var array: [A] = []
            for _ in 1...count {
                array.append(self.run())
            }
            return array
        }
    }
}

func zip<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> {
        (ga.run(), gb.run())
    }
}

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { zip($0, $1).map(f) }
}

func zip4<A, B, C, D, Z>(with f: @escaping (A, B, C, D) -> Z) -> (Gen<A>, Gen<B>, Gen<C>, Gen<D>) -> Gen<Z> {
    return { a, b, c, d in
        Gen<Z> { f(a.run(), b.run(), c.run(), d.run()) }
    }
}

extension Gen {
    
    static func always(_ a: A) -> Gen<A> {
        return Gen { a }
    }
}

struct LCRNG: RandomNumberGenerator {
    
    var seed: UInt64
    
    init(seed: UInt64) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        seed = 2862933555777941757 &* seed &+ 3037000493
        return seed
    }
}



//: [Next](@next)
