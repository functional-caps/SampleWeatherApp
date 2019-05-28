//: [Previous](@previous)

import Foundation

struct Describing<A> {
    let describe: (A) -> String
}

struct PostgresConnInfo {
    let database: String
    let hostname: String
    let password: String
    let port: Int
    let user: String
}

let localPostgress = PostgresConnInfo(
    database: "development",
    hostname: "localhost",
    password: "",
    port: 5432,
    user: "admin")

let compactWitness = Describing<PostgresConnInfo> { conn in
    return "Postgres — database \(conn.database), hostname \(conn.hostname), password \(conn.password), port \(conn.port), user \(conn.user)"
}

compactWitness.describe(localPostgress)

let prettyWitness = Describing<PostgresConnInfo> { conn in
    """
    Postgres:
    - database \(conn.database)
    - hostname \(conn.hostname)
    - password \(conn.password)
    - port \(conn.port)
    - user \(conn.user)
    """
}

prettyWitness.describe(localPostgress)

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
    print("[\(tag)] \(witness.describe(value))")
}

print(tag: "debug", localPostgress, compactWitness)
print(tag: "debug", localPostgress, prettyWitness)

struct Combining<A> {
    let combine: (A, A) -> A
}

struct EmptyInitializing<A> {
    let create: () -> A
}

extension Array {
    func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
        return reduce(initial, combining.combine)
    }
}

let sum = Combining<Int>(combine: +)
let product = Combining<Int>(combine: *)

[1, 2, 3, 4].reduce(0, sum)
[1, 2, 3, 4].reduce(1, product)

extension Array {
    func reduce(_ initial: EmptyInitializing<Element>,
                _ combining: Combining<Element>) -> Element {
        return reduce(initial.create(), combining.combine)
    }
}

let zero = EmptyInitializing<Int> { 0 }
let one = EmptyInitializing<Int> { 1 }

[1, 2, 3, 4].reduce(zero, sum)
[1, 2, 3, 4].reduce(one, product)

extension Describing {
    func contramap<B>(_ f: @escaping (B) -> A) -> Describing<B> {
        return Describing<B> { b in self.describe(f(b)) }
    }
}

let secureCompactWitness = compactWitness.contramap { (conn: PostgresConnInfo) in
    PostgresConnInfo(database: conn.database,
                     hostname: conn.hostname,
                     password: "******",
                     port: conn.port,
                     user: conn.user)
}

print(tag: "debug", localPostgress, secureCompactWitness)

/*
 
 Exercise 1.
 
 Translate the Equatable protocol into an explicit datatype struct Equating.

 */

struct Equating<A> {
    let equal: (A, A) -> Bool
}

let equalInt = Equating<Int> { $0 == $1 }
equalInt.equal(1, 2)
equalInt.equal(1, 1)

/*
 
 Exercise 2.
 
 Currently in Swift (as of 4.2) there is no way to extend tuples to conform to protocols. Tuples are what is known as “non-nominal”, which means they behave differently from the types that you can define. For example, one cannot make tuples Equatable by implementing extension (A, B): Equatable where A: Equatable, B: Equatable. To get around this Swift implements overloads of == for tuples, but they aren’t truly equatable, i.e. you cannot pass a tuple of equatable values to a function wanting an equatable value.
 
 However, protocol witnesses have no such problem! Demonstrate this by implementing the function pair: (Combining<A>, Combining<B>) -> Combining<(A, B)>. This function allows you to construct a combining witness for a tuple given two combining witnesses for each component of the tuple.
 
 */

func pair<A, B>(_ a: Combining<A>, _ b: Combining<B>) -> Combining<(A, B)> {
    return Combining<(A, B)> { first, second in
        (a.combine(first.0, second.0), b.combine(first.1, second.1))
    }
}

let combineInt = Combining<Int> { $0 + $1 }
let combineString = Combining<String> { $0 + " plus " + $1 }

let combinePair = pair(combineInt, combineString)

combinePair.combine((1, "one"), (2, "two"))

/*
 
 Exercise 3.
 
 Functions in Swift are also “non-nominal” types, which means you cannot extend them to conform to protocols. However, again, protocol witnesses have no such problem! Demonstrate this by implementing the function pointwise: (Combining<B>) -> Combining<(A) -> B>. This allows you to construct a combining witness for a function given a combining witnesss for the type you are mapping into. There is exactly one way to implement this function.
 
 */

func pointwise<A, B>(_ combining: Combining<B>) -> Combining<(A) -> B> {
    return Combining<(A) -> B> { first, second in
        return { combining.combine(first($0), second($0)) }
    }
}

let combiningIntToString: Combining<(Int) -> String> = pointwise(combineString)

let firstIntToString: (Int) -> String = { int in String(int) }
let secondIntToString: (Int) -> String = { int in "here is int: \(int)" }

combiningIntToString.combine(firstIntToString, secondIntToString)(42)

/*
 
 Exercise 4.
 
 One of Swift’s most requested features was “conditional conformance”, which is what allows you to express, for example, the idea that an array of equatable values should be equatable. In Swift it is written extension Array: Equatable where Element: Equatable. It took Swift nearly 4 years after its launch to provide this capability!
 
 So, then it may come as a surprise to you to know that “conditional conformance” was supported for protocol witnesses since the very first day Swift launched! All you need is generics. Demonstrate this by implementing a function array: (Combining<A>) -> Combining<[A]>. This is saying that conditional conformance in Swift is nothing more than a function between protocol witnesses.

 */

