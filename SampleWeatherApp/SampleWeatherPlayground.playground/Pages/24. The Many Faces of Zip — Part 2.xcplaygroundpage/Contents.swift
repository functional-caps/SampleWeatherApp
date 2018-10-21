//: [Previous](@previous)

/*
 
 Exercise 1:
 
 Can you make the zip2 function on our F3 type thread safe?
 
 Answer 1:
 
 */

/*
 
 Exercise 2:
 
 Generalize the F3 type to a type that allows returning values other than Void: struct F4<A, R> { let run: (@escaping (A) -> R) -> R }. Define zip2 and zip2(with:) on the A type parameter.
 
 Answer 2:
 
 */

/*
 
 Exercise 3:
 
 Find a function in the Swift standard library that resembles the function above. How could you use zip2 on it?
 
 Answer 3:
 
 */

/*
 
 Exercise 4.1:
 
 This exercise explore what happens when you nest two types that each support a zip operation.
 
 Consider the type [A]? = Optional<Array<A>>. The outer layer Optional has zip2 defined, but also the inner layer Array has a zip2. Can we define a zip2 on [A]? that makes use of both of these zip structures? Write the signature of such a function and implement it.
 
 Answer 4.1:
 
 */

/*
 
 Exercise 4.2:
 
 Using the zip2 defined above write an example usage of it involving two [A]? values.
 
 Answer 4.2:
 
 */

/*
 
 Exercise 4.3:
 
 Consider the type [Validated<A, E>]. We again have have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both zip structures? Write the signature of such a function and implement it.
 
 Answer 4.3:
 
 */

/*
 
 Exercise 4.4:
 
 Using the zip2 defined above write an example usage of it involving two [Validated<A, E>] values.
 
 Answer 4.4:
 
 */

/*
 
 Exercise 4.5:
 
 Consider the type Func<R, A?>. Again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.5:
 
 */

/*
 
 Exercise 4.6:
 
 Consider the type Func<R, [A]>. Again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.6:
 
 */

/*
 
 Exercise 4.7:
 
 Finally, conisder the type F3<Validated<A, E>>. Yet again we have a nesting of types, each of which have their own zip2 operation. Can you define a zip2 on this type that makes use of both structures? Write the signature of such a function and implement it.
 
 Answer 4.7:
 
 */

/*
 
 Exercise 5:
 
 Do you see anything common in the implementation of all of the functions in the previous exercise? What this is showing is that nested zippable containers are also zippable containers because zip on the nesting can be defined in terms of zip on each of the containers.
 
 Answer 5:
 
 */

//: [Next](@next)
