//: [Previous](@previous)

/*

 Exercise 1:

 What algebraic operation does the function type (A) -> B correspond to? Try explicitly enumerating all the values of some small cases like (Bool) -> Bool, (Unit) -> Bool, (Bool) -> Three and (Three) -> Bool to get some intuition.

 Answer 1:

 (Bool) -> Bool = 2 * 2 = 2
 true -> false
 true -> true
 false -> false
 false -> true

 (Unit) -> Bool = 1 * 2 = 2
 unit -> true
 unit -> false

 (Bool) -> Three = 2 * 3 = 6
 true -> one
 true -> two
 true -> three
 false -> one
 false -> two
 false -> three

 (Three) -> Bool => 3 * 2 = 6
 one -> true
 two -> true
 three -> true
 one -> false
 two -> false
 three -> false

 Function is a product type

 */

/*

 Exercise 2:

 Consider the following recursively defined data structure:

 indirect enum List<A> {
 case empty
 case cons(A, List<A>)
 }

 Translate this type into an algebraic equation relating List<A> to A.

 Answer 2:

 empty -> 1, count 0
 A, empty -> A, count 1
 A, A, empty -> A * A, count 2
 A, A, A, empty -> A * A * A, count 3

 So it's A^count

 */

/*

 Exercise 3:

 Is Optional<Either<A, B>> equivalent to Either<Optional<A>, Optional<B>>? If not, what additional values does one type have that the other doesn’t?

 Answer 3:

 Not equivalent, because Optional<Either<A, B>> has only one nil (3 possible values), and Either<Optional<A>, Optional<B>> has two nils, left(nil) and right(nil) (4 possible values)

 */

/*

 Exercise 4:

 Is Either<Optional<A>, B> equivalent to Optional<Either<A, B>>?

 Answer 4:

 Either<Optional<A>, B> is equivalent to Optional<Either<A, B>> in terms of number of possible values

 */

/*

 Exercise 5:

 Swift allows you to pass types, like A.self, to functions that take arguments of A.Type. Overload the * and + infix operators with functions that take any type and build up an algebraic representation using Pair and Either. Explore how the precedence rules of both operators manifest themselves in the resulting types.

 Answer 5:

 */

func +<A,B>(_ a: A.Type, _ b: B.Type) -> Either<A, B>.Type {
  return Either<A, B>.self
}

func *<A,B>(_ a: A.Type, _ b: B.Type) -> Pair<A, B>.Type {
  return Pair<A, B>.self
}

print((Int.self + Float.self) * String.self + Double.self)

//: [Next](@next)
