//: [Previous](@previous)

struct F3<A> {
    let run: (@escaping (A) -> Void) -> Void
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
    return { f3 in
        return F3 { callback in
            f3.run { callback(f($0)) }
        }
    }
}

func zip2<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
    return F3 { callback in
        var a: A?
        var b: B?
        fa.run {
            a = $0
            if let b = b { callback(($0, b)) }
        }
        fb.run {
            b = $0
            if let a = a { callback((a, $0)) }
        }
    }
}

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0..<min(xs.count, ys.count)).forEach { idx in
        result.append((xs[idx], ys[idx]))
    }
    return result
}

func zip3<A, B, C>(
    _ xs: [A], _ ys: [B], _ zs: [C]
    ) -> [(A, B, C)] {
    
    return zip2(xs, zip2(ys, zs)) // [(A, (B, C))]
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
    ) -> ([A], [B]) -> [C] {
    return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
    ) -> ([A], [B], [C]) -> [D] {
    
    return { xs, ys, zs in zip3(xs, ys, zs).map(f) }
}

func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    return zip2(a, zip2(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
    ) -> (A?, B?) -> C? {
    
    return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
    ) -> (A?, B?, C?) -> D? {
    
    return { zip3($0, $1, $2).map(f) }
}

/*
 
 Exercise 1:
 
 Can you make the zip2 function on our F3 type thread safe?
 
 Answer 1:
 
 */

import Foundation

func zip2safer<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
    return F3 { callback in
        
        let dispatchGroup = DispatchGroup()
        
        var a: A?
        var b: B?
        dispatchGroup.enter()
        dispatchGroup.enter()
        fa.run {
            a = $0
            dispatchGroup.leave()
        }
        fb.run {
            b = $0
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            if let a = a, let b = b { callback((a, b)) }
        }
    }
}

/*
 
 Exercise 2:
 
 Generalize the F3 type to a type that allows returning values other than Void: struct F4<A, R> { let run: (@escaping (A) -> R) -> R }. Define zip2 and zip2(with:) on the A type parameter.
 
 Answer 2:
 
 */

struct F4<Input, Return> {
    let run: (@escaping (Input) -> Return) -> Return
}

func zip2<InputA, InputB, Return>(_ fa: F4<InputA, Return>, _ fb: F4<InputB, Return>) -> F4<(InputA, InputB), Return> {
    return F4 { tupleTaking -> Return in
        // couldn't find a way to produce R without waiting for the closures to produce them
        return fa.run { inputA -> Return in
            return fb.run { inputB -> Return in
                return tupleTaking((inputA, inputB))
            }
        }
    }
}

func zip2<InputA, InputB, Output, Return>(
    with f: @escaping (InputA, InputB) -> Output
) -> (F4<InputA, Return>, F4<InputB, Return>) -> F4<Output, Return> {
    return { fa, fb in
        let fab = zip2(fa, fb)
        return F4<Output, Return> { callback in
            return fab.run { ab in
                callback(f(ab.0, ab.1))
            }
        }
    }
}

let fa = F4<Int, String> { $0(4) }

let fb = F4<Double, String> { $0(2.1) }

let fc = zip2(fa, fb)

fc.run({ tuple in
    print(tuple)
    return String(describing: tuple)
})


/*
 
 Exercise 3:
 
 Find a function in the Swift standard library that resembles the function above. How could you use zip2 on it?
 
 Answer 3:
 
 */

// DispatchQueue.main.sync(execute: <#T##() throws -> T#>) ??

/*
 
 Exercise 4.1:
 
 This exercise explore what happens when you nest two types that each support a zip operation.
 
 Consider the type [A]? = Optional<Array<A>>. The outer layer Optional has zip2 defined, but also the inner layer Array has a zip2. Can we define a zip2 on [A]? that makes use of both of these zip structures? Write the signature of such a function and implement it.
 
 Answer 4.1:
 
 */

func zip2<A, B>(_ as: [A]?, _ bs: [B]?) -> [(A, B)]? {
    return zip2(`as`, bs).map(zip2)
}

