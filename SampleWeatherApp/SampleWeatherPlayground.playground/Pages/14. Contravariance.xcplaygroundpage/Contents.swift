//: [Previous](@previous)

/*

 Exercise 1:

 Determine the sign of all the type parameters in the function (A) -> (B) -> C. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.

 Answer 1:

 */

/*
 (A) -> ((B) -> C)
        |__|  |__|
         -1    +1
|___|  |__________|
 -1         +1


 A: -1
 B: -1
 C: +1
 */


/*

 Exercise 2:

 Determine the sign of all the type parameters in the following function:

 (A, B) -> (((C) -> (D) -> E) -> F) -> G

 Answer 2:

 */

/*

 (A, B) -> ((((C) -> (D) -> E) -> F) -> G)
             |___|  |___|
               -1     +1
             |_________|   |__|
                  -1        +1
             |_______________|   |__|
                    -1            +1
             |_____________________|   |__|
                       -1               +1
 |____|    |_____________________________|
   -1                     +1

 (A, B): -1
 C: +1
 D: -1
 E: +1
 F: -1
 G: +1

 */

/*

 Exercise 3:

 Recall that a setter is just a function ((A) -> B) -> (S) -> T. Determine the variance of each type parameter, and define a map and contramap for each one. Further, for each map and contramap write a description of what those operations mean intuitively in terms of setters.

 Answer 3:

 */

/*

 ((A) -> B) -> ((S) -> T)
 |___|  |__|   |___|  |__|
   -1    +1     -1     +1
 |_________|   |_________|
     -1            +1

 A: +1 covariance
 B: -1 contravariance
 S: -1 contravariance
 T: +1 covariance

 */

struct Setter<A, B, S, T> {
    let set: (@escaping (A) -> B) -> (S) -> T
}

func map<A, B, S, T, C>(_ f: @escaping (A) -> C) -> (Setter<A, B, S, T>) -> Setter<C, B, S, T> {
    return { (setter: Setter<A, B, S, T>) in
        Setter { (cb: @escaping (C) -> B) in
            setter.set(f >>> cb)
        }
    }
}

func contramap<A, B, S, T, C>(_ f: @escaping (C) -> B) -> (Setter<A, B, S, T>) -> Setter<A, C, S, T> {
    return { (setter: Setter<A, B, S, T>) in
        Setter { (ac: @escaping (A) -> C) in
            setter.set(ac >>> f)
        }
    }
}

func contramap<A, B, S, T, C>(_ f: @escaping (C) -> S) -> (Setter<A, B, S, T>) -> Setter<A, B, C, T> {
    return { (setter: Setter<A, B, S, T>) in
        Setter { (ab: @escaping (A) -> B) in
            f >>> setter.set(ab)
        }
    }
}

func map<A, B, S, T, C>(_ f: @escaping (T) -> C) -> (Setter<A, B, S, T>) -> Setter<A, B, S, C> {
    return { (setter: Setter<A, B, S, T>) in
        Setter { (ab: @escaping (A) -> B) in
            setter.set(ab) >>> f
        }
    }
}

/*

 Exercise 4:

 Define union, intersect, and invert on PredicateSet.

 Answer 4:

 */

struct PredicateSet<A> {
    let contains: (A) -> Bool
}

func union<A>(lhs: PredicateSet<A>, rhs: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet<A> { lhs.contains($0) || rhs.contains($0) }
}

func intersect<A>(lhs: PredicateSet<A>, rhs: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet<A> { lhs.contains($0) && rhs.contains($0) }
}

func invert<A>(set: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet<A> { !set.contains($0) }
}

/*

 Exercise 5:

 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.
 1) Create a predicate set powersOf2: PredicateSet<Int> that determines if a value is a power of 2, i.e. 2^n for some n: Int.
 2) Use the above predicate set to derive a new one powersOf2Minus1: PredicateSet<Int> that tests if a number is of the form 2^n - 1 for n: Int.
 3) Find an algorithm online for testing if an integer is prime, and turn it into a predicate primes: PredicateSet<Int>.
 4) The intersection primes.intersect(powersOf2Minus1) consists of numbers known as Mersenne primes. Compute the first 10.
 5) Recall that && and || are short-circuiting in Swift. How does that translate to union and intersect?
 6) What is the difference between primes.intersect(powersOf2Minus1) and powersOf2Minus1.intersect(primes)? Which one represents a more performant predicate set?

 Answer 5:

*/

// 1)
let powersOf2 = PredicateSet<Int> { $0.nonzeroBitCount == 1 && $0 != 1 }

powersOf2.contains(-2)
powersOf2.contains(3)
powersOf2.contains(4)
powersOf2.contains(8)
powersOf2.contains(15)

// 2)
extension PredicateSet {
    func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
        return PredicateSet<B>(contains: f >>> self.contains)
    }
}

let incr: (Int) -> Int = { $0 + 1 }

let powersOf2Minus1 = powersOf2.contramap(incr)

powersOf2Minus1.contains(-2)
powersOf2Minus1.contains(3)
powersOf2Minus1.contains(4)
powersOf2Minus1.contains(8)
powersOf2Minus1.contains(15)

// 3)
/*
 function is_prime(n)
 if n ≤ 1
   return false
 else if n ≤ 3
   return true
 else if n mod 2 = 0 or n mod 3 = 0
   return false
 let i ← 5
 while i * i ≤ n
   if n mod i = 0 or n mod (i + 2) = 0
     return false
   i ← i + 6
 return true
 */
