//: [Previous](@previous)

import Foundation

struct Predicate<A> {
    let contains: (A) -> Bool
    func contramap<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
        return Predicate<B> { self.contains(f($0)) }
    }
    func pullback<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
        return Predicate<B> { self.contains(f($0)) }
    }
}

let isLessThan10 = Predicate { $0 < 10 }

isLessThan10.contramap { (s: String) in s.count }

isLessThan10.pullback { (s: String) in s.count }

struct Describing<A> {
    let describe: (A) -> String
}

extension Describing {
    func pullback<B>(_ f: @escaping (B) -> A) -> Describing<B> {
        return Describing<B> { b in self.describe(f(b)) }
    }
}

struct PostgresConnInfo {
    let database: String
    let hostname: String
    let password: String
    let port: Int
    let user: String
}

let compactWitness = Describing<PostgresConnInfo> { conn in
    return "Postgres — database \(conn.database), hostname \(conn.hostname), password \(conn.password), port \(conn.port), user \(conn.user)"
}


let secureCompactWitness = compactWitness.pullback { (conn: PostgresConnInfo) in
    PostgresConnInfo(database: conn.database,
                     hostname: conn.hostname,
                     password: "******",
                     port: conn.port,
                     user: conn.user)
}

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

struct Combining<A> {
    let combine: (A, A) -> A
}

struct EmptyInitializing<A> {
    let create: () -> A
}

let zero = EmptyInitializing<Int> { 0 }
let one = EmptyInitializing<Int> { 1 }

let sum = Combining<Int>(combine: +)
let product = Combining<Int>(combine: *)

extension Array {
    func reduce(_ initial: EmptyInitializing<Element>,
                _ combining: Combining<Element>) -> Element {
        return reduce(initial.create(), combining.combine)
    }
}

[1, 2, 3, 4].reduce(zero, sum)
[1, 2, 3, 4].reduce(one, product)

//extension Combining where A == Int {
//    static let sum = Combining(combine: +)
//    static let product = Combining(combine: +)
//}
//
//extension EmptyInitializing where A == Int {
//    static let zero = EmptyInitializing { 0 }
//    static let one = EmptyInitializing { 1 }
//}

extension Combining where A: Numeric {
    static var sum: Combining { return Combining(combine: +) }
    static var product: Combining { return Combining(combine: +) }
}

extension EmptyInitializing where A: Numeric {
    static var zero: EmptyInitializing { return EmptyInitializing { 0 } }
    static var one: EmptyInitializing { return EmptyInitializing { 1 } }
}

[1, 2, 3, 4].reduce(EmptyInitializing.zero, Combining.sum)
[1, 2, 3, 4].reduce(.zero, .sum)

extension Describing where A == PostgresConnInfo {
    
    static let compact = Describing { conn in
        return "Postgres — database \(conn.database), hostname \(conn.hostname), password \(conn.password), port \(conn.port), user \(conn.user)"
    }

    static let pretty = Describing { conn in
        """
        Postgres:
        - database \(conn.database)
        - hostname \(conn.hostname)
        - password \(conn.password)
        - port \(conn.port)
        - user \(conn.user)
        """
    }
    
}

let localPostgress = PostgresConnInfo(
    database: "development",
    hostname: "localhost",
    password: "",
    port: 5432,
    user: "admin")

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
    print("[\(tag)] \(witness.describe(value))")
}

print(tag: "debug", localPostgress, .pretty)

extension Describing where A == Bool {
    static let compact = Describing { $0 ? "t" : "f" }
    static let pretty = Describing { $0 ? "true" : "false" }
}

print(tag: "debug", true, .compact)
print(tag: "debug", true, .pretty)

//extension Array: Equatable where Element: Equatable {
//
//}

struct Equating<A> {
    let equal: (A, A) -> Bool
}

let equalInt = Equating<Int> { $0 == $1 }
equalInt.equal(1, 2)
equalInt.equal(1, 1)

extension Equating where A == Int {
    static let int = Equating(equal: ==)
}

extension Equating {

    static func array(of equating: Equating) -> Equating<[A]> {
        return Equating<[A]> { first, second in
            guard first.count == second.count else { return false }
            for (lhs, rhs) in zip(first, second) {
                if !equating.equal(lhs, rhs) {
                    return false
                }
            }
            return true
        }
    }
}

Equating.array(of: .int).equal([], [])
Equating.array(of: .int).equal([1], [])
Equating.array(of: .int).equal([1], [1])
Equating.array(of: .int).equal([1], [1, 2])

extension Equating {
    func pullback<B>(_ f: @escaping (B) -> A) -> Equating<B> {
        return Equating<B> { lhs, rhs in
            self.equal(f(lhs), f(rhs))
        }
    }
}

let stringCount: Equating<String> = Equating.int.pullback { $0.count }

Equating.array(of: stringCount).equal(["Blob"], [""])
Equating.array(of: stringCount).equal(["Blob"], ["Blob"])

let nestedIntArrays = (Equating.array >>> Equating.array)(.int)

nestedIntArrays.equal([[1, 2], [3, 4]], [[1, 2], [3]])
nestedIntArrays.equal([[1, 2], [3, 4]], [[1, 2], [3, 4]])

let nestedStringArrays = (Equating.array >>> Equating.array)(stringCount)


/*
 
 Exercise 1.
 
 Currently in Swift (as of 4.2) there is no way to extend tuples to conform to protocols. Tuples are what is known as “non-nominal”, which means they behave differently from the types that you can define. For example, one cannot make tuples Equatable by implementing extension (A, B): Equatable where A: Equatable, B: Equatable. To get around this Swift implements overloads of == for tuples, but they aren’t truly equatable, i.e. you cannot pass a tuple of equatable values to a function wanting an equatable value.
 
 However, protocol witnesses have no such problem! Demonstrate this by implementing the function pair: (Combining<A>, Combining<B>) -> Combining<(A, B)>. This function allows you to construct a combining witness for a tuple given two combining witnesses for each component of the tuple.
 
 */



/*
 
 Exercise 2.
 
 Functions in Swift are also “non-nominal” types, which means you cannot extend them to conform to protocols. However, again, protocol witnesses have no such problem! Demonstrate this by implementing the function pointwise: (Combining<B>) -> Combining<(A) -> B>. This allows you to construct a combining witness for a function given a combining witnesss for the type you are mapping into. There is exactly one way to implement this function.
 
 */



/*
 
 Exercise 3.
 
 Protocols in Swift can have “associated types”, which are types specified in the body of a protocol but aren’t determined until a type conforms to the protocol. How does this translate to an explicit datatype to represent the protocol?
 
 */



/*
 
 Exercise 4.
 
 Translate the RawRepresentable protocol into an explicit datatype struct RawRepresenting. You will need to use the previous exercise to do this.
 
 */



/*
 
 Exercise 5.
 
 Protocols can inherit from other protocols, for example the Comparable protocol inherits from the Equatable protocol. How does this translate to an explicit datatype to represent the protocol?
 
 */



/*
 
 Exercise 6.
 
 Translate the Comparable protocol into an explicit datatype struct Comparing. You will need to use the previous exercise to do this.
 
 */



//: [Next](@next)
