//: [Previous](@previous)

/*

 Exercise 1:

 Why shouldn’t NonEmpty conditionally conform to SetAlgebra when its underlying collection type also conforms to SetAlgebra?
 
 Answer 1:
 
 */

// because there might be a requirement for being empty,
// such as when the intersection between two separate sets is made.
// NonEmpty<Set> cannot express that

/*
 
 Exercise 2:

 Define the following method:

 extension NonEmpty where C: SetAlgebra {
     func contains(_ member: C.Element) -> Bool
 }

 Note that SetAlgebra does not require that elements are equatable, so utilize other methods on SetAlgebra to make this check.
 
 Answer 2:
 
 */

extension NonEmpty where C: SetAlgebra {
    func contains(_ member: C.Element) -> Bool {
        let set = NonEmpty(member, head)
        return set.count == 1 || tail.contains(member)
    }
}

NonEmptySet(1, 2, 3, 4, 5).contains(0)
NonEmptySet(1, 2, 3, 4, 5).contains(2)
NonEmptySet(1, 2, 3, 4, 5).contains(6)

/*
 
 Exercise 3:

 Define the following method:

 extension NonEmpty where C: SetAlgebra {
     func union(_ other: NonEmpty) -> NonEmpty
 }

 Ensure that no duplicate head element enters the resulting non-empty set. The following property should hold true:

 NonEmptySet(1, 2, 3).union(NonEmptySet(3, 2, 1)).count == 3

 Answer 3:
 
 */

extension NonEmpty where C: SetAlgebra {
    func union(_ other: NonEmpty) -> NonEmpty {
        var resultTail = self.tail.union(other.tail)
        resultTail.insert(other.head)
        return NonEmpty(head, resultTail)
    }
}

NonEmptySet(1, 2, 3).union(NonEmptySet(3, 2, 1)).count == 3
NonEmptySet(1).union(NonEmptySet(1)).count == 1
NonEmptySet(1, 2, 3).union(NonEmptySet(4, 5, 6)).count == 6
NonEmptySet(1, 2, 3).union(NonEmptySet(3, 4, 5)).count == 5

/*
 
 Exercise 4:
 
 Define a helper subscript on NonEmpty to access a non-empty dictionary’s element using the dictionary key. You can constrain the subscript over Key and Value generics to make this work.
 
 Answer 4:
 
 */

extension NonEmpty  {
    subscript<Key, Value>(key: Key) -> Value? where C == [Key : Value] {
        let (headKey, headValue) = self.head
        if headKey == key {
            return headValue
        } else {
            return tail[key]
        }
    }
}

typealias NonEmptyDictionary<Key, Value> = NonEmpty<[Key: Value]> where Key: Hashable

let dict = NonEmptyDictionary(("1", 2), ["3" : 4])
dict["1"]
dict["3"]
dict["5"]

/*
 
 Exercise 5:

 Our current implementation of NonEmpty allows for non-empty dictionaries to contain the head key twice! Write a constrained extension on NonEmpty to prevent this from happening. You will need create a DictionaryProtocol for Dictionary in order to make this work because Swift does not currently support generic extentions.

 // Doesn't work
 extension <Key, Value> NonEmpty where Element == [Key: Value] {}

 // Works
 protocol DictionaryProtocol {
     /* Expose necessary associated types and interface */
 }
 extension Dictionary: DictionaryProtocol {}
 extension NonEmpty where Element: DictionaryProtocol {}

 Look to the standard library APIs for inspiration on how to handle duplicate keys, like the init(uniqueKeysAndValues:) and init(_:uniquingKeysWith:) initializers.

 Answer 5:
 
 */

extension NonEmpty {
    
    init<Key, Value>(
        _ head: (key: Key, value: Value),
        _ tail: C,
        _ f: (Value, Value) -> Value
    ) where C == [Key: Value] {
        if let value = tail[head.key] {
            var copyTail = tail
            let chosenValue = f(head.value, value)
            copyTail.removeValue(forKey: head.key)
            self.init((key: head.key, value: chosenValue), copyTail)
        } else {
            self.init(head, tail)
        }

    }
}

let dict2 = NonEmptyDictionary(("1", 2), ["3" : 4]) {
    one, _ in  one
}
let dict3 = NonEmptyDictionary(("1", 2), ["1" : 4]) {
    one, _ in  one
}
let dict4 = NonEmptyDictionary(("1", 2), ["3" : 4, "1": 3]) {
    one, _ in  one
}

/*
 
 Exercise 6:
 
 Define updateValue(_:forKey:) on non-empty dictionaries.

 Answer 6:
 
 */

extension NonEmpty {

