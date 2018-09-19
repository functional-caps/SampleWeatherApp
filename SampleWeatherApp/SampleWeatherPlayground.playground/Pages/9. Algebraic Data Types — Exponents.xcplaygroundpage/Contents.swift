//: [Previous](@previous)

/*

 Exercises 1:

 Prove the equivalence of 1^a = 1 as types. This requires re-expressing this algebraic equation as types, and then defining functions between the types that are inverses of each other.

 Answer 1:

 1^a = 1
 1 * 1 * 1 * 1 * 1 ... = 1
 A -> Void = Void

 */

func exercise1<A>(_ a: A) -> Void {
    return ()
}

/*

 Exercises 2:

 What is 0^a? Prove an equivalence. You will need to consider a = 0 and a != 0 separately.

 Answer 2:

 0^a = 0
 A -> Never

 if a == 0:
 Never -> Never

 if a != 0:
 A -> Never

 */

func exercise2(_ never: Never) -> Never {
    switch never {}
}

func exercise2<A>(_ a: A) -> Never {
    fatalError()
}

/*

 Exercises 3:

 How do you think generics fit into algebraic data types? We’ve seen a bit of this with thinking of Optional<A> as A + 1 = A + Void.

 Answer 3:

 */

struct Some<A> {
    let a: A
    let b: Bool
}
// A * Bool = A * 2

struct Some2<A, B> {
    let a: A
    let b: B
}
// A * B

enum Some3<A, B> {
    case a(A)
    case b(B)
}
// A + B

func exercise3<A>(_ a: A) -> Bool {
    return true
}
// Bool^A

// Generics are the variables in the algebraic data types equasions?

/*

 Exercises 4:

 Show that sets with values in A can be represented as 2^A. Note that A does not require any Hashable constraints like the Swift standard library Set<A> requires.

 Answer 4:

 */

var set: Set<Int> = []
set.contains

func s(_ value: Int) -> Bool {
    return set.contains(value)
}

// set is a mapping from the space of possible values (A) to space of whether it's been hold by set or not (Bool)
// function (A) -> Bool is a mapping from the space of possible values (A) to space of Bool
// they are the same

// Set<Int> == => Bool^Int = 2^Int
// Set<A> => Bool^A = 2^A

/*

 Exercises 5:

 Define intersection and union functions for the above definition of set.

 Answer 5:

 Intersection == take the common part of two sets
 Union == join two sets together

 so, given two functions:
 s1: (a: A) -> Bool
 s2: (a: A) -> Bool

 Intersection is a such that
 s1(a) == true && s2(a) == true

 Union is such that
 s1(a) == true || s2(a) == true

 */

 func intersection<A>(s1: @escaping (A) -> Bool, s2: @escaping (A) -> Bool) -> (A) -> Bool {
    return { a in s1(a) && s2(a) }
 }

 func union<A>(s1: @escaping (A) -> Bool, s2: @escaping (A) -> Bool) -> (A) -> Bool {
    return { a in s1(a) || s2(a) }
 }

/*

 Exercises 6:

 How can dictionaries with keys in K and values in V be represented algebraically?

 Answer 6:

 dictionaries are mappings from the space of keys (K) to the space of optional values (V + 1)

 K -> (V + 1)
 (V + 1)^K

 */

/*

 Exercises 7:

 Implement the following equivalence:

 func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
 fatalError()
 }

 func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
 fatalError()
 }

 Answer 7:

 */

// A ^ (B + C) == A ^ B * A ^ C

 func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
    return (
        { b in f(Either<B, C>.left(b)) },
        { c in f(Either<B, C>.right(c)) }
    )
 }

 func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
    return { either in
        switch either {
        case .left(let b): return f.0(b)
        case .right(let c): return f.1(c)
        }
    }
 }

/*

 Exercises 8:

 Implement the following equivalence:

 func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
 fatalError()
 }

 func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
 fatalError()
 }

 Answer 8:

 */

// (A * B) ^ C == A ^ C * B ^ C

struct S {
    let a: Int
    let b: Int

    func foo() {}
}

// S == Int * Int
func foo(s: S) {}

// Int * Int
func foo(a: Int, b: Int) {}

 func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
     return (
         { c in f(c).0 },
         { c in f(c).1 }
     )
 }

 func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
     return { c in (f.0(c), f.1(c)) }
 }

//: [Next](@next)
