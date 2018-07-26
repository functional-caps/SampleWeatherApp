//: [Previous](@previous)

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
  return f(a)
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in
    g(f(a))
  }
}

precedencegroup BackwardsComposition {
  associativity: right
}

infix operator <<<: BackwardsComposition

func <<< <A, B, C>(g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C {
  return { x in
    g(f(x))
  }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

func zurry<A>(_ f: () -> A) -> A {
  return f()
}

/*

 Exercise 1:

 As we saw with free map on Array, define free map on Optional and use it to compose setters that traverse into an optional field.

 Answer 1:

 */

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  return { data in
    data.map(f)
  }
}

func incr(a: Int) -> String {
  return "\(a + 1)"
}

let maybeInt: Int? = 42

maybeInt |> map(incr)

/*

 Exercise 2:

 Take a struct, e.g.:

 struct User {
 let name: String
 }

 Write a setter for its property. Take (or add) another property, and add a setter for it. What are some potential issues with building these setters?

 Answer 2:

 */

import Foundation

struct User {
  let name: String
  let birthday: Date
}

func nameSetter(_ f: @escaping (String) -> String) -> (User) -> User {
  return { user in
    return User(name: f(user.name), birthday: user.birthday)
  }
}

func birthdaySetter(_ f: @escaping (Date) -> Date) -> (User) -> User {
  return { user in
    return User(name: user.name, birthday: f(user.birthday))
  }
}

User(name: "Me", birthday: Date(timeIntervalSince1970: 1_000))
  |> birthdaySetter { _ in Date(timeIntervalSince1970: 1_000_000_000) }
  |> nameSetter { _ in "You" }

// Problem: too many of them!

/*

 Exercise 3:

 Take a struct with a nested struct, e.g.:

 struct Location {
 let name: String
 }

 struct User {
 let location: Location
 }

 Write a setter for userLocationName. Now write setters for userLocation and locationName. How do these setters compose?

 Answer 3:

 */

struct Location {
  let name: String
}

struct UserWithLocation {
  let location: Location
}

func userLocationName(_ f: @escaping (String) -> String) -> (UserWithLocation) -> UserWithLocation {
  return { user in
    return UserWithLocation(location: Location(name: f(user.location.name)))
  }
}

func userLocation(_ f: @escaping (Location) -> Location) -> (UserWithLocation) -> UserWithLocation {
  return { user in
    return UserWithLocation(location: f(user.location))
  }
}

func locationName(_ f: @escaping (String) -> String) -> (Location) -> Location {
  return { location in
    return Location(name: f(location.name))
  }
}

UserWithLocation(location: Location(name: "London"))
  |> userLocationName { _ in "Paris" }

UserWithLocation(location: Location(name: "London"))
  |> userLocation { location in location |> locationName { _ in "Paris" }  }

UserWithLocation(location: Location(name: "London"))
  |> (userLocation <<< locationName) { _ in "Paris" }

/*

 Exercise 4:

 Do first and second work with tuples of three or more values? Can we write first, second, third, and nth for tuples of n values?

 Answer 4:

 */

func first<A, B, C, D>(_ f: @escaping (A) -> D) -> ((A, B, C)) -> (D, B, C) {
  return { pair in
    return (f(pair.0), pair.1, pair.2)
  }
}

func second<A, B, C, D>(_ f: @escaping (B) -> D) -> ((A, B, C)) -> (A, D, C) {
  return { pair in
    return (pair.0, f(pair.1), pair.2)
  }
}

func third<A, B, C, D>(_ f: @escaping (C) -> D) -> ((A, B, C)) -> (A, B, D) {
  return { pair in
    return (pair.0, pair.1, f(pair.2))
  }
}

// it's possible to write for any number of elements, but a lot of boilerplate

(1, 2, 3)
  |> first(incr)
  |> second(incr)
  |> third(incr)


/*

 Exercise 5:

 Write a setter for a dictionary that traverses into a key to set a value.

 Answer 5:

 */

func setDict<A, B>(_ f: @escaping (B?) -> B) -> (A) -> ([A : B]) -> [A : B] {
  return { key in
    return { dict in
      var dictCopy = dict
      dictCopy[key] = f(dict[key])
      return dictCopy
    }
  }
}

func update(val: Int?) -> Int {
  if let val = val { return val + 1 } else { return 42 }
}

["ala" : 3, "ma": 2, "kota" : 4]
  |> ("ala" |> setDict(update))

["ala" : 3, "ma": 2, "kota" : 4]
  |> ("a" |> setDict(update))

/*

 Exercise 6:

 Write a setter for a dictionary that traverses into a key to set a value if and only if that value already exists.

 Answer 6:

 */

func setDict2<A, B>(_ f: @escaping (B) -> B) -> (A) -> ([A : B]) -> [A : B] {
  return { key in
    return { dict in
      var dictCopy = dict
      if let value = dict[key] {
        dictCopy[key] = f(value)
      }
      return dictCopy
    }
  }
}

["ala" : 3, "ma": 2, "kota" : 4]
|> ("ala" |> setDict2(update) )

["ala" : 3, "ma": 2, "kota" : 4]
  |> ("a" |> setDict2(update) )

/*

 Exercise 7:

 What is the difference between a function of the form ((A) -> B) -> (C) -> (D) and one of the form (A) -> (B) -> (C) -> D?

 Answer 7:

 */

// ((A) -> B) -> (C) -> D means that the first argument is a function (A) -> B, the second argument is C and the result is D

// (A) -> (B) -> (C) -> D means that the first argument is A, second is B, third is C and the result is D

// there's already some logic that expresses the mapping from (A) -> B that we cannot easily extract

//func uncurry<A, B, C, D>(f: @escaping (A) -> (B) -> (C) -> D) -> ((A) -> B) -> (C) -> D {
//  return { ab: (A) -> B in
//    return { b in
//      return { c in
//        f(a)
//      }
//    }
//  }
//}
//
//
//func curry<A, B, C, D>(f: @escaping ((A) -> B) -> (C) -> D) -> (A) -> (B) -> (C) -> D {
//  return { a in
//    return { b in
//      return { c in
//        f(/* what to write here? */)(c)
//      }
//    }
//  }
//}

//: [Next](@next)
