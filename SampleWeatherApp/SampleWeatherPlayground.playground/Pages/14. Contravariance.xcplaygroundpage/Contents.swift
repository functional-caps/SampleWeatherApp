//: [Previous](@previous)

/*

 Exercise 1:

 Determine the sign of all the type parameters in the function (A) -> (B) -> C. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.

 Answer 1:

 */

/*

 Exercise 2:

 Determine the sign of all the type parameters in the following function:

 (A, B) -> (((C) -> (D) -> E) -> F) -> G

 Answer 2:

 */

/*

 Exercise 3:

 Recall that a setter is just a function ((A) -> B) -> (S) -> T. Determine the variance of each type parameter, and define a map and contramap for each one. Further, for each map and contramap write a description of what those operations mean intuitively in terms of setters.

 Answer 3:

 */

/*

 Exercise 4:

 Define union, intersect, and invert on PredicateSet.

 Answer 4:

 */

/*

 Exercise 5:

 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.
 Create a predicate set powersOf2: PredicateSet<Int> that determines if a value is a power of 2, i.e. 2^n for some n: Int.
 Use the above predicate set to derive a new one powersOf2Minus1: PredicateSet<Int> that tests if a number is of the form 2^n - 1 for n: Int.
 Find an algorithm online for testing if an integer is prime, and turn it into a predicate primes: PredicateSet<Int>.
 The intersection primes.intersect(powersOf2Minus1) consists of numbers known as Mersenne primes. Compute the first 10.
 Recall that && and || are short-circuiting in Swift. How does that translate to union and intersect?
 What is the difference between primes.intersect(powersOf2Minus1) and powersOf2Minus1.intersect(primes)? Which one represents a more performant predicate set?

 Answer 5:

 */

/*

 Exercise 6:

 It turns out that dictionaries [K: V] do not have map on K for all the same reasons Set does not. There is an alternative way to define dictionaries in terms of functions. Do that and define map and contramap on that new structure.

 Answer 6:

 */

/*

 Exercise 7:

 Define CharacterSet as a type alias of PredicateSet, and construct some of the sets that are currently available in the API.

 Answer 7:

 */

/*

 Exercise 8:

 Let’s explore what happens when a type parameter appears multiple times in a function signature.
 Is A in positive or negative position in the function (B) -> (A, A)? Define either map or contramap on A.
 Is A in positive or negative position in (A, A) -> B? Define either map or contramap.
 Consider the type struct Endo<A> { let apply: (A) -> A }. This type is called Endo because functions whose input type is the same as the output type are called “endomorphisms”. Notice that A is in both positive and negative position. Does that mean that both map and contramap can be defined, or that neither can be defined?
 Turns out, Endo has a different structure on it known as an “invariant structure”, and it comes equipped with a different kind of function called imap. Can you figure out what it’s signature should be?

 Answer 8:

 */

/*

 Exercise 9:

 Consider the type struct Equate<A> { let equals: (A, A) -> Bool }. This is just a struct wrapper around an equality check. You can think of it as a kind of “type erased” Equatable protocol. Write contramap for this type.

 Answer 9:

 */

/*

 Exercise 10:

 Consider the value intEquate = Equate<Int> { $0 == $1 }. Continuing the “type erased” analogy, this is like a “witness” to the Equatable conformance of Int. Show how to use contramap defined above to transform intEquate into something that defines equality of strings based on their character count.

 Answer 10:

 */

//: [Next](@next)
