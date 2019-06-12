//: [Previous](@previous)

import Foundation

func pipe<A, B, C>(
    _ lhs: @escaping (A) -> B,
    _ rhs: @escaping (B) -> C
) -> (A) -> C {
    return { a in rhs(lhs(a)) }
}

pipe({ $0 + 1 }, { $0 * $0})

let f = { $0 + 1 } >>> { $0 * $0 } >>> { $0 + 1 }

func chain<A, B, C>(
    _ lhs: @escaping (A) -> B?,
    _ rhs: @escaping (B) -> C?
    ) -> (A) -> C? {
    return { a in
        lhs(a).flatMap(rhs)
    }
}

struct User: Codable {
    let email: String
    let id: Int
    let name: String
}

chain(
    { try? Data.init(contentsOf: $0) },
    { try? JSONDecoder().decode(User.self, from: $0) }
)

pipe(
    URL.init(fileURLWithPath:),
    chain(
        { try? Data.init(contentsOf: $0) },
        { try? JSONDecoder().decode(User.self, from: $0) }
    )
)


func >=><A, B, C>(
    _ lhs: @escaping (A) -> B?,
    _ rhs: @escaping (B) -> C?
    ) -> (A) -> C? {
    return { a in
        lhs(a).flatMap(rhs)
    }
}

let loadUser = URL.init(fileURLWithPath:)
    >>> ({ try? Data.init(contentsOf: $0) }
    >=> { try? JSONDecoder().decode(User.self, from: $0) })

Bundle.main.path(forResource: "user", ofType: "json")
    .flatMap(loadUser)

enum Result<A, E> {
    
    case success(A)
    case failure(E)
    
    func map<B>(_ f: @escaping (A) -> B) -> Result<B, E> {
        switch self {
        case let .success(a): return .success(f(a))
        case let .failure(e): return .failure(e)
        }
    }
    
    func flatMap<B>(_ f: (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case .success(let value): return f(value)
        case .failure(let error): return .failure(error)
        }
    }
}

func zip<A, B, C, E>(with f: @escaping (A, B) -> C)
    -> (Result<A, E>, Result<B, E>) -> Result<C, E> {
        return { l, r in
            return l.flatMap { a in
                return r.map { b in
                    return f(a, b)
                }
            }
        }
}

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
    
    func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in callback(f(a)) }
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in
                f(a).run { b in
                    callback(b)
                }
            }
        }
    }
}

func zip<A, B, C>(with: @escaping (A, B) -> C)
    -> (Parallel<A>, Parallel<B>) -> Parallel<C> {
        return { l, r in
            return l.flatMap { a -> Parallel<C> in
                return r.map { b in with(a, b) }
            }
        }
}

// Parallel<Result<A, E>>

func map<A, B, E>(
    _ f: @escaping (A) -> B
) -> (Parallel<Result<A, E>>) -> Parallel<Result<B, E>> {
    return { parallelResultA in
        parallelResultA.map { resultA in
            resultA.map { a in f(a) }
        }
    }
}

func zip<A, B, E>(
    _ lhs: Parallel<Result<A, E>>,
    _ rhs: Parallel<Result<B, E>>
) -> Parallel<Result<(A, B), E>> {
    return zip(with: zip(with: { ($0, $1) }))(lhs, rhs)
}

func flatMap<A, B, E>(
    _ f: @escaping (A) -> Parallel<Result<B, E>>
) -> (Parallel<Result<A, E>>) -> Parallel<Result<B, E>> {
    return { parallelReturnA in
        parallelReturnA.flatMap { resultA -> Parallel<Result<B, E>> in
            Parallel<Result<B, E>> { callback in
                switch resultA {
                case let .success(a):
                    f(a).run { resultB in
                        callback(resultB)
                    }
                case let .failure(error):
                    callback(.failure(error))
                }
            }
        }
    }
}

// map: you can always map on both containers
// zip: you can always zip on both containers
// flatMap: you cannot just compose without unpacking the containers

public typealias NonEmptyArray<A> = NonEmpty<Array<A>>

enum Validated<A, E> {
    
    case valid(A)
    case invalid(NonEmptyArray<E>)
    
    func map<B>(_ f: @escaping (A) -> B) -> Validated<B, E> {
        switch self {
        case let .valid(a): return .valid(f(a))
        case let .invalid(e): return .invalid(e)
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Validated<B, E>) -> Validated<B, E> {
        switch self {
        case let .valid(a): return f(a)
        case let .invalid(e): return .invalid(e)
        }
    }
}

struct Func<A, B> {
    
    let run: (A) -> B
    
    func map<C>(_ f: @escaping (B) -> C) -> Func<A, C> {
        return Func<A, C>(run: self.run >>> f)
    }
    
    func flatMap<C>(_ f: @escaping (B) -> Func<A, C>) -> Func<A, C> {
        return Func<A, C> { (a) -> C in
            return f(self.run(a)).run(a)
        }
    }
}

extension Optional {
    func newMap<NewWrapped>(_ f: (Wrapped) -> NewWrapped) -> NewWrapped? {
        return self.flatMap { Optional<NewWrapped>.some(f($0)) }
    }
}

extension Array {
    func newMap<NewElement>(_ f: (Element) -> NewElement) -> [NewElement] {
        return self.flatMap { [f($0)] }
    }
}

extension Result {
    func newMap<B>(_ f: (A) -> B) -> Result<B, E> {
        return self.flatMap { .success(f($0)) }
    }
}

extension Validated {
    func newMap<B>(_ f: @escaping (A) -> B) -> Validated<B, E> {
        return self.flatMap { .valid(f($0)) }
    }
}

extension Func {
    func newMap<C>(_ f: @escaping (B) -> C) -> Func<A, C> {
        return self.flatMap { b in Func<A, C> { _ in f(b) } }
    }
}

extension Parallel {
    func newMap<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return self.flatMap { a in Parallel<B> { callback in callback(f(a)) } }
    }
}

