//: [Previous](@previous)

import Foundation

struct User: Codable {
    let email: String
    let id: Int
    let name: String
}

let user: User?

if let path = Bundle.main.path(forResource: "user", ofType: "json"),
    case let url = URL.init(fileURLWithPath: path),
    let data = try? Data.init(contentsOf: url) {
    user = try? JSONDecoder().decode(User.self, from: data)
} else {
    user = nil
}

print(user)

let user2 = Bundle.main.path(forResource: "user", ofType: "json")
    .map(URL.init(fileURLWithPath:))
    .flatMap { try? Data.init(contentsOf: $0) }
    .flatMap { try? JSONDecoder().decode(User.self, from: $0) }

print(user2)

struct Invoice: Codable {
    let amountDue: Int
    let amountPaid: Int
    let closed: Bool
    let id: Int
}

let invoices = Bundle.main.path(forResource: "invoices", ofType: "json")
    .map(URL.init(fileURLWithPath:))
    .flatMap { try? Data.init(contentsOf: $0) }
    .flatMap { try? JSONDecoder().decode([Invoice].self, from: $0) }

print(invoices)

func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}

zip(user2, invoices)

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (A?, B?) -> C? {
    return { a, b in
        guard let a = a, let b = b else { return nil }
        return f(a, b)
    }
}

struct UserEnvelope {
    let user: User
    let invoices: [Invoice]
}

print(
zip(with: UserEnvelope.init)(
    Bundle.main.path(forResource: "user", ofType: "json")
        .map(URL.init(fileURLWithPath:))
        .flatMap { try? Data.init(contentsOf: $0) }
        .flatMap { try? JSONDecoder().decode(User.self, from: $0) },
    Bundle.main.path(forResource: "invoices", ofType: "json")
        .map(URL.init(fileURLWithPath:))
        .flatMap { try? Data.init(contentsOf: $0) }
        .flatMap { try? JSONDecoder().decode([Invoice].self, from: $0) }
)
)

struct SomeExpected: Error {}

func requireSome<A>(_ a: A?) throws -> A {
    if let a = a { return a }
    else { throw SomeExpected() }
}

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


extension Result where E == Swift.Error {
    init(catching f: () throws -> A) {
        do {
            self = .success(try f())
        } catch {
            self = .failure(error)
        }
    }
}

let userResult = Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
    .map(URL.init(fileURLWithPath:))
    .flatMap { url in Result { try Data.init(contentsOf: url) } }
    .flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) } }

let invoicesResult = Result { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
    .map(URL.init(fileURLWithPath:))
    .flatMap { url in Result { try Data.init(contentsOf: url) } }
    .flatMap { data in Result { try JSONDecoder().decode([Invoice].self, from: data) } }

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

zip(with: UserEnvelope.init)(
    Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Result { try Data.init(contentsOf: url) } }
        .flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) } },
    Result { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Result { try Data.init(contentsOf: url) } }
        .flatMap { data in Result { try JSONDecoder().decode([Invoice].self, from: data) } }
)

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

extension Validated where E == Swift.Error {
    init(catching f: () throws -> A) {
        do {
            self = .valid(try f())
        } catch {
            self = .invalid(NonEmptyArray(error, []))
        }
    }
}

func zip<A, B, C, E>(with: @escaping (A, B) -> C)
    -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {
    return { l, r in
        switch (l, r) {
        case let (.valid(vl), .valid(vr)): return .valid(with(vl, vr))
            case let (.invalid(el), .valid): return .invalid(el)
            case let (.valid, .invalid(er)): return .invalid(er)
            case let (.invalid(el), .invalid(er)):
                return .invalid(NonEmptyArray(el.head, el.tail + [er.head] + er.tail))
        }
    }
}

zip(with: UserEnvelope.init)(
    Validated { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Validated { try Data.init(contentsOf: url) } }
        .flatMap { data in Validated { try JSONDecoder().decode(User.self, from: data) } },
    Validated { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Validated { try Data.init(contentsOf: url) } }
        .flatMap { data in Validated { try JSONDecoder().decode([Invoice].self, from: data) } }
)

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

func zip<A, B, C, D>(
    with: @escaping (B, C) -> D
) -> (Func<A, B>, Func<A, C>) -> Func<A, D> {
    return { l, r in
        return l.flatMap { (b) -> Func<A, D> in
            return r.map { c in with(b, c) }
        }
    }
}

let lazyEnvelope = zip(with: UserEnvelope.init)(
    Func { Bundle.main.path(forResource: "user", ofType: "json")! }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Func { try! Data.init(contentsOf: url) } }
        .flatMap { data in Func { try! JSONDecoder().decode(User.self, from: data) } },
    Func { Bundle.main.path(forResource: "invoices", ofType: "json")! }
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Func { try! Data.init(contentsOf: url) } }
        .flatMap { data in Func { try! JSONDecoder().decode([Invoice].self, from: data) } }
)

print(lazyEnvelope.run(()))

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

extension Parallel {
    init(_ work: @autoclosure @escaping () -> A) {
        self = Parallel { callback in
            DispatchQueue.global(qos: .background).async {
                callback(work())
            }
        }
    }
}

let parallelEnvelope = zip(with: UserEnvelope.init)(
    Parallel(Bundle.main.path(forResource: "user", ofType: "json")!)
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Parallel(try! Data.init(contentsOf: url)) }
        .flatMap { data in Parallel(try! JSONDecoder().decode(User.self, from: data)) },
    Parallel(Bundle.main.path(forResource: "invoices", ofType: "json")!)
        .map(URL.init(fileURLWithPath:))
        .flatMap { url in Parallel(try! Data.init(contentsOf: url)) }
        .flatMap { data in Parallel(try! JSONDecoder().decode([Invoice].self, from: data)) }
)

parallelEnvelope.run {
    print("parallel: \($0)")
}

//: [Next](@next)