func isPrime(n: Int) -> Bool {
    guard n > 1 else { return false }
    guard n > 3 else { return true }
    guard n % 2 != 0 && n % 3 != 0 else { return false }
    var i = 5
    while i * i < n {
        guard n % i != 0 && n % (i + 2) != 0 else { return false }
        i += 6
    }
    return true
}

let primes = PredicateSet<Int>(contains: isPrime)
primes.contains(1)
primes.contains(2)
primes.contains(3)
primes.contains(4)
primes.contains(5)
primes.contains(6)
primes.contains(7)
primes.contains(8)
primes.contains(9)
primes.contains(10)
primes.contains(11)
primes.contains(12)

// 4)
let marsenne = intersect(lhs: powersOf2Minus1, rhs: primes)

var result = [Int]()
var number = 0
while result.count < 5 {
    if marsenne.contains(number) {
        result.append(number)
    }
    number += 1
}
print(result)

//5)
// && is the intersect. short cutting is for the performance
// || is the union. short cutting is for the performance

// 6)
intersect(lhs: powersOf2Minus1, rhs: primes) // this first checks the power, then for prime
intersect(lhs: primes, rhs: powersOf2Minus1) // this first checks for prime, then the power

/*

 Exercise 6:

 It turns out that dictionaries [K: V] do not have map on K for all the same reasons Set does not. There is an alternative way to define dictionaries in terms of functions. Do that and define map and contramap on that new structure.

 Answer 6:

 */

struct Dict<Key, Value> {
    let contains: (Key) -> Value?
}

func contramap<Key, Value, A>(_ f: @escaping (A) -> Key) -> (Dict<Key, Value>) -> Dict<A, Value> {
    return { dict in
        Dict(contains: dict.contains <<< f)
    }
}

func map<Key, Value, A>(_ f: @escaping (Value) -> A) -> (Dict<Key, Value>) -> Dict<Key, A> {
    return { dict in
        Dict(contains: dict.contains >>> map(f))
    }
}

/*

 Exercise 7:

 Define CharacterSet as a type alias of PredicateSet, and construct some of the sets that are currently available in the API.

 Answer 7:

 */

typealias CharacterSet = PredicateSet<Character>

let decimalDigits = CharacterSet { ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains($0) }

decimalDigits.contains("a")
decimalDigits.contains("2")

/*

 Exercise 8:

 Let’s explore what happens when a type parameter appears multiple times in a function signature.
 1) Is A in positive or negative position in the function (B) -> (A, A)? Define either map or contramap on A.
 2) Is A in positive or negative position in (A, A) -> B? Define either map or contramap.
 3) Consider the type struct Endo<A> { let apply: (A) -> A }. This type is called Endo because functions whose input type is the same as the output type are called “endomorphisms”. Notice that A is in both positive and negative position. Does that mean that both map and contramap can be defined, or that neither can be defined?
 4) Turns out, Endo has a different structure on it known as an “invariant structure”, and it comes equipped with a different kind of function called imap. Can you figure out what it’s signature should be?

 Answer 8:

 */

// 1)
/*
(B) -> (A, A)
|_|    |____|
-1       +1
*/

func map<A, B, C>(
    _ f: @escaping ((A, A)) -> (C, C)
    ) -> (@escaping (B) -> (A, A)) -> ((B) -> (C, C)) {
    return { (baa: @escaping (B) -> (A, A)) in
        baa >>> f
    }
}

// 2)
/*
 (A, A) -> B
 |____|   |_|
   -1     +1
 */

func contramap<A, B, C>(
    _ f: @escaping ((C, C)) -> (A, A)
    ) -> (@escaping ((A, A)) -> B) -> (((C, C)) -> B) {
    return { (aab: @escaping ((A, A)) -> B) in
        f >>> aab
    }
}

// 3)

struct Endo<A> { let apply: (A) -> A }

// NEITHER

//func map<A, B>(_ f: @escaping (A) -> B) -> (Endo<A>) -> Endo<B> {
//    return { endoA in
//        // (A) -> A
//        //        A -> B
//        // (A)   ->    B
//        // But we need (B) -> B!
//        Endo(apply: endoA.apply >>> f)
//    }
//}

// 4)

func imap<A, B>(
    _ f: @escaping (B) -> A,
    _ g: @escaping (A) -> B
    ) -> (Endo<A>) -> Endo<B> {
    return { endo in Endo(apply: f >>> endo.apply >>> g) }
}

/*

 Exercise 9:

 Consider the type struct Equate<A> { let equals: (A, A) -> Bool }. This is just a struct wrapper around an equality check. You can think of it as a kind of “type erased” Equatable protocol. Write contramap for this type.

 Answer 9:

 */

struct Equate<A> { let equals: (A, A) -> Bool }

func contramap<A, B>(_ f: @escaping (B) -> A) -> (Equate<A>) -> Equate<B> {
    let f2: ((B, B)) -> (A, A) = { (f($0.0), f($0.1)) }
    return { equate -> Equate<B> in
        let result = f2 >>> equate.equals
        let betterResult: (B, B) -> Bool = { b1, b2 in
            return result((b1, b2))
        }
        return Equate<B>(equals: betterResult)
    }
}

/*

 Exercise 10:

 Consider the value intEquate = Equate<Int> { $0 == $1 }. Continuing the “type erased” analogy, this is like a “witness” to the Equatable conformance of Int. Show how to use contramap defined above to transform intEquate into something that defines equality of strings based on their character count.

 Answer 10:

 */

let intEquate = Equate<Int> { $0 == $1 }

let stringEquate = intEquate
    |> contramap { (b: String) -> Int in b.count }

stringEquate.equals("asd", "dsa")
stringEquate.equals("asd", "dsaa")

//: [Next](@next)
