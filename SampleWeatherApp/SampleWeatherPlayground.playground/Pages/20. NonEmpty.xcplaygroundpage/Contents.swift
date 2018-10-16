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


protocol DictionaryProtocol {
    associatedtype Key: Hashable
    associatedtype Value
}

extension Dictionary: DictionaryProtocol {}

extension NonEmpty where C: DictionaryProtocol {
    
    init(_ head: (key: C.Key, value: C.Value), _ tail: C) {
        
    }
}


/*
 
 Exercise 6:
 
 Define updateValue(_:forKey:) on non-empty dictionaries.

 Answer 6:
 
 */

/*
 
 Exercise 7:
 
 Define merge and merging on non-empty dictionaries.

 Answer 7:
 
 */

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

/*
 
 Exercise 9:
 
 Swift Sequence also contains two split methods that split a Sequence into [Sequence.SubSequence]. They contain a parameter, omittingEmptySubsequences that prevents non-empty sub-sequences from being included in the resulting array.

 Splitting a non-empty collection, while omitting empty subsequences, should return a non-empty collection of non-empty collections. Define this version of split on NonEmpty.

 Answer 9:
 
 */

/*
 
 Exercise 10:
 
 What are some challenges with conditionally-conforming NonEmpty to Equatable? Consider the following check: NonEmptySet(1, 2, 3) == NonEmptySet(3, 2, 1). How can these challenges be overcome?

 Answer 10:
 
 */

/*
 
 Exercise 11:
 
 Define zip on non-empty arrays:

 func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {}
 
 Answer 11:

*/

//: [Next](@next)
