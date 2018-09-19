//: [Previous](@previous)

/*

 Exercise 1:

 We previously saw that functions (inout A) -> Void and functions (A) -> Void where A: AnyObject can be composed the same way. Write mver, mut, and ^ in terms of AnyObject. Note that there is a specific subclass of WritableKeyPath for reference semantics.

 Answer 1:

 */

class ReferenceProperty {
    let name: String
    init(_ name: String) {
        self.name = name
    }
}

class ReferenceTester {
    var property = ReferenceProperty("Tester")
    deinit {
        print("deinitialized tester")
    }
}

typealias ReferenceSetter<S, A> = (@escaping (A) -> A) -> (S) -> Void where A: AnyObject

func rver<S, A>(
    _ setter: ReferenceSetter<S, A>,
    _ set: @escaping (A) -> A
    )
    -> (S) -> Void where A: AnyObject {
    return setter(set)
}

func rut<S, A>(
    _ setter: ReferenceSetter<S, A>,
    _ value: A
    )
    -> (S) -> Void where A: AnyObject {
    return rver(setter) { _ in value }
}

prefix func ^ <Root, Value>(
    _ kp: ReferenceWritableKeyPath<Root, Value>
    )
    -> (@escaping (Value) -> Value)
    -> (Root) -> Void where Value: AnyObject {

    return { (update: @escaping (Value) -> Value) in
        return { (root: Root) in
            root[keyPath: kp] = update(root[keyPath: kp])
        }
    }
}

let test = ReferenceTester()
\ReferenceTester.property
test
    |> rut(^\ReferenceTester.property, ReferenceProperty("Elo"))
dump(test)

// HAD TO CHANGE SETTERS SIGNATURE TO USE (@escaping (A) -> A)
// OTHERWISE COULDN'T UPDATE THE ROOT VALUE

/*

 Exercise 2:

 Our episode on UIKit styling was nothing more than setters in disguise! Explore building some of the styling functions we covered using both immutable and mutable setters, specifically how setters compose over sub-typing in Swift, and how setters compose between roots that are reference types, and values that are value types.

 Answer 2:

 */

// ???

/*

 Exercise 3:

 We’ve explored <>/concat as single-type composition, but this doesn’t mean we’re limited to a single generic parameter! Write a version of <>/concat that allows for composition of value transformations of the same input and output type. This should allow for prop(\UIEdgeInsets.top) <> prop(\.bottom) as a way of assigning both top and bottom the same value at once.

 Answer 3:

 */

typealias SingleSetter<Root, Value> =
    Setter<Root, Root, Value, Value>

func concat<Root, Value>(lhs: @escaping SingleSetter<Root, Value>,
                         rhs: @escaping SingleSetter<Root, Value>
                        ) -> SingleSetter<Root, Value> {
    return { (update: @escaping (Value) -> Value) in
        return { (root: Root) in
            let lhsUpdate = lhs(update)
            let rhsUpdate = rhs(update)
            var newRoot = lhsUpdate(root)
            newRoot = rhsUpdate(newRoot)
            return newRoot
        }
    }
}

func <> <Root, Value>(
    lhs: @escaping SingleSetter<Root, Value>,
    rhs: @escaping SingleSetter<Root, Value>
    ) -> SingleSetter<Root, Value> {
    return concat(lhs: lhs, rhs: rhs)
}

import UIKit

UIEdgeInsetsMake(0, 0, 0, 0)
    |> (prop(\UIEdgeInsets.top) <> prop(\.bottom)) { _ in 100 }

/*

 Exercise 4:

 Define an operator-free version of setters using with and concat from our episode on composition without operators. Define an update function that combines the semantics of with and the variadic convenience of concat for ergonomics.

 Answer 4:

 */

func with<A>(_ a: A, _ f: (inout A) -> Void) -> A {
    var a = a
    f(&a)
    return a
}

func concat<A>(_ fs: ((inout A) -> Void)...) -> (inout A) -> Void {
    return { a in
        fs.forEach { f in f(&a) }
    }
}

func update<A>(_ a: A, _ fs: ((inout A) -> Void)...) -> A {
    var a = a
    fs.forEach { f in f(&a) }
    return a
}

func with<A: AnyObject>(_ a: A, _ f: (A) -> Void) -> A {
    var a = a
    f(a)
    return a
}

func concat<A: AnyObject>(_ fs: ((A) -> Void)...) -> (A) -> Void {
    return { a in
        fs.forEach { f in f(a) }
    }
}

func update<A: AnyObject>(_ a: A, _ fs: ((A) -> Void)...) -> A {
    var a = a
    fs.forEach { f in f(a) }
    return a
}

func with<A, B>(_ a: A, _ f: (A) -> B) -> B {
    return f(a)
}

func concat<A>(_ fs: ((A) -> A)...) -> (A) -> A {
    return { a in
        var copy = a
        for f in fs {
            copy = f(copy)
        }
        return copy
    }
}

func update<A>(_ a: A, _ fs: ((A) -> A)...) -> A {
    var copy = a
    for f in fs {
        copy = f(copy)
    }
    return copy
}

let guaranteeHeaders = mver(^\URLRequest.allHTTPHeaderFields) { $0 = $0 ?? [:] }

let setHeader = { name, value in
    concat(guaranteeHeaders, { $0.allHTTPHeaderFields?[name] = value })
}

let postJson =
    concat(
        mut(^\URLRequest.httpMethod, "POST"),
        setHeader("Content-Type", "application/json; charset=utf-8")
    )

let gitHubAccept =
    concat(
        guaranteeHeaders,
        setHeader("Accept", "application/vnd.github.v3+json")
    )

let attachAuthorization = { token in
    setHeader("Authorization", "Token " + token)
}

with(
    URLRequest(url: URL(string: "https://www.pointfree.co/hello")!),
    concat(
        attachAuthorization("deadbeef"),
        gitHubAccept,
        postJson
    )
)

/*

 Exercise 5:

 In the Haskell Lens library, over and set are defined as infix operators %~ and .~. Define these operators and explore what their precedence should be, updating some of our examples to use them. Do these operators tick the boxes?

 Answer 5:

 */

precedencegroup SetterPrecedence {
    associativity: left
    higherThan: SingleTypeComposition
}

infix operator %~: SetterPrecedence

func %~ <S, T, A, B>(
    _ setter: Setter<S, T, A, B>,
    _ set: @escaping (A) -> B
    )
    -> (S) -> T {
    return over(setter, set)
}

infix operator .~: SetterPrecedence

func .~<S, T, A, B>(
    _ setter: Setter<S, T, A, B>,
    _ value: B
    )
    -> (S) -> T {
    return over(setter) { _ in value }
}

struct Food {
    var name: String
}

struct Location {
    var name: String
}

struct User {
    var favoriteFoods: [Food]
    var location: Location
    var name: String
}

var user = User(
    favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
    location: Location(name: "Brooklyn"),
    name: "Blob"
)

let addCourtesyTitle = { $0 + ", Esq." }
let healthierOption = { $0 + " & Salad" }

user
    |> (^\.name %~ addCourtesyTitle)
    <> (^\.name %~ { $0.uppercased() })
    <> (^\.location.name .~ "Los Angeles")
    // expression was too complex to be solved in reasonable time
//    <> ((^\.favoriteFoods <<< map <<< ^\.name) %~ healthierOption)

// THEY TICK BOXES


//: [Next](@next)
