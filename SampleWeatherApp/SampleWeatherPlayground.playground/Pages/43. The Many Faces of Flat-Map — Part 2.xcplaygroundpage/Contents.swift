//: [Previous](@previous)

import Foundation

extension Array {
    func flatMap<NewElement>(_ f: (Element) -> [NewElement]) -> [NewElement] {
        var result: [NewElement] = []
        for elem in self {
            result.append(contentsOf: f(elem))
        }
        return result
    }
}

[1, 2, 3]
    .flatMap { Array(repeating: $0, count: $0) }

extension Optional {
    func flatMap<NewWrapped>(_ f: (Wrapped) -> NewWrapped?) -> NewWrapped? {
        guard let wrapped = self else { return nil }
        return f(wrapped)
    }
}

let maybe42: String? = "42"

type(of:
    maybe42
        .flatMap { string in Int(string) }
)

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
        return Func<A, C> { a in
            return f(self.run(a)).run(a)
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
                f(a).run(callback)
            }
        }
    }
}

// map:     ((A) ->    C ) -> (([A])      -> [C])
// zip:     ((A, B) -> C ) -> (([A], [B]) -> [C])
// flatMap: ((A) ->   [C]) -> (([A])      -> [C])

// map:     ((A) ->    C ) -> (( A?)      ->  C?)
// zip:     ((A, B) -> C ) -> (( A?,  B?) ->  C?)
// flatMap: ((A) ->    C?) -> (( A?)      ->  C?)

// map:     ((A) ->        C    ) -> ((Result<A, E>)               -> Result<C, E>)
// zip:     ((A, B) ->     C    ) -> ((Result<A, E>, Result<B, E>) -> Result<C, E>)
// flatMap: ((A) -> Result<C, E>) -> ((Result<A, E>)               -> Result<C, E>)

// map:     ((A) ->        C    ) -> ((Validated<A, E>)               -> Validated<C, E>)
// zip:     ((A, B) ->     C    ) -> ((Validated<A, E>, Validated<B, E>) -> Validated<C, E>)
// flatMap: ((A) -> Validated<C, E>) -> ((Validated<A, E>)               -> Validated<C, E>)

// map:     ((B) ->        D    ) -> ((Func<A, B>)               -> Func<A, D>)
// zip:     ((B, C) ->     D    ) -> ((Func<A, B>, Func<A, C>) -> Func<A, D>)
// flatMap: ((B) -> Func<A, D>) -> ((Func<A, B>)               -> Func<A, D>)

// map:     ((A) ->        C    ) -> ((Parallel<A>)               -> Parallel<C>)
// zip:     ((A, B) ->     C    ) -> ((Parallel<A>, Parallel<B>) -> Parallel<C>)
// flatMap: ((A) -> Parallel<C>) -> ((Parallel<A>)               -> Parallel<C>)


// map:     ((A) ->      C ) -> ((F<A>)       -> F<C>)
// zip:     ((A, B) ->   C ) -> ((F<A>, F<B>) -> F<C>)
// flatMap: ((A)    -> F<C>) -> ((F<A>)       -> F<C>)

// F<A> = Array<A>
// F<A> = Optional<A>
// F<A> = Result<A, E>
// F<A> = Validated<A, E>
// F<A> = Func<A0, A>
// F<A> = Parallel<A>

//: [Next](@next)
