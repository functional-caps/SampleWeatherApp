//: [Previous](@previous)

import Foundation

func combos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    return xs.flatMap { x in
        ys.map { y in
            (x, y)
        }
    }
}

print(combos([1, 2, 3], ["a", "b"]))

let scores = """
             1,2,3,4
             5,6
             7,8,9
             """

let allScores = scores.split(separator: "\n").flatMap { row in
    row.split(separator: ",")
}

print(allScores)

let strings = ["42", "Blob", "functions"]

strings.first
type(of: strings.first)

strings.first.flatMap(Int.init)
type(of: strings.first.flatMap(Int.init))

enum Result<A, E> {
    case success(A)
    case failure(E)
    
    func map<B>(_ f: @escaping (A) -> B) -> Result<B, E> {
        switch self {
        case let .success(a): return .success(f(a))
        case let .failure(e): return .failure(e)
        }
    }
}

Result<Double, String>.success(42)
    .map { $0 + 1 }

func compute(_ a: Double, _ b: Double) -> Result<Double, String> {
    guard a >= 0 else { return .failure("non negative!") }
    guard b != 0 else { return .failure("non-zero") }
    return .success(sqrt(a) / b)
}

compute(-1, 123)
compute(42, 0)

let computed = compute(42, 17).map { compute($0, $0) }
print(type(of: computed))

public typealias NonEmptyArray<A> = NonEmpty<Array<A>>

enum Validated<A, E> {
    case valid(A)
    case invalid(NonEmptyArray<E>)
    
    func map<B>(_ f: @escaping (A) -> B) -> Validated<B, E> {
        switch self {
        case let .valid(a): return .valid(f(a))
        case let .invalid(e): return .invalid(e)
        }
    }
}

struct Func<A, B> {
    let run: (A) -> B
    func map<C>(_ f: @escaping (B) -> C) -> Func<A, C> {
//        return Func<A, C> { a in
//            f(self.run(a))
//        }
        return Func<A, C>(run: self.run >>> f)
    }
}

// nesting problem again

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
    
    func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in callback(f(a)) }
        }
    }
}

func delay(by duration: TimeInterval, line: UInt = #line) -> Parallel<Void> {
    return Parallel { callback in
        print("Delaying line \(line) by duration \(duration)")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            callback(())
            print("Executed line \(line)")
        }
    }
}

delay(by: 1).run { print("Executed after 1 second") }
delay(by: 2).run { print("Executed after 2 seconds") }

let aDelayedInt = delay(by: 3).map { 42 }
aDelayedInt.run { print($0) }

aDelayedInt.map { value in
    delay(by: 1).map { value + 12 }
}.run { innerParallel in
    innerParallel.run {
        print($0)
    }
}

/*
 
 Exercise 1.
 
 In this episode we saw that the combos function on arrays can be implemented in terms of flatMap and map. The zip function on arrays as the same signature as combos. Can zip be implemented in terms of flatMap and map?
 
 */

func zipA<A, B, C>(_ a: [A], _ b: [B], combine: (Int, A, Int, B) -> [C]) -> [C] {
    return a.enumerated().flatMap { indexA, elemA in
        return b.enumerated().flatMap { indexB, elemB in
            combine(indexA, elemA, indexB, elemB)
        }
    }
}

let arrayZ = zipA([1, 2, 3], ["a", "b", "c", "d"]) { indexA, a, indexB, b -> [(Int, String)] in
    if indexA == indexB { return [(a, b)] } else { return [] }
}

print(arrayZ)

// it cannot really be written with just flatmap and map
// you need to use enumerated() for it
// and also special shape of combine function that takes the indices

/*
 
 Exercise 2.
 
 Define a flatMap method on the Result<A, E> type. Its signature looks like:
 (Result<A, E>, (A) -> Result<B, E>) -> Result<B, E>
 It only changes the A generic while leaving the E fixed.
 
 */

extension Result {
    func flatMap<B>(_ f: @escaping (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case .success(let a): return f(a)
        case .failure(let e): return .failure(e)
        }
    }
}

let computed2 = compute(42, 17).flatMap { compute($0, $0) }
print(type(of: computed2))

/*
 
 Exercise 3.
 
 Can the zip function we defined on Result<A, E> in episode #24 be implemented in terms of the flatMap you implemented above? If so do it, otherwise explain what goes wrong.
 
 */

