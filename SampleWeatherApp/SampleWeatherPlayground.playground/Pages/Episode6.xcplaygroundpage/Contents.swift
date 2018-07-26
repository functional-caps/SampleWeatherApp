import SampleWeatherFramework

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

precedencegroup BackwardsComposition {
    associativity: left
}

infix operator <<<: BackwardsComposition

func <<< <A, B, C>(_ f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
    return { f(g($0))}
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

func zurry<A>(_ f: () -> A) -> A {
    return f()
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { $0.map(f) }
}

func incr(_ a: Int) -> Int {
    return a + 1
}

func square(_ a: Int) -> Int {
    return a * a
}

//[2] |> map(incr >>> square >>> String.init)
//
let pair = (42, "Swift")
//
//(incr(pair.0), pair.1)
//
//func incrFirst<A>(_ pair: (Int, A)) -> (Int, A) {
//    return (incr(pair.0), pair.1)
//}
//
//incrFirst(pair)
//
//func incrSecond<A>(_ pair: (A, Int)) -> (A, Int) {
//    return (pair.0, incr(pair.1))
//}
//
//incrSecond(("Swift", 45))


func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
    return { pair in
        (f(pair.0), pair.1)
    }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
    return { pair in
        return (pair.0, f(pair.1))
    }
}

pair
    |> first(incr)
    |> first(String.init)

pair
    |> first(incr)
    >>> first(String.init)
//    >>> second(zurry(flip(String.uppercased)))

let nested = ((1, true), "Swift")

var changedNested = nested |> first { $0 |> second { !$0 } }

print(changedNested)

let nexted = nested |> (first <<< second) { !$0 }
print(nexted)


/* ex1
 As we saw with free map on Array, define free map on Optional and use it to compose setters that traverse into an optional field.
 */

func map<A, B>(_ f: @escaping (A?) -> B?) -> ([A?]) -> [B?] {
    return { $0.map(f) }
}

let optionalArray: [String?] = ["Aaaa", nil, "Bbb", nil]

optionalArray |> map { $0 ?? "" + "a" }



