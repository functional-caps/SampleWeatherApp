//: [Previous](@previous)

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
 
 In this episode we came across closures of the form { ($0, $1.0, $1.1) } a few times in order to unpack a tuple of the form (A, (B, C)) to (A, B, C). Create a few overloaded functions named unpack to automate this.
 
 Answer 1:
 
 */

func unpack<A, B, C>(_ tuple: (A, (B, C))) -> (A, B, C) { return (tuple.0, tuple.1.0, tuple.1.1) }
func unpack<A, B, C>(_ tuple: ((A, B), C)) -> (A, B, C) { return (tuple.0.0, tuple.0.1, tuple.1) }
func unpack<A, B, C, D>(_ tuple: ((A, B, C), D)) -> (A, B, C, D) { return (tuple.0.0, tuple.0.1, tuple.0.2, tuple.1) }
func unpack<A, B, C, D>(_ tuple: (A, (B, C, D))) -> (A, B, C, D) { return (tuple.0, tuple.1.0, tuple.1.1, tuple.1.2) }
func unpack<A, B, C, D, E>(_ tuple: ((A, B, C, D), E)) -> (A, B, C, D, E) { return (tuple.0.0, tuple.0.1, tuple.0.2, tuple.0.3, tuple.1) }
func unpack<A, B, C, D, E>(_ tuple: (A, (B, C, D, E))) -> (A, B, C, D, E) { return (tuple.0, tuple.1.0, tuple.1.1, tuple.1.2, tuple.1.3) }

unpack((1, (2, 3)))
unpack(((1, 2), 3))
unpack(((1, 2, 3), 4))
unpack((1, (2, 3, 4)))
unpack((1, (2, 3, 4, 5)))
unpack(((1, 2, 3, 4), 5))


/*
 
 Exercise 2:

 Define zip4, zip5, zip4(with:) and zip5(with:) on arrays and optionals. Bonus: learn how to use Apple’s gyb tool to generate higher-arity overloads.
 
 Answer 2:
 
 */

func zip4<A, B, C, D>(_ as: [A], _ bs: [B], _ cs: [C], _ ds: [D]) -> [(A, B, C, D)] {
    return zip2(`as`, zip3(bs, cs, ds)).map(unpack)
}

func zip4<A, B, C, D>(_ as: A?, _ bs: B?, _ cs: C?, _ ds: D?) -> (A, B, C, D)? {
    return zip2(`as`, zip3(bs, cs, ds)).map(unpack)
}

func zip5<A, B, C, D, E>(_ as: [A], _ bs: [B], _ cs: [C], _ ds: [D], _ es: [E]) -> [(A, B, C, D, E)] {
    return zip2(`as`, zip4(bs, cs, ds, es)).map(unpack)
}

func zip5<A, B, C, D, E>(_ as: A?, _ bs: B?, _ cs: C?, _ ds: D?, _ es: E?) -> (A, B, C, D, E)? {
    return zip2(`as`, zip4(bs, cs, ds, es)).map(unpack)
}

func zip4<A, B, C, D, E>(with f: @escaping (A, B, C, D) -> E) -> ([A], [B], [C], [D]) -> [E] {
    return { zip4($0, $1, $2, $3).map(f) }
}

func zip4<A, B, C, D, E>(with f: @escaping (A, B, C, D) -> E) -> (A?, B?, C?, D?) -> E? {
    return { zip4($0, $1, $2, $3).map(f) }
}

func zip5<A, B, C, D, E, F>(with f: @escaping (A, B, C, D, E) -> F) -> ([A], [B], [C], [D], [E]) -> [F] {
    return { zip5($0, $1, $2, $3, $4).map(f) }
}

func zip5<A, B, C, D, E, F>(with f: @escaping (A, B, C, D, E) -> F) -> (A?, B?, C?, D?, E?) -> F? {
    return { zip5($0, $1, $2, $3, $4).map(f) }
}


/*
 
 Exercise 3:

 Do you think zip2 can be seen as a kind of associative infix operator? For example, is it true that zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)? If it’s not strictly true, can you define an equivalence between them?
 
 Answer 3:
 
 */

