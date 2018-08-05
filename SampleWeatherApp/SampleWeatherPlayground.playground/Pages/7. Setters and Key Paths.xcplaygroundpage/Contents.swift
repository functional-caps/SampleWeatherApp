//: [Previous](@previous)

struct Food {
    var name: String
}

struct Location {
    var name: String
}

struct User {
    var favoriteFoods: [Food]
    var location: Location
    var name: String
}

/*

 Exercise 1:

 In this episode we used Dictionary’s subscript key path without explaining it much. For a key: Key, one can construct a key path \.[key] for setting a value associated with key. What is the signature of the setter prop(\.[key])? Explain the difference between this setter and the setter prop(\.[key]) <<< map, where map is the optional map.

 Answer 1:

 */

//func prop<Root, Value>(_ kp: WritableKeyPath<Dictionary<Root, Value>, Optional<Value>>)
//    -> (@escaping (Optional<Value>) -> Optional<Value>)
//    -> (Dictionary<Root, Value>)
//    -> Dictionary<Root, Value> {
//        return { update in
//            return { root in
//                var copy = root
//                copy[keyPath: kp] = update(copy[keyPath: kp])
//                return copy
//            }
//        }
//}

["one" : 1, "two" : 2]
    |> (prop(\.["one"])) { _ in 42 }

// takes optional update
prop(\[String: Int].["one"])

// takes non-optional update
prop(\[String: Int].["one"]) <<< map

/*

 Exercise 2:

 The Set<A> type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn’t stop us from defining a functional setter! Define a function elem with signature (A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>, which is a functional setter that allows one to add and remove a value a: A to a set by providing a transformation (Bool) -> Bool, where the input determines if the value is already in the set and the output determines if the value should be included.

 Answer 2:


 */

func elem<A: Hashable>(_ a: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
    return { (checker: @escaping (Bool) -> Bool) in
        return { (set: Set<A>) -> Set<A> in
            let isInSet = set.contains(a)
            let shouldBeIncluded = checker(isInSet)
            var copy = set
            switch (isInSet, shouldBeIncluded) {
            case (true, true), (false, false): break;
            case (true, false): copy.remove(a)
            case (false, true): copy.insert(a)
            }
            return copy
        }
    }
}

let set = Set(arrayLiteral: 1, 2, 3, 3, 4, 5)
set
    |> (elem(1)) { !$0 }

/*

 Exercise 3:

 Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?

 Answer 3:

 */

var user = User(
    favoriteFoods: [
        Food(name: "ramen"), Food(name: "sushi")
    ],
    location: Location(name: "Warsaw"),
    name: "Krzysztof"
)

prop(\User.favoriteFoods)
user.favoriteFoods.first?.name

//???

/*

 Exercise 4:

 Recall from a previous episode that the free filter function on arrays has the signature ((A) -> Bool) -> ([A]) -> [A]. That’s kinda setter-like! What does the composed setter prop(\User.favoriteFoods) <<< filter represent?

 Answer 4:


 */

dump(
user
    |> (prop(\User.favoriteFoods) <<< filter) { _ in false }
)

// it represents filtering setter

/*

 Exercise 5:

 Define the Result<Value, Error> type, and create value and error setters for safely traversing into those cases.

 Answer 5:

 */

enum Result<Value, Error> {
    case success(Value)
    case failure(Error)
}

func success<Value, Error>()
    -> (@escaping (Value) -> Value)
    -> (Result<Value, Error>)
    -> Result<Value, Error> {
        return { update in
            return { result in
                switch result {
                case .success(let val):
                    return .success(update(val))
                case .failure: return result
                }
            }
        }
}

func failure<Value, Error>()
    -> (@escaping (Error) -> Error)
    -> (Result<Value, Error>)
    -> Result<Value, Error> {
        return { update in
            return { result in
                switch result {
                case .success: return result
                case .failure(let error): return .failure(update(error))
                }
            }
        }
}

Result<Int, String>.success(42)
    |> ((success()) { $0 * 2 })
    |> ((success()) { $0 * 2 })
    |> ((failure()) { $0.uppercased() })

Result<Int, String>.failure("aaa")
    |> ((success()) { $0 * 2 })
    |> ((failure()) { $0.uppercased() })

/*

 Exercise 6:

 Is it possible to make key path setters work with enums?

 Answer 6:
 */

//(\Value) -> (V -> V) -> R -> R

func success<Value, Error, Prop>(_ kp: WritableKeyPath<Value, Prop>)
    -> (@escaping (Prop) -> Prop)
    -> (Result<Value, Error>)
    -> Result<Value, Error> {
        return { update in
            return { result in
                switch result {
                case .success(let val):
                    var copy = val
                    copy[keyPath: kp] = update(copy[keyPath: kp])
                    return .success(copy)
                case .failure: return result
                }
            }
        }
}

func failure<Value, Error, Prop>(_ kp: WritableKeyPath<Error, Prop>)
    -> (@escaping (Prop) -> Prop)
    -> (Result<Value, Error>)
    -> Result<Value, Error> {
        return { update in
            return { result in
                switch result {
                case .success: return result
                case .failure(let error):
                    var copy = error
                    copy[keyPath: kp] = update(copy[keyPath: kp])
                    return .failure(copy)
                }
            }
        }
}

dump(
Result<User, Location>.success(
    User(favoriteFoods: [], location: Location(name: "Berlin"), name: "Krzysztof")
)
    |> (success(\.name)) { _ in "Magda" }
)

dump(
Result<User, Location>.failure(Location(name: "Warsaw"))
    |> (failure(\.name)) { _ in "Paris" }
)

/*

 Exercise 7:

 Redefine some of our setters in terms of inout. How does the type signature and composition change?

 Answer 7:

 */

public func propInout<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
    -> (@escaping (Value) -> Value)
    -> (inout Root)
    -> Void {
        return { update in
            { root in
                var copy = root
                copy[keyPath: kp] = update(copy[keyPath: kp])
                root = copy
            }
        }
}

func elemInout<A: Hashable>(_ a: A)
    -> (@escaping (Bool) -> Bool)
    -> (inout Set<A>)
    -> Void {
    return { (checker: @escaping (Bool) -> Bool) in
        return { set in
            let isInSet = set.contains(a)
            let shouldBeIncluded = checker(isInSet)
            var copy = set
            switch (isInSet, shouldBeIncluded) {
            case (true, true), (false, false): break;
            case (true, false): copy.remove(a)
            case (false, true): copy.insert(a)
            }
            set = copy
        }
    }
}

var copy = set
((elemInout(6)) { !$0 })(&copy)


//: [Next](@next)
