//: [Previous](@previous)

import Foundation

/*
 
 Exercise 1.1:
 
 In this series of episodes on zip we have described zipping types as a kind of way to swap the order of nested containers when one of those containers is a tuple, e.g. we can transform a tuple of arrays to an array of tuples ([A], [B]) -> [(A, B)]. There’s a more general concept that aims to flip containers of any type. Implement the following to the best of your ability, and describe in words what they represent:
 
 sequence: ([A?]) -> [A]?
 
 Answer 1.1:
 
 */

func sequence<A>(_ `as`: [A?]) -> [A]? {
    var result: [A] = []
    for elem in `as` {
        guard let elem = elem else { return nil }
        result.append(elem)
    }
    return result
}

// It represents ensuring that the array elements do exist

/*
 
 Exercise 1.2:
 
 sequence: ([Result<A, E>]) -> Result<[A], E>
 
 Answer 1.2:
 
 */

func sequence<A, E>(_ `as`: [Result<A, E>]) -> Result<[A], E> {
    var result: [A] = []
    for elem in `as` {
        switch elem {
        case let .success(a): result.append(a)
        case let .failure(e): return .failure(e)
        }
    }
    return .success(result)
}

// It respresents ensuring that all the results are successful

/*
 
 Exercise 1.3:
 
 sequence: ([Validated<A, E>]) -> Validated<[A], E>
 
 Answer 1.3:
 
 */

typealias NonEmptyArray<T> = NonEmpty<[T]>

enum Validated<A, E> {
    case valid(A)
    case invalid(NonEmptyArray<E>)
}

func + <T>(lhs: NonEmptyArray<T>, rhs: NonEmptyArray<T>) -> NonEmptyArray<T> {
    return NonEmptyArray(lhs.head, lhs.tail + [rhs.head] + rhs.tail)
}

func sequence<A, E>(_ `as`: [Validated<A, E>]) -> Validated<[A], E> {
    var valids: [A] = []
    var invalids: [NonEmptyArray<E>] = []
    for elem in `as` {
        switch elem {
        case let .valid(a): valids.append(a)
        case let .invalid(e): invalids.append(e)
        }
    }
    if let first = invalids.first {
        return .invalid(invalids.reduce(first, +))
    } else {
        return .valid(valids)
    }
}

// It represents partitioning the separete validated results into all the valid results and all the errors

/*
 
 Exercise 1.4:
 
 sequence: ([Parallel<A>]) -> Parallel<[A]>
 
 Answer 1.4:
 
 */

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
}

func sequence<A>(_ `as`: [Parallel<A>]) -> Parallel<[A]> {
    return Parallel<[A]> { completion in
        let dispatchGroup = DispatchGroup()
        var result: [A] = []
        `as`.forEach { (parallel: Parallel<A>) in
            dispatchGroup.enter()
            parallel.run { a in
                result.append(a)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            completion(result)
        }
    }
}

// It represents grouping of multiple independent operation into one operation that tries to execute them concurrently
// and collects all the results by waiting till the last one is finished

/*
 
 Exercise 1.5:
 
 sequence: (Result<A?, E>) -> Result<A, E>?
 
 Answer 1.5:
 
 */

func sequence<A, E>(_ result: Result<A?, E>) -> Result<A, E>? {
    switch result {
    case .success(nil): return nil
    case let .failure(e): return .failure(e)
    case let .success(v?): return .success(v)
    }
}

// It represents expressing the lack of value in the result as the lack of the whole result

/*
 
 Exercise 1.6:
 
 sequence: (Validated<A?, E>) -> Validated<A, E>?
 
 Answer 1.6:
 
 */

func sequence<A, E>(_ validated: Validated<A?, E>) -> Validated<A, E>? {
    switch validated {
    case .valid(nil): return nil
    case let .valid(a?): return .valid(a)
    case let .invalid(e): return .invalid(e)
    }
}

// It represents expressing the lack of value in the validation as the lack of the whole validation

/*
 
 Exercise 1.7:
 
 sequence: ([[A]]) -> [[A]]. Note that you can still flip the order of these containers even though they are both the same container type. What does this represent? Evaluate the function on a few sample nested arrays.
 
 Answer 1.7:
 
 */

func sequence<A>(_ `as`: [[A]]) -> [[A]] {
    return `as`.flatMap { $0 }.map { [$0] }
}

sequence([[1, 2, 3], [4, 5], [], [6, 7, 8]])

// It represents dropping the empty value sequences and partitioning the all the other elements into independent containers

/*
 
 Exercise 1.8:

 Note that all of these functions also represent the flipping of containers, e.g. an array of optionals transforms into an optional array, an array of results transforms into a result of an array, or a validated optional transforms into an optional validation, etc.
 
 Do the implementations of these functions have anything in common, or do they seem mostly distinct from each other?
 
 Answer 1.8:
 
 */

// The implementations are distinct in a sense that the actual meaning of the sequence function depends on the particular pair of containers that we're working with.
// The common idea is that we lift the semantics of the underlying container to the whole object

/*
 
 Exercise 2:
 

 There is a function closely related to zip called apply. It has the following shape: apply: (F<(A) -> B>, F<A>) -> F<B>. Define apply for Array, Optional, Result, Validated, Func and Parallel.
 
 Answer 2:
 
 */

// apply: (F<(A) -> B>, F<A>) -> F<B> for Array

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0..<min(xs.count, ys.count)).forEach { idx in
        result.append((xs[idx], ys[idx]))
    }
    return result
}