func newZip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    return a.flatMap { a in
        b.flatMap { b in
            Optional.some((a, b))
        }
    }
}

func newZip<A, B>(_ a: [A], _ b: [B]) -> [(A, B)] {
    return a.flatMap { a in
        b.flatMap { b in
            [(a, b)]
        }
    }
}

newZip(["a", "b"], [1, 2])
// this is not the same zip, because it doesn't combine pairwise

func newZip<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
    return a.flatMap { a in
        b.flatMap { b in
            .success((a, b))
        }
    }
}

func newZip<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
    return a.flatMap { a in
        b.flatMap { b in
            .valid((a, b))
        }
    }
}

newZip(
    Validated<Int, String>.valid(1),
    Validated<Int, String>.valid(2)
)

newZip(
    Validated<Int, String>.valid(1),
    Validated<Int, String>.invalid(NonEmptyArray("2"))
)

newZip(
    Validated<Int, String>.invalid(NonEmptyArray("1")),
    Validated<Int, String>.invalid(NonEmptyArray("2"))
) // this is not the same zip, because it doesn't combine errors

func newZip<A, B, C>(_ a: Func<A, B>, _ b: Func<A, C>) -> Func<A, (B, C)> {
    return a.flatMap { a in
        b.flatMap { b in
            Func { _ in (a, b) }
        }
    }
}

func newZip<A, B>(_ a: Parallel<A>, _ b: Parallel<B>) -> Parallel<(A, B)> {
    return a.flatMap { a in
        b.flatMap { b in
            Parallel { callback in callback((a, b)) }
        }
    }
}

func delay(by duration: TimeInterval, line: UInt = #line) -> Parallel<Void> {
    return Parallel { callback in
        print("Delaying line \(line) by duration \(duration)")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            callback(())
            print("Executed line \(line)")
        }
    }
}

newZip(delay(by: 2).map { 2 }, delay(by: 3).map { 3 }).run {
    print($0)
} // this is not the same zip, because it doesn't run in parallel

// zip cannot always be defined using only flatMap!
// sometimes it doesn't work as the regular zip

/*
 
 Exercise 1.
 
 Implement flatMap on the nested type Result<A?, E>. It would have the signature:
 
 func flatMap<A, B, E>(
    _ f: @escaping (A) -> Result<B?, E>
 ) -> (Result<A?, E>) -> Result<B?, E> {
    fatalError("Implement me!")
 }
 
 */

func flatMap<A, B, E>(
    _ f: @escaping (A) -> Result<B?, E>
) -> (Result<A?, E>) -> Result<B?, E> {
    return { resultA in
        resultA.flatMap { a in
            guard let a = a else {
                return .success(nil)
            }
            return f(a)
        }
    }
}

 /*
 
 Exercise 2.
 
 Implement flatMap on the nested type Func<A, B?>. It would have the signature:
 
 func flatMap<A, B, C>(
 _ f: @escaping (B) -> Func<A, C?>
 ) -> (Func<A, B?>) -> Func<A, C?> {
 
 fatalError("Implement me!")
 }
 
 */

func flatMap<A, B, C>(
    _ f: @escaping (B) -> Func<A, C?>
) -> (Func<A, B?>) -> Func<A, C?> {
    return { funcB in
        funcB.flatMap { b in
            guard let b = b else {
                return Func<A, C?> { _ in nil }
            }
            return f(b)
        }
    }
    
}

/*
 
 Exercise 3.
 
 Implement flatMap on the nested type Parallel<A?>. It would have the signature:
 
 func flatMap<A, B>(
 _ f: @escaping (A) -> Parallel<B?>
 ) -> (Parallel<A?>) -> Parallel<B?> {
 
 fatalError("Implement me!")
 }
 
 */

func flatMap<A, B>(
    _ f: @escaping (A) -> Parallel<B?>
) -> (Parallel<A?>) -> Parallel<B?> {
    return { parallelA in
        parallelA.flatMap { a in
            guard let a = a else {
                return Parallel<B?>.init { callback  in
                    callback(nil)
                }
            }
            return f(a)
        }
    }
}

/*
 
 Exercise 4.
 
 Do you see anything in common with all of the implementations in the previous 3 exercises? It turns out that if a generic type F<A> has a flatMap operation, then you can define a flatMap on F<A?> in a natural way.
 
 */

// The common thing:
// * you can flatMap on outer container
// * then you need to open the Optional
// * if there's a value in Optional, just give it to f
// * if there's no value in Optional, create new F type with nil

/*
 
 Exercise 5.
 
 Implement flatMap on the nested type Func<A, Result<B, E>>. It would have the signature:
 
 flatMap: ((B) -> Func<A, Result<C, E>>)
 -> (Func<A, Result<B, E>>)
 -> Func<A, Result<C, E>>

 */

func flatMap<A, B, C, E>(_ f: @escaping (B) -> Func<A, Result<C, E>>)
    -> (Func<A, Result<B, E>>) -> Func<A, Result<C, E>> {
    return { funcA in
        funcA.flatMap { resultB in
            switch resultB {
            case let .success(b):
                return f(b)
            case let .failure(e):
                return Func<A, Result<C, E>> { _ in
                    .failure(e)
                }
            }
            
        }
    }
}

// The same idea as with optional

//: [Next](@next)
