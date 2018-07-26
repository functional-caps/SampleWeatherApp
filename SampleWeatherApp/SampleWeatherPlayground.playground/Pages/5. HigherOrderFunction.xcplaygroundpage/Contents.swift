//: [Previous](@previous)

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

func zurry<A>(_ f: () -> A) -> A {
  return f()
}

/*

 Exercise 1:

 Write curry for functions that take 3 arguments.

 Answer 1:

 */

func testCurry(a: Int, b: Float, c: Double) -> String {
  return String(Double(a) * Double(b) * c)
}

testCurry(a: 2, b: 3, c: 4)

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  return { a in
    return { b in
      return { c in
        return f(a, b, c)
      }
    }
  }
}

let curried = curry(testCurry)
curried(2)(3)(4)

/*

 Exercise 2:

 Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using curry, zurry, flip, or by hand.

 Answer 2:

 */

import Foundation

// ???

/*

 Exercise 3:

 Explore the associativity of function arrow ->. Is it fully associative, i.e. is ((A) -> B) -> C equivalent to (A) -> ((B) -> C), or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?

 Answer 3:

 */

func curry<A, B, C, D, E, F>(_ f: @escaping (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
  return { a in
    return { b in
      return { c in
        return { d in
          return { e in
            return f(a, b, c, d, e)
          }
        }
      }
    }
  }
}

func longSignature(a: Int, b: Float, c: String, d: Double, e: Date) -> Bool { return false }

let longCurried = curry(longSignature)

//let foo1: (Int) -> (Float) -> (String) -> (Double) -> (Date) -> Bool = longCurried

// Answer: it associates to one side

/*

 Exercise 4:

 Write a function, uncurry, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?

 Answer 4:

 */

func uncurry<A, B, C, D>(_ f: @escaping (A) -> (B) -> (C) -> D) -> (A, B, C) -> D {
  return { a, b, c in
    return f(a)(b)(c)
  }
}

uncurry(curried)

/*

 Exercise 5:

 Write reduce as a curried, free function. What is the configuration vs. the data?

 Answer 5:

 */

func freeReduce<A, B>(initializer: B, reducer: @escaping (B, A) -> B, data: [A]) -> B {
  return data.reduce(initializer, reducer)
}

func freeCurriedReduce<A, B>(_ initializer: B) -> (@escaping (B, A) -> B) -> ([A]) -> B {
  return { reducer in
    return { data in
      return data.reduce(initializer, reducer)
    }
  }
}

freeCurriedReduce(1)(*)([2, 3, 4])

/*

 Exercise 6:

 In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type struct PseudoEither<A, B> of a pair of optionals, and prevent the creation of invalid values by providing initializers.

 This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.

 Answer 6:

 */

struct PseudoEither<A, B> {
  let left: A?
  let right: B?

  init(_ left: A) { self.left = left; self.right = nil }

  init(_ right: B) { self.left = nil; self.right = right }
}

let left = PseudoEither<Int, String>(1)
let right = PseudoEither<Int, String>("2")

/*

 Exercise 7:

 Explore how the free map function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array [[A]], then map could mean either the transformation on the inner array or the outer array. Can you make sense of doing map >>> map?

 Answer 7:

 */

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

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in
    g(f(a))
  }
}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { $0.map(f) }
}

func incr(a: Int) -> String {
  return "\(a + 1)"
}

[[1], [2], [3]]
|> (incr |> map >>> map)

//: [Next](@next)
