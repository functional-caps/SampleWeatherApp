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

public func prop<Root, Value>(
    _ kp: WritableKeyPath<Root, Value>,
    _ f: @escaping (Value) -> Value
    )
    -> (Root) -> Root {

    return prop(kp)(f)
}

public func prop<Root, Value>(
    _ kp: WritableKeyPath<Root, Value>,
    _ value: Value
    )
    -> (Root) -> Root {

    return prop(kp) { _ in value }
}

public typealias Setter<S, T, A, B> = (@escaping (A) -> B) -> (S) -> T

public func over<S, T, A, B>(
    _ setter: Setter<S, T, A, B>,
    _ set: @escaping (A) -> B
    )
    -> (S) -> T {

    return setter(set)
}

public func set<S, T, A, B>(
    _ setter: Setter<S, T, A, B>,
    _ value: B
    )
    -> (S) -> T {

    return over(setter) { _ in value }
}

public prefix func ^ <Root, Value>(kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (Root) -> Root {

    return prop(kp)
}

public typealias MutableSetter<S, A> = (@escaping (inout A) -> Void) -> (inout S) -> Void

public func mver<S, A>(
    _ setter: MutableSetter<S, A>,
    _ set: @escaping (inout A) -> Void
    )
    -> (inout S) -> Void {
        return setter(set)
}

public func mut<S, A>(
    _ setter: MutableSetter<S, A>,
    _ value: A
    )
    -> (inout S) -> Void {
        return mver(setter) { $0 = value }
}

public prefix func ^ <Root, Value>(
    _ kp: WritableKeyPath<Root, Value>
    )
    -> (@escaping (inout Value) -> Void)
    -> (inout Root) -> Void {

    return { update in
        { root in
            update(&root[keyPath: kp])
        }
    }
}

public func |> <A>(_ a: A, _ f: (inout A) -> Void) -> A {
    var a = a
    f(&a)
    return a
}

public func mutEach<A>(_ f: @escaping (inout A) -> Void) -> (inout [A]) -> Void {
    return {
        for i in $0.indices {
            f(&$0[i])
        }
    }
}

public struct Func<A, B> {
    public let apply: (A) -> B
    public init(apply: @escaping (A) -> B) {
        self.apply = apply
    }
}

public struct NonEmpty<C: Collection> {
    public var head: C.Element
    public var tail: C
    
    public init(_ head: C.Element, _ tail: C) {
        self.head = head
        self.tail = tail
    }
}

extension NonEmpty: CustomStringConvertible {
    public var description: String {
        return "\(self.head)\(self.tail)"
    }
}

public extension NonEmpty where C: RangeReplaceableCollection {
    init(_ head: C.Element, _ tail: C.Element...) {
        self.head = head
        self.tail = C(tail)
    }
}

extension NonEmpty: Collection {

    public typealias Element = C.Element

    public enum Index: Comparable {
        case head
        case tail(C.Index)
        
        public static func < (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.head, .tail):
                return true
            case (.tail, .head):
                return false
            case (.head, .head):
                return false
            case let (.tail(l), .tail(r)):
                return l < r
            }
        }
    }
    
    public var startIndex: Index {
        return .head
    }
    
    public var endIndex: Index {
        return .tail(self.tail.endIndex)
    }
    
    public subscript(position: Index) -> C.Element {
        switch position {
        case .head:
            return self.head
        case let .tail(index):
            return self.tail[index]
        }
    }
    
    public func index(after i: Index) -> Index {
        switch i {
        case .head:
            return .tail(self.tail.startIndex)
        case let .tail(index):
            return .tail(self.tail.index(after: index))
        }
    }
}

public extension NonEmpty {
    var first: C.Element {
        return self.head
    }
}

extension NonEmpty: BidirectionalCollection where C: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        switch i {
        case .head:
            return .tail(self.tail.index(before: self.tail.startIndex))
        case let .tail(index):
            return index == self.tail.startIndex ? .head : .tail(self.tail.index(before: index))
        }
    }
}

public extension NonEmpty where C: BidirectionalCollection {
    var last: C.Element {
        return self.tail.last ?? self.head
    }
}

public extension NonEmpty where C.Index == Int {
    subscript(position: Int) -> C.Element {
        return self[position == 0 ? .head : .tail(position - 1)]
    }
}

extension NonEmpty: MutableCollection where C: MutableCollection {
    public subscript(position: Index) -> C.Element {
        get {
            switch position {
            case .head:
                return self.head
            case let .tail(index):
                return self.tail[index]
            }
        }
        set(newValue) {
            switch position {
            case .head:
                self.head = newValue
            case let .tail(index):
                self.tail[index] = newValue
            }
        }
    }
}

public extension NonEmpty where C: MutableCollection, C.Index == Int {
    subscript(position: Int) -> C.Element {
        get {
            return self[position == 0 ? .head : .tail(position - 1)]
        }
        set {
            self[position == 0 ? .head : .tail(position - 1)] = newValue
        }
    }
}

public extension NonEmpty where C: SetAlgebra {
    init(_ head: C.Element, _ tail: C) {
        var tail = tail
        tail.remove(head)
        self.head = head
        self.tail = tail
    }
    init(_ head: C.Element, _ tail: C.Element...) {
        var tail = C(tail)
        tail.remove(head)
        self.head = head
        self.tail = tail
    }
}

public typealias NonEmptySet<A> = NonEmpty<Set<A>> where A: Hashable

public struct Gen<A> {
    public let run: () -> A
    public init(run: @escaping () -> A) { self.run = run }
}

extension Gen {
    public func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

extension Gen {
    public func array(count: Gen<Int>) -> Gen<[A]> {
        return Gen<[A]> {
            Array(repeating: (), count: count.run()).map(self.run)
        }
    }
}

public func int(in range: ClosedRange<Int>) -> Gen<Int> {
    return .init { Int.random(in: range) } // this is alternative implementation
}

public func element<A>(of xs: [A]) -> Gen<A?> {
    return int(in: 0...(xs.count - 1)).map { index in
        guard !xs.isEmpty else { return nil }
        return xs[index]
    }
}
