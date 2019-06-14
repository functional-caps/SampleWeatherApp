//: [Previous](@previous)

import Foundation

struct AnyRandomNumberGenerator: RandomNumberGenerator {
    var rng: RandomNumberGenerator
    
    mutating func next() -> UInt64 {
        return rng.next()
    }
}

struct Gen<A> {
    internal let runClosure: (inout AnyRandomNumberGenerator) -> A
    
    func run<RNG: RandomNumberGenerator>(using: inout RNG) -> A {
        var arng = AnyRandomNumberGenerator(rng: using)
        let result = self.runClosure(&arng)
        using = arng.rng as! RNG
        return result
    }
}

extension Gen {
    func flatMap<B>(_ f: @escaping (A) -> Gen<B>) -> Gen<B> {
        return Gen<B> { rng in
            let a = self.runClosure(&rng)
            let genB = f(a)
            let b = genB.runClosure(&rng)
            return b
        }
    }
}

import Darwin

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { rng in f(self.run(using: &rng)) }
    }
}

var globalRNG = SystemRandomNumberGenerator()

extension Gen
where A: BinaryFloatingPoint, A.RawSignificand: FixedWidthInteger {
    
    static func float(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { rng in
            return .random(in: range, using: &rng)
        }
    }
}

import UIKit
Gen<CGFloat>.float(in: 0...1)

extension Gen where A: FixedWidthInteger {
    
    static func int(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { rng in
            return A.random(in: range, using: &rng)
        }
    }
}

extension Gen where A == Bool {
    static func bool() -> Gen<Bool> {
        return Gen { rng in
            return .random(using: &rng)
        }
    }
}

extension Gen {
    
    static func element(of xs: [A]) -> Gen<A?> {
        return Gen<A?> { rng in
            return xs.randomElement(using: &rng) }
    }
}

extension Gen {
    func array(of count: Gen<Int>) -> Gen<[A]> {
        return count.flatMap { count in
            return Gen<[A]> { rng -> [A] in
                var array: [A] = []
                for _ in 1...count {
                    array.append(self.runClosure(&rng))
                }
                return array
            }
        }
    }
}

func zip<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> { rng in
        (ga.runClosure(&rng), gb.runClosure(&rng))
    }
}

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { zip($0, $1).map(f) }
}

func zip4<A, B, C, D, Z>(with f: @escaping (A, B, C, D) -> Z) -> (Gen<A>, Gen<B>, Gen<C>, Gen<D>) -> Gen<Z> {
    return { a, b, c, d in
        Gen<Z> { rng in
            f(a.runClosure(&rng), b.runClosure(&rng), c.runClosure(&rng), d.runClosure(&rng))
        }
    }
}

extension Gen {
    
    static func always(_ a: A) -> Gen<A> {
        return Gen { _ in a }
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

var srng = SystemRandomNumberGenerator()

//globalRNG = LCRNG(seed: 0)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)

//globalRNG = LCRNG(seed: 0)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)
Gen<Int>.int(in: 0...100).run(using: &globalRNG)

/*
 
 Exercise 1.
 
 We’ve all but completely recovered the ergonomics of Gen from before we controlled it, but our public run function requires an explicit RandomNumberGenerator is passed in as a dependency. Add an overload to recover the ergonomics of calling gen.run() without a RandomNumberGenerator.
 
 */

extension Gen {
    func run() -> A {
        var srng = SystemRandomNumberGenerator()
        return self.run(using: &srng)
    }
}

Gen.bool().run()

/*
 
 Exercise 2.
 
 The Gen type perfectly encapsulates producing a random value from a given mutable random number generator. Generalize Gen to a type State that produces values from a given mutable parameter.
 
 */

struct State<Parameter, Value> {
    let run: (inout Parameter) -> Value
}

/*
 
 Exercise 3.
 
 Recover Gen as a specification of State using a type alias.
 
 */

typealias GenState<A> = State<AnyRandomNumberGenerator, A>

extension State where Parameter == AnyRandomNumberGenerator {
    func run<RNG: RandomNumberGenerator>(using: inout RNG) -> Value {
        var arng = AnyRandomNumberGenerator(rng: using)
        let result = self.run(&arng)
        using = arng.rng as! RNG
        return result
    }
}

/*
 
 Exercise 4.
 
 Deriving Gen as a type alias of State breaks a bunch of implementations, including:
 
 map
 flatMap
 int(in:)
 float(in:)
 bool
 Update each implementation for State.
 
 */

extension State {
    
    func map<B>(_ f: @escaping (Value) -> B) -> State<Parameter, B> {
        return State<Parameter, B> { parameter in
            return f(self.run(&parameter))
        }
    }
    
    func flatMap<B>(
        _ f: @escaping (Value) -> State<Parameter, B>
    ) -> State<Parameter, B> {
        return State<Parameter, B> { parameter in
            let stateB = f(self.run(&parameter))
            return stateB.run(&parameter)
        }
    }
}

extension GenState where Value: FixedWidthInteger {
    
    static func int(
        in range: ClosedRange<Value>
    ) -> GenState<Value> {
        return GenState { rng in
            return .random(in: range, using: &rng)
        }
    }
}

extension GenState
    where Value: BinaryFloatingPoint,
          Value.RawSignificand: FixedWidthInteger {
    
    static func float(
        in range: ClosedRange<Value>
    ) -> GenState<Value> {
        return GenState { rng in
            .random(in: range, using: &rng)
        }
    }
}

extension GenState where Value == Bool {
    static func bool() -> GenState<Bool> {
        return GenState { rng in
            return .random(using: &rng)
        }
    }
}

GenState<Bool>.bool().run(using: &srng)

//: [Next](@next)
