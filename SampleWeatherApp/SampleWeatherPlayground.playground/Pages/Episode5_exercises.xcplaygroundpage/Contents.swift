import UIKit

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
    return { a in
        g(f(a))
    }
}

func greet(at date: Date, name: String) -> String {
    let seconds = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past the minute."
}

func greet(at date: Date) -> (String) -> String {
    return { name in
        let seconds = Int(date.timeIntervalSince1970) % 60
        return "Hello \(name)! It's \(seconds) seconds past the minute."
    }
}

greet(at: Date())("Kamil")

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

func zurry<A>(_ f: () -> A) -> A {
    return f()
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}

let greeting = greet(at:name:)
curry(greeting)(Date())("Bolo")

// ex. 1 Write curry for functions that take 3 arguments.

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

/* ex. 2 Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using curry, zurry, flip, or by hand.
 */
var curriedStringInit = curry(String.init(data:encoding:)) >>> { $0(.utf8) }
var encodedString = Data() |> curriedStringInit
var flipedStringInit = flip(curry(String.init(data:encoding:)))

Optional<Bundle>.none |> flip(curry(UIViewController.init(nibName:bundle:)))

/* ex. 4 Write a function, uncurry, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */

func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { (a, b) in f(a)(b) }
}

var curriedGreeting = curry(greeting)
var uncurriedGreeting = uncurry(curriedGreeting)

// ex.5 Write reduce as a curried, free function. What is the configuration vs. the data?

//let x = [1,2,3,4].reduce(0) { return $0 + $1 }


func reduce<A, B>(_ initialResult: A,
                  _ nextPartialResult: @escaping (A, B) -> A) -> ([B]) -> A  {
    return {
        $0.reduce(initialResult, nextPartialResult)
    }
}

var number = [1,2,3,4,5] |> reduce(0, { $0 + $1} )
print(number)