/*
 
 Exercise 4.2:
 
 Using the zip2 defined above write an example usage of it involving two [A]? values.
 
 Answer 4.2:
 
 */

let noArray: [Int]? = nil

zip2(noArray, noArray)
zip2([1, 2, 3], noArray)
zip2(noArray, [1, 2, 3])
zip2([1, 2, 3], [1, 2, 3])

/*
 
 Exercise 4.3:
 
 Consider the type [Validated<A, E>]. We again have have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both zip structures? Write the signature of such a function and implement it.
 
 Answer 4.3:
 
 */

typealias NonEmptyArray<T> = NonEmpty<[T]>

enum Validated<A, E> {
    case valid(A)
    case invalid(NonEmptyArray<E>)
}

func + <T>(lhs: NonEmptyArray<T>, rhs: NonEmptyArray<T>) -> NonEmptyArray<T> {
    return NonEmptyArray(lhs.head, lhs.tail + [rhs.head] + rhs.tail)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
    return { validated in
        switch validated {
        case let .valid(a):
            return .valid(f(a))
        case let .invalid(e):
            return .invalid(e)
        }
    }
}

func zip2<A, B, E>(_ lv: Validated<A, E>, _ rv: Validated<B, E>) -> Validated<(A, B), E> {
    switch (lv, rv) {
    case let (.valid(a), .valid(b)): return .valid((a, b))
    case let (.valid, .invalid(e)), let (.invalid(e), .valid): return .invalid(e)
    case let (.invalid(le), .invalid(re)): return .invalid(le + re)
    }
}

func zip2<A, B, E>(_ lv: [Validated<A, E>], _ rv: [Validated<B, E>]) -> [Validated<(A, B), E>] {
    return zip2(lv, rv) |> map(zip2)
}

/*
 
 Exercise 4.4:
 
 Using the zip2 defined above write an example usage of it involving two [Validated<A, E>] values.
 
 Answer 4.4:
 
 */

let valid = Validated<Int, String>.valid(42)
let invalid = Validated<Int, String>.invalid(NonEmptyArray("not 42", "also stupid"))

zip2([valid, valid], [])
zip2([valid], [invalid])
zip2([], [invalid, valid])
zip2([invalid], [invalid])

/*
 
 Exercise 4.5:
 
 Consider the type Func<R, A?>. Again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.5:
 
 */

typealias FuncMaybe<R, A> = Func<R, A?>

func zip2<A, B, R>(_ lf: Func<R, A>, _ rf: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { (r: R) -> (A, B) in
        return (lf.apply(r), rf.apply(r))
    }
}

func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
    return { input in
        return Func<R, B> { r in
            return f(input.apply(r))
        }
        
    }
}

func zip2<A, B, R>(_ lf: Func<R, A?>, _ rf: Func<R, B?>) -> Func<R, (A, B)?> {
    return zip2(lf, rf) |> map(zip2)
}

/*
 
 Exercise 4.6:
 
 Consider the type Func<R, [A]>. Again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.6:
 
 */

func zip2<A, B, R>(_ lf: Func<R, [A]>, _ rf: Func<R, [B]>) -> Func<R, [(A, B)]> {
    return zip2(lf, rf) |> map(zip2)
}

/*
 
 Exercise 4.7:
 
 Finally, conisder the type F3<Validated<A, E>>. Yet again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.7:
 
 */

func zip2<A, B, E>(_ lf: F3<Validated<A, E>>, _ rf: F3<Validated<B, E>>) -> F3<Validated<(A, B), E>> {
    return zip2safer(lf, rf) |> map(zip2)
}

/*
 
 Exercise 5:
 
 Do you see anything common in the implementation of all of the functions in the previous exercise? What this is showing is that nested zippable containers are also zippable containers because zip on the nesting can be defined in terms of zip on each of the containers.
 
 Answer 5:
 
 */

// YES: { zip2 on Container1<Container2<T>> } is { zip2 on container1 } |> map { zip2 on Container2 }
// map is used to go inside containers, zip is used to adjust the types structure

//: [Next](@next)
