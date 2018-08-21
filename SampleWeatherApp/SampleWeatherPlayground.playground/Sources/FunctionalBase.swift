import Foundation

public struct Pair<A, B> {
    let a: A
    let b: B
}

public enum Either<A, B> {
    case left(A)
    case right(B)
}

public enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

public func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { a, b in
        return f(a)(b)
    }
}

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
    return { b in { a in f(a)(b) } }
}

public func zurry<A>(_ f: () -> A) -> A {
    return f()
}

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

public func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

precedencegroup BackwardApplication {
    associativity: right
}

infix operator <|: BackwardApplication

public func <| <A, B>(f: (A) -> B, a: A) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

precedencegroup BackwardsComposition {
    associativity: right
    higherThan: BackwardApplication
}

infix operator <<<: BackwardsComposition

public func <<< <A, B, C>(g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C {
    return { x in
        g(f(x))
    }
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >=>: EffectfulComposition

public func >=> <A, B, C>(
    _ f: @escaping (A) -> (B, [String]),
    _ g: @escaping (B) -> (C, [String])
    ) -> (A) -> (C, [String]) {

    return { a in
        let (b, logs) = f(a)
        let (c, moreLogs) = g(b)
        return (c, logs + moreLogs)
    }
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

public func <> <A>(
    f: @escaping (A) -> A,
    g: @escaping (A) -> A
    ) -> (A) -> A {
    return f >>> g
}

public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
    f(&a)
}

public func <> <A>(
    f: @escaping (inout A) -> Void,
    g: @escaping (inout A) -> Void
    ) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}

public func <> <A: AnyObject>(
    f: @escaping (A) -> Void,
    g: @escaping (A) -> Void
    ) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { $0.map(f) }
}

public func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
    return { $0.filter(p) }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
    return { $0.map(f) }
}

public func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
    return { pair in
        return (f(pair.0), pair.1)
    }
}

public func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
    return { pair in
        return (pair.0, f(pair.1))
    }
}

public func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (Root)
    -> Root {

        return { update in
            { root in
                var copy = root
                copy[keyPath: kp] = update(copy[keyPath: kp])
                return copy
            }
        }
}

public func mrop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (inout Root)
    -> Void {
        return { update in
            return { root in
                var copy = root
                copy[keyPath: kp] = update(copy[keyPath: kp])
                root = copy
            }
        }
}

public func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: kp]
    }
}

public func their<Root, Value>(
    _ f: @escaping (Root) -> Value,
    _ g: @escaping (Value, Value) -> Bool
    )
    -> (Root, Root)
    -> Bool {

        return { g(f($0), f($1)) }
}

public func their<Root, Value: Comparable>(
    _ f: @escaping (Root) -> Value
    )
    -> (Root, Root)
    -> Bool {

        return their(f, <)
}

public func combining<Root, Value>(
    _ f: @escaping (Root) -> Value,
    by g: @escaping (Value, Value) -> Value
    )
    -> (Value, Root)
    -> Value {

        return { value, root in
            g(value, f(root)) }
}

prefix operator ^
public prefix func ^ <Root, Value>(kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return get(kp)
}

public func with<A, B>(_ a: A, _ f: (A) -> B) -> B {
    return f(a)
}

public func pipe<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

public struct Tagged<Tag, RawValue> {
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
