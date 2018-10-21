//: [Previous](@previous)

/*
 
 Exercise 1.1:
 
 In this series of episodes on zip we have described zipping types as a kind of way to swap the order of nested containers when one of those containers is a tuple, e.g. we can transform a tuple of arrays to an array of tuples ([A], [B]) -> [(A, B)]. There’s a more general concept that aims to flip containers of any type. Implement the following to the best of your ability, and describe in words what they represent:
 
 sequence: ([A?]) -> [A]?
 
 Answer 1.1:
 
 */

/*
 
 Exercise 1.2:
 
 sequence: ([Result<A, E>]) -> Result<[A], E>
 
 Answer 1.2:
 
 */

/*
 
 Exercise 1.3:
 
 sequence: ([Validated<A, E>]) -> Validated<[A], E>
 
 Answer 1.3:
 
 */

/*
 
 Exercise 1.4:
 
 sequence: ([Parallel<A>]) -> Parallel<[A]>
 
 Answer 1.4:
 
 */

/*
 
 Exercise 1.5:
 
 sequence: (Result<A?, E>) -> Result<A, E>?
 
 Answer 1.5:
 
 */

/*
 
 Exercise 1.6:
 
 sequence: (Validated<A?, E>) -> Validated<A, E>?
 
 Answer 1.6:
 
 */

/*
 
 Exercise 1.7:
 
 sequence: ([[A]]) -> [[A]]
 
 Answer 1.7:
 
 */

/*
 
 Exercise 1.8:
 
 Note that you can still flip the order of these containers even though they are both the same container type. What does this represent? Evaluate the function on a few sample nested arrays.
 Note that all of these functions also represent the flipping of containers, e.g. an array of optionals transforms into an optional array, an array of results transforms into a result of an array, or a validated optional transforms into an optional validation, etc.
 
 Do the implementations of these functions have anything in common, or do they seem mostly distinct from each other?
 
 Answer 1.8:
 
 */

/*
 
 Exercise 2:
 

 There is a function closely related to zip called apply. It has the following shape: apply: (F<(A) -> B>, F<A>) -> F<B>. Define apply for Array, Optional, Result, Validated, Func and Parallel.
 
 Answer 2:
 
 */

/*
 
 Exercise 3:
 
 Another closely related function to zip is called alt, and it has the following shape: alt: (F<A>, F<A>) -> F<A>. Define alt for Array, Optional, Result, Validated and Parallel. Describe what this function semantically means for each of the types.
 
 Answer 3:
 
 */



//: [Next](@next)
