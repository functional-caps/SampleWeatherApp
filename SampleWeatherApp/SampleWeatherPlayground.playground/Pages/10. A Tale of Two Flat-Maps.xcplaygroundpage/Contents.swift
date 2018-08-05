//: [Previous](@previous)

/*

 Exercise 1:

 Define filtered as a function from [A?] to [A].

 Answer 1:

 */

func filtered<A>(_ array: [A?]) -> [A] {
    var results = [A]()
    for elem in array {
        switch elem {
        case .some(let a): results.append(a)
        case .none: break
        }
    }
    return results
}

filtered([nil, 1, nil])

/*

 Exercise 2:

 Define partitioned as a function from [Either<A, B>] to (left: [A], right: [B]). What does this function have in common with filtered?

 Answer 2:

 */

func partitioned<A, B>(_ array: [Either<A, B>]) -> (left: [A], right: [B]) {
    var result = (left: [A](), right: [B]())
    for elem in array {
        switch elem {
        case .left(let a): result.left.append(a)
        case .right(let b): result.right.append(b)
        }
    }
    return result
}

// they heve the same idea: split the array of two-case enum (a sum type A + B) into two groups: As and Bs. It's just that filtered discards the Bs

//func partitioned<A, B>(_ array: [Either<A, B>])

/*

 Exercise 3:

 Define partitionMap on Optional.

 Answer 3:

 */

extension Optional {

    func partitionMap<A, B>(_ f: (Wrapped) -> Either<A, B>) -> (left: A?, right: B?) {
        if let elem = self {
            switch f(elem) {
            case .left(let a): return (a, nil)
            case .right(let b): return (nil, b)
            }
        }
        return (nil, nil)
    }

//    func partitionMap2<A, B>(_ f: (Wrapped) -> Either<A, B>) -> Either<A, B>? {
//        guard let elem = self else { return nil }
//        return f(elem)
//    }
}


/*

 Exercise 4:

 Dictionary has mapValues, which takes a transform function from (Value) -> B to produce a new dictionary of type [Key: B]. Define filterMapValues on Dictionary.

 Answer 4:

 */

extension Dictionary {
    func filterMapValues<B>(_ f: (Value) -> B?) -> [Key: B] {
        var result = [Key: B]()
        for (key, value) in self {
            if let b = f(value) {
                result[key] = b
            }
        }
        return result
    }
}

/*

 Exercise 5:

 Define partitionMapValues on Dictionary.

 Answer 5:

 */

extension Dictionary {
    func partitionMapValue<A, B>(_ f: (Value) -> Either<A, B>) -> (left: [Key: A], right: [Key: B]) {
        var result = (left: [Key: A](), right: [Key: B]())
        for (key, value) in self {
            switch f(value) {
            case .left(let a): result.left[key] = a
            case .right(let b): result.right[key] = b
            }
        }
        return result
    }
}

/*

 Exercise 6:

 Rewrite filterMap and filter in terms of partitionMap.

 Answer 6:

 */

extension Array {
    func partitionMap<A, B>(_ transform: (Element) -> Either<A, B>) -> (lefts: [A], rights: [B]) {
        var result = (lefts: [A](), rights: [B]())
        for x in self {
            switch transform(x) {
            case let .left(a):
                result.lefts.append(a)
            case let .right(b):
                result.rights.append(b)
            }
        }
        return result
    }

    func filterMap<B>(_ transform: (Element) -> B?) -> [B] {
        return partitionMap { element -> Either<B, Void> in
            guard let b = transform(element) else { return .right(()) }
            return .left(b)
        }.lefts
    }

    func filter(_ transform: (Element) -> Bool) -> [Element] {
        return partitionMap { element -> Either<Element, Element> in
            if transform(element) {
                return .left(element)
            } else {
                return .right(element)
            }
        }.lefts
    }
}

/*

 Exercise 7:

 Is it possible to define partitionMap on Either?

 Answer 7:

 */

extension Either {
    func partitionMap<C, D>(
        _ transformA: (A) -> Either<C, D>,
        _ transformB: (B) -> Either<C, D>
    ) -> Either<C, D> {
        let either: Either<C, D>
        switch self {
        case .left(let a): either = transformA(a)
        case .right(let b): either = transformB(b)
        }
        return either
    }
}

//: [Next](@next)