func array<A>(_ combining: Combining<A>) -> Combining<[A]> {
    return Combining<[A]> { first, second in
        zip(first, second)
            .map { elem in combining.combine(elem.0, elem.1) }
    }
}

array(combineInt).combine([1, 2, 3], [1, 2, 3, 4])

/*
 
 Exercise 5.
 
 Currently all of our witness values are just floating around in Swift, which may make some feel uncomfortable. There’s a very easy solution: implement witness values as static computed variables on the datatype! Try this by moving a few of the witnesses from the episode to be static variables. Also try moving the pair, pointwise and array functions to be static functions on the Combining datatype.
 
 */

extension Int {
 
    static let zero = EmptyInitializing<Int> { 0 }
    static let one = EmptyInitializing<Int> { 1 }
    
    static let sum = Combining<Int>(combine: +)
    static let product = Combining<Int>(combine: *)
    
}

extension Combining {
    
    static func pair<A, B>(_ a: Combining<A>, _ b: Combining<B>) -> Combining<(A, B)> {
        return Combining<(A, B)> { first, second in
            (a.combine(first.0, second.0), b.combine(first.1, second.1))
        }
    }
    
    static func pointwise<A, B>(_ combining: Combining<B>) -> Combining<(A) -> B> {
        return Combining<(A) -> B> { first, second in
            return { combining.combine(first($0), second($0)) }
        }
    }
    
    static func array<A>(_ combining: Combining<A>) -> Combining<[A]> {
        return Combining<[A]> { first, second in
            zip(first, second)
                .map { elem in combining.combine(elem.0, elem.1) }
        }
    }
    
}

[1, 2, 3, 4].reduce(Int.zero, Int.sum)


/*
 
 Exercise 6.
 
 Protocols in Swift can have “associated types”, which are types specified in the body of a protocol but aren’t determined until a type conforms to the protocol. How does this translate to an explicit datatype to represent the protocol?
 
 */

protocol Transformable {
    associatedtype Output
    
    func transform() -> Output
}

extension Int: Transformable {
    func transform() -> String {
        return String(self)
    }
}

42.transform()

struct Transforming<A, Output> {
    let transform: (A) -> Output
}

let intTransforming = Transforming<Int, String> { String($0) }

intTransforming.transform(42)

/*
 
 Exercise 7.
 
 Translate the RawRepresentable protocol into an explicit datatype struct RawRepresenting. You will need to use the previous exercise to do this.
 
 */

public protocol RawRepresentable {
    
    associatedtype RawValue
    
    init?(rawValue: Self.RawValue)
    
    var rawValue: Self.RawValue { get }
}

struct RawRepresenting<A, RawValue> {
    let rawValue: (A) -> RawValue
    let create: (RawValue) -> A?
}

enum Test {
    case one, two, three
}

let testRepresenting = RawRepresenting<Test, Int>(
    rawValue: { test in
        switch test {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        }
    },
    create: { raw in
        switch raw {
        case 1: return .one
        case 2: return .two
        case 3: return .three
        default: return nil
        }
    }
)

testRepresenting.create(1)
testRepresenting.rawValue(.three)

/*
 
 Exercise 8.
 
 Protocols can inherit from other protocols, for example the Comparable protocol inherits from the Equatable protocol. How does this translate to an explicit datatype to represent the protocol?
 
 */

struct Comparing<A> {
    
    let equating: Equating<A>
    
    let isLess: (A, A) -> Bool
    let isLessOrEqual: (A, A) -> Bool
    let isMoreOrEqual: (A, A) -> Bool
    let isMore: (A, A) -> Bool
    
}

// I think it translates to composition

/*
 
 Exercise 9.
 
 Translate the Comparable protocol into an explicit datatype struct Comparing. You will need to use the previous exercise to do this.
 
 */

let comparingInt = Comparing<Int>(
    equating: equalInt, isLess: <, isLessOrEqual: <=, isMoreOrEqual: >=, isMore: >
)

comparingInt.equating.equal(1, 1)
comparingInt.equating.equal(1, 3)
comparingInt.isLess(1, 3)
comparingInt.isLessOrEqual(1, 3)
comparingInt.isMore(1, 3)
comparingInt.isMoreOrEqual(1, 3)

/*
 
 Exercise 10.
 
 We can combine the best of both worlds by using witnesses and having our default protocol, too. Define a DefaultDescribable protocol which provides a static member that returns a default witness of Describing<Self>. Using this protocol, define an overload of print(tag:) that doesn’t require a witness.
 
 */

protocol DefaultDescribable {
    static var defaultWitness: Describing<Self> { get }
}

func print<A: DefaultDescribable>(tag: String, _ value: A) {
    print(tag: tag, value, A.defaultWitness)
}

extension Int: DefaultDescribable {
    static var defaultWitness: Describing<Int> {
        return Describing<Int> { "int it is: \($0)" }
    }
}

print(tag: "prod", 42)

//: [Next](@next)
