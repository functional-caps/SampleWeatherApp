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

arc4random

//let uniform = arc4random >>> { Double($0) / Double(UInt32.max) }
//uniform(())

struct Gen<A> {
    let run: () -> A
}

let random = Gen(run: arc4random)
random.run()

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

random.map(String.init).run()

let uniform = random.map { Double($0) / Double(UInt32.max) }
uniform.run()

func double(in range: ClosedRange<Double>) -> Gen<Double> {
    return uniform.map { t in
        t * (range.upperBound - range.lowerBound) + range.lowerBound
    }
}

double(in: 2...10).run()

let uint64: Gen<UInt64> = .init {
    let lower = UInt64(random.run())
    let upper = UInt64(random.run()) << 32
    return upper + lower
}

uint64.run()
uint64.run()
uint64.run()

func int(in range: ClosedRange<Int>) -> Gen<Int> {
    return .init { Int.random(in: range) } // this is alternative implementation
}

int(in: -2...10).run()

let roll = int(in: 1...6)
roll.run()

let bool = int(in: 0...1).map { $0 == 1 }
bool.run()

func element<A>(of xs: [A]) -> Gen<A?> {
    return int(in: 0...(xs.count - 1)).map { index in
        guard !xs.isEmpty else { return nil }
        return xs[index]
    }
}

let move = element(of: Move.allCases).map { $0! }
move.run()

extension Gen {
    func array(count: Int) -> Gen<[A]> {
        return Gen<[A]> {
            Array(repeating: (), count: count).map(self.run)
        }
    }
    
    func array(count: Gen<Int>) -> Gen<[A]> {
//        return Gen<[A]> {
//            Array(repeating: (), count: count.run()).map(self.run)
//        }
        return count.map { self.array(count: $0).run() }
    }
}

let rollPair = roll.array(count: 2)
rollPair.run()

let fewMoves = move.array(count: int(in: 0...3))
fewMoves.run()

let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

let alphanum = element(of: chars).map { $0! }

let passwordSegment = alphanum.array(count: .init { 6 })
    .map { $0.map(String.init).joined() }

let password = passwordSegment.array(count: .init { 3 })
    .map { $0.joined(separator: "-") }

password.run()

/*

 Exercise 1.
 
 Create a function called frequency that takes an array of pairs, [(Int, Gen<A>)], to create a Gen<A> such that (2, gen) is twice as likely to be run than a (1, gen).
 
 */

func frequency<A>(_ weights: [(Int, Gen<A>)]) -> Gen<A?> {
    return Gen<A?> {
        let gens = weights.map { Array(repeating: $1, count: $0) }.flatMap { $0 }
        return element(of: gens).run()?.run()
    }
}

frequency([(1, .init { 1 }), (10, .init { 10 }), (10, .init { 100 })]).run()

/*

 Exercise 2.
 
 Extend Gen with an optional computed property that returns a generator that returns nil a quarter of the time. What other generators can you compose this from?
 
 */

extension Gen {
    var quarterNil: Gen<A?> {
        let weights = [(3, self.map { A?.some($0) }), (1, .init { A?.none })]
        return frequency(weights).map { $0?.flatMap { $0 } }
    }
}

int(in: 1...3).quarterNil.run()
int(in: 1...3).quarterNil.run()
int(in: 1...3).quarterNil.run()
int(in: 1...3).quarterNil.run()
int(in: 1...3).quarterNil.run()

/*

 Exercise 3.
 
 Extend Gen with a filter method that returns a generator that filters out random entries that don’t match the predicate. What kinds of problems may this function have?
 
 */

extension Gen {
    func filter(_ predicate: @escaping (A) -> Bool) -> Gen<A> {
        return Gen<A> {
            var value = self.run()
            while(!predicate(value)) {
               value = self.run()
            }
            return value
        }
    }
}

let evens = int(in: 0...10).filter { $0 % 2 == 0 }
evens.run()
evens.run()
evens.run()
evens.run()

// the problems:
// 1. what to do if the predicate doesn't ever pass the value? should it just keep trying forever? should it fatalError after a number of tries?
// 2. what if you're really really really unlucky and your generator never ever will produce the value that passes predicate? should it fatalError after a number of tries?
// alternative - it might also just return optional value and let the client worry

/*

 Exercise 4.
 
 Create a string generator of type Gen<String> that randomly produces a randomly-sized string of any unicode character. What smaller generators do you composed it from?
 
 */

