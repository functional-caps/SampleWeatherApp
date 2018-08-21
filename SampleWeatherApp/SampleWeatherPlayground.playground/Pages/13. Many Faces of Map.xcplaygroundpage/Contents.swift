//: [Previous](@previous)

/*

 Exercise 1:

 Implement a map function on dictionary values, i.e.

 map: ((V) -> W) -> ([K: V]) -> [K: W]

 Does it satisfy map(id) == id?

 Answer 1:

 */

func map<K, V, W>(_ f: @escaping (V) -> W) -> ([K: V]) -> [K: W] {
    return { (dict: [K: V]) in
        var result = [K: W]()
        dict.forEach { tuple in
            result[tuple.0] = f(tuple.1)
        }
        return result
    }
}

["elo" : 42]
    |> map { String($0) }

//return { (dict: [K: V]) in
//    var result = [K: W]()
//    dict.forEach { tuple in
//        result[tuple.0] = id(tuple.1)
//    }
//    return result
//}

//return { (dict: [K: V]) in
//    var result = [K: W]()
//    dict.forEach { tuple in
//        result[tuple.0] = tuple.1
//    }
//    return result
//}

//return { (dict: [K: V]) in
//    var result = [K: W]()
//    result = dict
//    return result
//}

//return { (dict: [K: V]) in
//    return dict
//}

//return { $0 }
/*

 Exercise 2:

 Implement the following function:

 transformSet: ((A) -> B) -> (Set<A>) -> Set<B>

 We do not call this map because it turns out to not satisfy the properties of map that we saw in this episode. What is it about the Set type that makes it subtly different from Array, and how does that affect the genericity of the map function?


 Answer 2:

 */

func transformSet<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> {
    return { (set: Set<A>) in
        var result = Set<B>()
        set.forEach { elem in
            result.insert(f(elem))
        }
        return result
    }
}

// depending in the function, it might return smaller set than the original one
// because of the duplicates removal

/*

 Exercise 3:

 Recall that one of the most useful properties of map is the fact that it distributes over compositions, i.e. map(f >>> g) == map(f) >>> map(g) for any functions f and g. Using the transformSet function you defined in a previous example, find an example of functions f and g such that

 transformSet(f >>> g) != transformSet(f) >>> transformSet(g)

 This is why we do not call this function map.

 Answer 3:

 */

//let f: (Int) -> Double = { return
//
//
//}
//let g: (Double) -> String = { return String($0) }
//let set: Set<Int> = [-1, 0, 1]
//
//set
//    |> transformSet(f)
//    |> transformSet(g)
//
//set
//    |> transformSet(f >>> g)

/*

 Exercise 4:

 There is another way of modeling sets that is different from Set<A> in the Swift standard library. It can also be defined as function (A) -> Bool that answers the question “is a: A contained in the set.” Define a type struct PredicateSet<A> that wraps this function. Can you define the following?

 map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>

 What goes wrong?

 Answer 4:

 */

struct PredicateSet<A> {
    let contains: (A) -> Bool
}

//func map(_ f: @escaping (A) -> B) -> (PredicateSet<A>) -> PredicateSet<B> {
//    return { (set: PredicateSet<A>) in
//        let contains = set.contains // (A) -> Bool
//        f // (A) -> B
//        // cannot compose
//    }
//}

/*

 Exercise 5:

 Try flipping the direction of the arrow in the previous exercise. Can you define the following function?

 fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>

 Answer 5:

 */

func fakeMap<A, B>(_ f: @escaping (B) -> A) -> (PredicateSet<A>) -> PredicateSet<B> {
    return { (set: PredicateSet<A>) in
//        set.contains // (A) -> Bool
        return PredicateSet(contains: f >>> set.contains) // (B) -> Bool
    }
}

/*

 Exercise 6:

 What kind of laws do you think fakeMap should satisfy?

 Answer 6:

 */

//fakeMap(id) == id
//fakeMap(f >>> g) == fakeMap(f) >>> fakeMap(g)

/*

 Exercise 7:

 Sometimes we deal with types that have multiple type parameters, like Either and Result. For those types you can have multiple maps, one for each generic, and no one version is “more” correct than the other. Instead, you can define a bimap function that takes care of transforming both type parameters at once. Do this for Result and Either.


 Answer 7:

 */


func bimap<Value, Error, NewValue, NewError>(
    _ f: @escaping (Value) -> NewValue, _ g: @escaping (Error) -> NewError
    ) -> (Result<Value, Error>) -> Result<NewValue, NewError> {
    return { result in
        switch result {
        case .success(let value):
            return Result.success(f(value))
        case .failure(let error):
            return Result.failure(g(error))
        }
    }
}

let result = Result<Int, String>.success(42)
result
    |> bimap({ _ in 24 }, { _ in 92 })

func bimap<A, B, NewA, NewB>(
    _ f: @escaping (A) -> NewA, _ g: @escaping (B) -> NewB
    ) -> (Either<A, B>) -> Either<NewA, NewB> {
    return { result in
        switch result {
        case .left(let value):
            return Either.left(f(value))
        case .right(let value):
            return Either.right(g(value))
        }
    }
}

let either = Either<Int, String>.left(42)
either
    |> bimap({ _ in 24 }, { _ in 92 })

/*

 Exercise 8:

 Write a few implementations of the following function:

 func r<A>(_ xs: [A]) -> A? {
 }

 Answer 8:

 */

func r1<A>(_ xs: [A]) -> A? {
    return xs.first
}

func r2<A>(_ xs: [A]) -> A? {
    return xs.last
}

func r3<A>(_ xs: [A]) -> A? {
    return xs.dropFirst().first
}

func r4<A>(_ xs: [A]) -> A? {
    return nil
}

/*

 Exercise 9:

 Continuing the previous exercise, can you generalize your implementations of r to a function [A] -> B? if you had a function f: (A) -> B?

 func s<A, B>(_ f: (A) -> B, _ xs: [A]) -> B? {
 }

 What features of arrays and optionals do you need to implement this?

 Answer 9:

 */

func s1<A, B>(_ f: @escaping (A) -> B, _ xs: [A]) -> B? {
    return xs |> map(f) >>> r1
}

func s2<A, B>(_ f: @escaping (A) -> B, _ xs: [A]) -> B? {
    return xs |> r1 >>> map(f)
}

/*

 Exercise 10:

 Derive a relationship between r, any function f: (A) -> B, and the map on arrays and optionals.

 This relationship is the “free theorem” for r’s signature.

 Answer 10:

 */

// mapArray(f) >>> r == r >>> mapOptional(f)


//: [Next](@next)
