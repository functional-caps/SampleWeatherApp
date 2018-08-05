//: [Previous](@previous)

/*

 Exercise 1:

 Write concat for functions (inout A) -> Void.

 Answer 1:

 */

func concat<A>(_ fs: ((inout A) -> Void)...)
    -> (inout A) -> Void {
    return { a in
        fs.forEach { $0(&a) }
    }
}

/*

 Exercise 2:

 Write concat for functions (A) -> A.

 Answer 2:

 */

func concat<A>(_ fs: ((A) -> A)...) -> (A) -> A {
    return { a in
        var result: A = a
        for f in fs {
            result = f(result)
        }
        return result
    }
}

/*

 Exercise 3:

 Write compose for backward composition. Recreate some of the examples from our functional setters episodes (part 1 and part 2) using compose and pipe.

 Answer 3:

 */

func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    return { f(g($0)) }
}

func incr(_ int: Int) -> Int { return int + 1 }

//pair |> first(incr >>> String.init)
with((42, "Swift"), first(pipe(incr, String.init)))


let nested = ((1, false), "Swift")

//nested |> (second >>> first) { !$0 }
dump(
with(nested, with({ !$0 }, pipe(second, first)))
)

//nested |> (first <<< second) { !$0 }
dump(
with(nested, with({ !$0 }, compose(first, second)))
)

//nested |> (first <<< first)(incr)
with(nested, with(incr, compose(first, first)))

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

let user = User(
    favoriteFoods: [
        Food(name: "Tacos"),
        Food(name: "Nachos")
    ],
    location: Location(name: "Brooklyn"),
    name: "Blob"
)

//(42, user) |> (second <<< prop(\User.name)) { $0.uppercased() }
with((42, user), with( { $0.uppercased() }, compose(second, prop(\User.name))))

//: [Next](@next)