let characterGen = frequency([
        (1, int(in: 0...55295)),
        (1, int(in: 57344...1114111))
    ])
    .map { $0! }
    .map { Unicode.Scalar($0) }
    .filter { $0 != nil }
    .map { $0! }
    .map { String(Character($0)) }
    .array(count: int(in: 0...10))
    .map { $0.joined() }

characterGen.run()
characterGen.run()
characterGen.run()

// it's composed out of int generators

/*

 Exercise 5.
 
 Redefine element(of:) to work with any Collection. Can it also be redefined in terms of Sequence?
 
 */

//func element<A>(of xs: [A]) -> Gen<A?> {
//    return int(in: 0...(xs.count - 1)).map { index in
//        guard !xs.isEmpty else { return nil }
//        return xs[index]
//    }
//}

func element<C: Collection>(of: C) -> Gen<C.Element?> {
    return int(in: 0...(of.count - 2))
        .map { of.dropFirst($0).first }
}

let elementUpa = element(of: ["dupa" : 1, "zupa" : 2, "pupa" : 3])
elementUpa.run()
elementUpa.run()

// it cannot be redefined in terms of sequence because
// the sequences doesn't need to be finite. and if the sequence is
// not finite, you canot get the arbitrary element with
// the known probability. probability is approaching zero

/*

 Exercise 6.
 
 Create a subsequence generator to return a randomly-sized, randomly-offset subsequence of an array. Can it be redefined in terms of Collection?
 
 */

func subsequence<A>(of array: [A]) -> Gen<[A]> {
    return Gen<[A]> {
        if array.isEmpty { return array }
        let size = int(in: 0...(array.count - 1)).run()
        let offset = int(in: 0...(array.count - 1 - size)).run()
        let slice = array[offset...(size + offset)]
        return Array(slice)
    }
}

let someInts = subsequence(of: [1, 2, 3, 4, 5, 6, 7, 8])
someInts.run()
someInts.run()
someInts.run()
someInts.run()
someInts.run()
someInts.run()
someInts.run()

func subsequence<C: Collection>(of collection: C) -> Gen<C.SubSequence> {
    return Gen<C.SubSequence> {
        if collection.isEmpty { return collection.prefix(0) }
        let size = int(in: 0...(collection.count - 1)).run()
        print("size \(size)")
        let offset = int(in: 0...(collection.count - 1 - size)).run()
        print("offset \(offset)")
        return collection.dropFirst(offset).prefix(size)
    }
}

let subsequenceUpa = subsequence(of: ["dupa" : 1, "zupa" : 2, "pupa" : 3])
print(Array(subsequenceUpa.run()))
print(Array(subsequenceUpa.run()))
print(Array(subsequenceUpa.run()))
print(Array(subsequenceUpa.run()))

/*

 Exercise 7.
 
 The Gen type has map defined it, which, as we’ve seen in the past, allows us to consider what zip might look like. Define zip2 on Gen:
 
 func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)>
 
 */

func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> { return (ga.run(), gb.run()) }
}

zip2(int(in: 0...10), int(in: 100...200)).run()

/*

 Exercise 8.
 
 Define zip2(with:):
 
 func zip2<A, B, C>(with f: (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C>
 
 */

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { ga, gb in
        return Gen<C> { return f(ga.run(), gb.run()) }
    }
}

zip2(with: +)(int(in: 0...10), int(in: 100...200)).run()

/*

 Exercise 9.
 
 With zip2 and zip2(with:) defined, define higher-order zip3 and zip3(with:) and explore some uses. What functionality does zip provide our Gen type?
 
 */

func zip3<A, B, C>(_ ga: Gen<A>, _ gb: Gen<B>, _ gc: Gen<C>) -> Gen<(A, B, C)> {
    return Gen<(A, B, C)> { return (ga.run(), gb.run(), gc.run()) }
}

zip3(int(in: 0...10), int(in: 100...200), int(in: 1000...2000)).run()

func zip3<A, B, C, D>(with f: @escaping (A, B, C) -> D)
    -> (Gen<A>, Gen<B>, Gen<C>) -> Gen<D> {
    return { ga, gb, gc in
        return Gen<D> { return f(ga.run(), gb.run(), gc.run()) }
    }
}

zip3(with: { $0 + $1 + $2 })(
        int(in: 0...10), int(in: 100...200), int(in: 1000...2000)
    )
    .run()

//: [Next](@next)