    mutating func updateValue<Key, Value>(
        _ value: Value, forKey key: Key
    ) where C == [Key: Value] {
        if head.key == key {
            head = (key: key, value: value)
        } else {
            tail[key] = value
        }
    }
}

var dict5 = NonEmptyDictionary(("1", 2), ["3" : 4, "5": 6])
dict5.updateValue(100, forKey: "1")
dict5.updateValue(200, forKey: "3")

/*
 
 Exercise 7:
 
 Define merge and merging on non-empty dictionaries.

 Answer 7:
 
 */

extension NonEmpty {
    
    func merging<Key, Value>(
        _ other: NonEmptyDictionary<Key, Value>,
        uniquingKeysWith combine: (Value, Value) -> Value
    ) -> NonEmptyDictionary<Key, Value> where C == [Key: Value] {
        var copyTail = self.tail

        for elem in other.tail {
            // The code is dupliated to not make the combine escaping
            let (otherKey, otherValue) = elem
            if let value = copyTail.removeValue(forKey: otherKey)  {
                copyTail[otherKey] = combine(otherValue, value)
            } else {
                copyTail[otherKey] = otherValue
            }
        }

        for elem in [other.head] {
            // The code is dupliated to not make the combine escaping
            let (otherKey, otherValue) = elem
            if let value = copyTail.removeValue(forKey: otherKey)  {
                copyTail[otherKey] = combine(otherValue, value)
            } else {
                copyTail[otherKey] = otherValue
            }
        }

        var copyHead = self.head
        let (otherKey, otherValue) = copyHead
        if let value = copyTail.removeValue(forKey: otherKey)  {
            copyHead.value = combine(otherValue, value)
        }

        return NonEmptyDictionary(copyHead, copyTail)
    }

    mutating func merge<Key, Value>(
        _ other: NonEmptyDictionary<Key, Value>,
        uniquingKeysWith combine: (Value, Value) -> Value
    ) where C == [Key: Value] {
        var copyTail = self.tail

        for elem in other.tail {
            // The code is dupliated to not make the combine escaping
            let (otherKey, otherValue) = elem
            if let value = copyTail.removeValue(forKey: otherKey)  {
                copyTail[otherKey] = combine(otherValue, value)
            } else {
                copyTail[otherKey] = otherValue
            }
        }

        for elem in [other.head] {
            // The code is dupliated to not make the combine escaping
            let (otherKey, otherValue) = elem
            if let value = copyTail.removeValue(forKey: otherKey)  {
                copyTail[otherKey] = combine(otherValue, value)
            } else {
                copyTail[otherKey] = otherValue
            }
        }

        var copyHead = self.head
        let (otherKey, otherValue) = copyHead
        if let value = copyTail.removeValue(forKey: otherKey)  {
            copyHead.value = combine(otherValue, value)
        }

        self.head = copyHead
        self.tail = copyTail
    }
}

var dict6 = NonEmptyDictionary(("1", 2), ["3" : 4, "5": 6])
var dict7 = NonEmptyDictionary(("1", 2), ["3" : 4, "7": 8])
var dict8 = NonEmptyDictionary(("2", 3), ["4" : 5, "5": 6])
dict6
    .merging(dict7) { one, _ in one }
dict7
    .merge(dict8) { one, _ in one }

/*
 
 Exercise 8:
 
 Swift Sequence contains two joined methods that flattens a nested sequence given an optional separator sequence. For example:

 ["Get ready", "get set", "go!"].joined("...")
 // "Get ready...get set...go!"

 [[1], [1, 2], [1, 2, 3]].joined([0, 0])
 // [1, 0, 0, 1, 2, 0, 0, 1, 2, 3]

 A non-empty collection of non-empty collections, when joined, should also be non-empty. Write a joined function that does so. How must the collection be constrained?

 Answer 8:
 
 */

// NonEmpty<Array<NonEmpty<Array<Int>>

extension NonEmpty where C: RangeReplaceableCollection {

    private var elements: C {
        var elementsFromCollection = C()
        elementsFromCollection.append(head)
        elementsFromCollection.append(contentsOf: tail)
        return elementsFromCollection
    }

}

extension NonEmpty {

    func joinedNE<InnerCollection>(
        separator: NonEmpty<InnerCollection>?
        ) -> NonEmpty<InnerCollection> where Element == NonEmpty<InnerCollection>, InnerCollection: RangeReplaceableCollection {
        var elementsFromSeparator = InnerCollection()
        if let separator = separator {
            elementsFromSeparator = separator.elements
        }

        let newHead = self.head.head
        var newTail: InnerCollection = self.head.tail
        newTail.append(contentsOf: elementsFromSeparator)

        if let last = self.tail.reversed().first {
            for collection in self.tail.dropLast() {
                newTail.append(contentsOf: collection.elements)
                newTail.append(contentsOf: elementsFromSeparator)
            }
            newTail.append(contentsOf: last)
        }


        return NonEmpty<InnerCollection>(newHead, newTail)
    }
}