// zip(xs, zip(ys, zs)) ?? zip(zip(xs, ys), zs)
// zip([x], zip([y], [z])) ?? zip(zip([x], [y]), [z])
// zip([x], [(y, z)]) ?? zip([(x, y)], [z])
// [(x, (y, z))] ?? [((x, y), z)]
// not strictly true, because the inner tuple structure differ
// the equivalent is zip(xs, zip(ys, zs)).map(unpack) ?? zip(zip(xs, ys), zs).map(unpack), or just zip3

/*
 
 Exercise 4:

 Define unzip2 on arrays, which does the opposite of zip2: ([(A, B)]) -> ([A], [B]). Can you think of any applications of this function?
 
 Answer 4:
 
 */

func unzip2<A, B>(_ tuples: [(A, B)]) -> ([A], [B]) {
    var `as`: [A] = []
    var bs: [B] = []
    tuples.forEach {
        `as`.append($0)
        bs.append($1)
    }
    return (`as`, bs)
}

unzip2([(1, 2), (3, 4), (5, 6), (7, 8)])

/*
 
 Exercise 5:

 It turns out, that unlike the map function, zip2 is not uniquely defined. A single type can have multiple, completely different zip2 functions. Can you find another zip2 on arrays that is different from the one we defined? How does it differ from our zip2 and how could it be useful?
 
 Answer 5:
 
 */

func zip2reversed<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    let maxIndex = min(xs.count, ys.count) - 1
    (0...maxIndex).forEach { idx in
        result.append((xs[idx], ys[maxIndex-idx]))
    }
    return result
}

zip2reversed([1, 2, 3, 4], [1, 2, 3, 4, 5])

/*
 
 Exercise 6:

 Define zip2 on the result type: (Result<A, E>, Result<B, E>) -> Result<(A, B), E>. Is there more than one possible implementation? Also define zip3, zip2(with:) and zip3(with:).

 Is there anything that seems wrong or “off” about your implementation? If so, it will be improved in the next episode 😃.
 
 Answer 6:
 
 */

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

func zip2<A, B, C, E>(with f: @escaping (A, B) -> C) -> (Result<A, E>, Result<B, E>) -> Result<C, E> {
    return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, E>(_ a: Result<A, E>, _ b: Result<B, E>, _ c: Result<C, E>) -> Result<(A, B, C), E> {
    return zip2(a, zip2(b, c)) |> map(unpack)
}

func zip3<A, B, C, D, E>(
    with f: @escaping (A, B, C) -> D
    ) -> (Result<A, E>, Result<B, E>, Result<C, E>) -> Result<D, E> {
    return { zip3($0, $1, $2) |> map(f) }
}

/*
 
 Exercise 7:

 In previous episodes we’ve considered the type that simply wraps a function, and let’s define it as struct Func<R, A> { let apply: (R) -> A }. Show that this type supports a zip2 function on the A type parameter. Also define zip3, zip2(with:) and zip3(with:).
 
 Answer 7:
 
 */

struct Func<R, A> { let apply: (R) -> A }

func map<R, A, B>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
    return { fa in Func<R, B> { r in f(fa.apply(r)) } }
}

func zip2<R, A, B>(_ lr: Func<R, A>, _ rr: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { r in
        let a = lr.apply(r)
        let b = rr.apply(r)
        return (a, b)
    }
}

func zip2<R, A, B, C>(with f: @escaping (A, B) -> C) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {
    return { zip2($0, $1) |> map(f) }
}

func zip3<R, A, B, C>(_ a: Func<R, A>, _ b: Func<R, B>, _ c: Func<R, C>) -> Func<R, (A, B, C)> {
    return zip2(a, zip2(b, c)) |> map(unpack)
}

func zip3<R, A, B, C, D>(
    with f: @escaping (A, B, C) -> D
    ) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {
    return { zip3($0, $1, $2) |> map(f) }
}

/*
 
 Exercise 8:

 The nested type [A]? = Optional<Array<A>> is composed of two containers, each of which has their own zip2 function. Can you define zip2 on this nested container that somehow involves each of the zip2’s on the container types?
 
 Answer 8:
 
 */

func zip2<A, B>(_ a: [A]?, _ b: [B]?) -> [(A, B)]? {
    return zip2(a, b).map(zip2)
}

//: [Next](@next)