func zipR<A, B, C, E>(
    _ l: Result<A, E>, _ r: Result<B, E>, _ combine: @escaping (A, B) -> C
) -> Result<C, E> {
    return l.flatMap { a in
        return r.map { b in
            return combine(a, b)
        }
    }
}

let resultZ = zipR(compute(21, 1.7), compute(4, 27)) { ($0, $1) }
resultZ

/*
 
 Exercise 4.
 
 Define a flatMap method on the Validated<A, E> type. Its signature looks like:
 (Validated<A, E>, (A) -> Validated<B, E>) -> Validated<B, E>
 It only changes the A generic while leaving the E fixed. How similar is it to the flatMap you defined on Result?
 
 */

extension Validated {
    func flatMap<B>(_ f: @escaping (A) -> Validated<B, E>) -> Validated<B, E> {
        switch self {
        case .valid(let a): return f(a)
        case .invalid(let e): return .invalid(e)
        }
    }
}

// very similar to result

let validated = Validated<Int, Int>.valid(42)
    .flatMap { Validated<Int, Int>.valid($0 + 1) }
print(type(of: validated))

/*
 
 Exercise 5.
 
 Can the zip function we defined on Validated<A, E> in episode #24 be defined in terms of the flatMap above? If so do it, otherwise explain what goes wrong.
 
 */

func zipV<A, B, C, E>(
    _ l: Validated<A, E>, _ r: Validated<B, E>, _ combine: @escaping (A, B) -> C
) -> Validated<C, E> {
    return l.flatMap { a in
        return r.map { b in combine(a, b) }
    }
}

let val1 = Validated<Int, Int>.valid(42)
let val2 = Validated<Int, Int>.valid(1)

let validatedZ = zipV(val1, val2) { $0 + $1 }
validatedZ

/*
 
 Exercise 6.
 
 Define a flatMap method on the Func<A, B> type. Its signature looks like:
 (Func<A, B>, (B) -> Func<A, C>) -> Func<A, C>
 It only changes the B generic while leaving the A fixed.
 
 */

extension Func {
    func flatMap<C>(_ f: @escaping (B) -> Func<A, C>) -> Func<A, C> {
        return Func<A, C> { (a) -> C in
            return f(self.run(a)).run(a)
        }
    }
}

let function = Func<Int, String> { (int) -> String in "\(int)" }
function.run(42)

/*
 
 Exercise 7.
 
 Can the zip function we defined on Func<A, B> in episode #24 be implemented in terms of the flatMap you implemented above? If so do it, otherwise explain what goes wrong.
 
 */

func zipF<A, B, C, D>(
    _ l: Func<A, B>, _ r: Func<A, C>, combine: @escaping (B, C) -> D
) -> Func<A, D> {
    return l.flatMap { (b) -> Func<A, D> in
        return r.map { c in combine(b, c) }
    }
}

let f1 = Func<String, Int> { (string) -> Int in Int(string)! }
let f2 = Func<String, Double> { (double) -> Double in Double(double)! }

let funcZ = zipF(f1, f2) { $0 + Int($1) }
funcZ.run("42")

/*
 
 Exercise 8.
 
 Define a flatMap method on the Parallel<A> type. Its signature looks like:
 (Parallel<A>, (A) -> Parallel<B>) -> Parallel<B>
 
 */

extension Parallel {
    func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in
                f(a).run { b in
                    callback(b)
                }
            }
        }
    }
}

let parallel = Parallel<Int> { callback in callback(42) }
    .flatMap { (int) in
        return Parallel<String> { callback in
            callback("\(int)")
        }
    }

parallel.run { print("\($0)") }

aDelayedInt.flatMap { value in
    delay(by: 1).map { value + 12 }
}.run { print($0) }

/*
 
 Exercise 9.
 
 Can the zip function we defined on Parallel<A> in episode #24 be implemented in terms of the flatMap you implemented above? If so do it, otherwise explain what goes wrong.
 
 */

func zipP<A, B, C>(
    _ l: Parallel<A>, _ r: Parallel<B>, combine: @escaping (A, B) -> C
) -> Parallel<C> {
    return l.flatMap { a -> Parallel<C> in
        return r.map { b in combine(a, b) }
    }
}

let parallel1 = delay(by: 2).map { "elo" }
let parallel2 = delay(by: 1).map { 42 }

let parallelZ = zipP(parallel1, parallel2) { a, b in a + " " + String(b) }

parallelZ.run { print($0) }

//: [Next](@next)