let s1 = NonEmpty<Array<Int>>(1, 2, 3)
let s2 = NonEmpty<Array<Int>>(4, 5, 6)
let s3 = NonEmpty<Array<Int>>(7, 8, 9)
let s4 = NonEmpty<Array<Int>>(0, 0, 0)

let asd =
    NonEmpty<Array<NonEmpty<Array<Int>>>>.init(s1, s2, s3)
dump(
    asd
        .joinedNE(separator: s4)
)

// how to construct it?

/*
 
 Exercise 9:
 
 Swift Sequence also contains two split methods that split a Sequence into [Sequence.SubSequence]. They contain a parameter, omittingEmptySubsequences that prevents non-empty sub-sequences from being included in the resulting array.

 Splitting a non-empty collection, while omitting empty subsequences, should return a non-empty collection of non-empty collections. Define this version of split on NonEmpty.

 Answer 9:
 
 */

[1,2,3,4,1,2,1,1,2,2]
    .split(maxSplits: Int.max, omittingEmptySubsequences: true, whereSeparator: { _ in false })

extension NonEmpty {
    func splitNE<OuterCollection>(
        whereSeparator shouldSeparate: (C.Element) -> Bool
    ) -> NonEmpty<OuterCollection> where OuterCollection.Element == NonEmpty<C>, C: RangeReplaceableCollection, OuterCollection: RangeReplaceableCollection {
        var outer = OuterCollection()
        var inner = C()

        if !shouldSeparate(self.head) {
            inner.append(self.head)
        }

        for elem in self.tail {
            if shouldSeparate(elem) {

                if let head = inner.first {
                    let tail = C(inner.dropFirst())
                    let newNE = NonEmpty<C>(head, tail)
                    outer.append(newNE)
                    inner.removeAll(keepingCapacity: true)

                } else {
                    continue
                }

            } else {
                inner.append(elem)
            }
        }

        if let head = inner.first {
            let tail = C(inner.dropFirst())
            let newNE = NonEmpty<C>(head, tail)
            outer.append(newNE)
            inner.removeAll(keepingCapacity: true)
        }


        if let head = outer.first {
            let tail = OuterCollection(outer.dropFirst())
            return NonEmpty<OuterCollection>(head, tail)
        } else {
            fatalError("Couldn't make nonempty collection out of empty data source")
        }

    }

    func splitNEq<OuterCollection>(
        separator: C.Element
        ) -> NonEmpty<OuterCollection> where C.Element: Equatable, OuterCollection.Element == NonEmpty<C>, C: RangeReplaceableCollection, OuterCollection: RangeReplaceableCollection {
        return self.splitNE(whereSeparator: { elem in elem == separator })
    }
}

let arr: NonEmpty<Array<NonEmpty<Array<Int>>>> =
    NonEmpty<Array<Int>>(1, 2, 3, 1, 4, 5, 6, 1, 7, 1, 8, 9)
    .splitNEq(separator: 1)

/*
 
 Exercise 10:
 
 What are some challenges with conditionally-conforming NonEmpty to Equatable? Consider the following check: NonEmptySet(1, 2, 3) == NonEmptySet(3, 2, 1). How can these challenges be overcome?

 Answer 10:
 
 */

extension NonEmpty: Equatable where C: Equatable, C.Element: Equatable {
    public static func == (lhs: NonEmpty<C>, rhs: NonEmpty<C>) -> Bool {
        if lhs.head == rhs.head {
            return lhs.tail == rhs.tail
        } else {
            let rHeadInL = lhs.tail.contains { elem -> Bool in
                elem == rhs.head
            }
            let lHeadInR = rhs.tail.contains { elem -> Bool in
                elem == lhs.head
            }
            if rHeadInL && lHeadInR {
                let newLHS = lhs.tail.filter { elem -> Bool in
                    elem != rhs.head
                }
                let newRHS = rhs.tail.filter { elem -> Bool in
                    elem != lhs.head
                }
                return newLHS == newRHS
            }
        }
        return false
    }
}

s1 == s2
s1 == s1

NonEmptySet(1, 2, 3) == NonEmptySet(3, 2, 1)

/*
 
 Exercise 11:
 
 Define zip on non-empty arrays:

 func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {}
 
 Answer 11:

*/

func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {
    let head = (a.head, b.head)
    let tail = Array(zip(a.tail, b.tail))
    return NonEmpty<[(A, B)]>(head, tail)
}

//: [Next](@next)