func apply<A, B>(_ fs: [(A) -> B], _ `as`: [A]) -> [B] {
    return zip2(`as`, fs).map { a, f in f(a) }
}

// apply: (F<(A) -> B>, F<A>) -> F<B> for Optional

func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}

func apply<A, B>(_ fs: ((A) -> B)?, _ `as`: A?) -> B? {
    return zip2(`as`, fs).map { a, f in f(a) }
}

// apply: (F<(A) -> B>, F<A>) -> F<B> for Result

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
    return {
        switch $0 {
        case .success(let s): return .success(f(s))
        case .failure(let e): return .failure(e)
        }
    }
}

func zip2<A, B, E>(_ lr: Result<A, E>, _ rr: Result<B, E>) -> Result<(A, B), E> {
    switch (lr, rr) {
    case let (.success(a), .success(b)): return .success((a, b))
    case let (.success, .failure(e)), let (.failure(e), .success): return .failure(e)
    case let (.failure(e1), .failure): return .failure(e1)
    }
}

func apply<A, B, E>(_ fs: Result<(A) -> B, E>, _ `as`: Result<A, E>) -> Result<B, E> {
    return zip2(`as`, fs) |> map { (elem: (A, (A) -> B)) -> B in
        let (a, f) = elem
        return f(a)
    }
}

// apply: (F<(A) -> B>, F<A>) -> F<B> for Validated

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

func apply<A, B, E>(_ fs: Validated<(A) -> B, E>, _ `as`: Validated<A, E>) -> Validated<B, E> {
    return zip2(`as`, fs) |> map { (elem: (A, (A) -> B)) -> B in
        let (a, f) = elem
        return f(a)
    }
}

// apply: (F<(A) -> B>, F<A>) -> F<B> for Func

func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
    return { input in
        return Func<R, B> { r in
            return f(input.apply(r))
        }

    }
}

func zip2<A, B, R>(_ lf: Func<R, A>, _ rf: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { (r: R) -> (A, B) in
        return (lf.apply(r), rf.apply(r))
    }
}

func apply<A, B, R>(_ fs: Func<R, (A) -> B>, _ `as`: Func<R, A>) -> Func<R, B> {
    return zip2(`as`, fs) |> map { (elem: (A, (A) -> B)) -> B in
        let (a, f) = elem
        return f(a)
    }
}

// apply: (F<(A) -> B>, F<A>) -> F<B> for Parallel

func map<A, B>(_ f: @escaping (A) -> B) -> (Parallel<A>) -> Parallel<B> {
    return { pa in
        return Parallel { callback in
            pa.run { callback(f($0)) }
        }
    }
}

func zip2<A, B>(_ pa: Parallel<A>, _ pb: Parallel<B>) -> Parallel<(A, B)> {
    return Parallel { callback in

        let dispatchGroup = DispatchGroup()

        var a: A?
        var b: B?
        dispatchGroup.enter()
        dispatchGroup.enter()
        pa.run {
            a = $0
            dispatchGroup.leave()
        }
        pb.run {
            b = $0
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            if let a = a, let b = b { callback((a, b)) }
        }
    }
}

func apply<A, B>(_ fs: Parallel<(A) -> B>, _ `as`: Parallel<A>) -> Parallel<B> {
    return zip2(`as`, fs) |> map { (elem: (A, (A) -> B)) -> B in
        let (a, f) = elem
        return f(a)
    }
}

/*
 
 Exercise 3:
 
 Another closely related function to zip is called alt, and it has the following shape: alt: (F<A>, F<A>) -> F<A>. Define alt for Array, Optional, Result, Validated and Parallel. Describe what this function semantically means for each of the types.
 
 Answer 3:
 
 */

// alt: (F<A>, F<A>) -> F<A> for Array

func alt<A>(_ first: [A], _ second: [A]) -> [A] {
    if !first.isEmpty {
        return first
    } else {
        return second
    }
}

// If means the first nonempty array if any is non empty

// alt: (F<A>, F<A>) -> F<A> for Optional

func alt<A>(_ first: A?, _ second: A?) -> A? {
    return first ?? second
}

// If means the first value from the container if any exists

// alt: (F<A>, F<A>) -> F<A> for Result

func alt<A, E>(_ first: Result<A, E>, _ second: Result<A, E>) -> Result<A, E> {
    if case .success = first {
        return first
    } else {
        return second
    }
}

// If means the first success result if any exists

// alt: (F<A>, F<A>) -> F<A> for Validated

func alt<A, E>(_ first: Validated<A, E>, _ second: Validated<A, E>) -> Validated<A, E> {
    if case .valid = first {
        return first
    } else {
        return second
    }
}

// If means the first valid value if any exists

// alt: (F<A>, F<A>) -> F<A> for Parallel

func alt<A>(_ first: Parallel<A>, _ second: Parallel<A>) -> Parallel<A> {
    return Parallel { callback in

        let dispatchSemaphore = DispatchSemaphore(value: 0)

        var a: A?
        var b: B?
        pa.run {
            a = $0
            dispatchSemaphore.signal()
        }
        pb.run {
            b = $0
            dispatchSemaphore.signal()
        }
        dispatchSemaphore.wait()
        if let a = a {
            callback(a)
        } else if let b = b {
            callback(b)
        }
    }
}

// If means waiting for the fastest operation to end and then
// returning the result of first operation if it's available and if it's not, returning the result of the second operation

//: [Next](@next)
