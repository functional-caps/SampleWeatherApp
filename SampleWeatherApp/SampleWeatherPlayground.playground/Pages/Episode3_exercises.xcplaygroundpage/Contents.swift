//: [Previous](@previous)

import Foundation

// ex 2

indirect enum List<A> {
    case empty
    case cons(A, List<A>)
}

List<Bool>.empty
List<Bool>.cons(false, .empty)
List<Bool>.cons(true, .empty)
List<Bool>.cons(false, .cons(false, .empty))
List<Bool>.cons(false, .cons(false, .cons(false, .empty)))
List<Bool>.cons(false, .cons(false, .cons(false, .cons(false, .empty))))

// 2 + infinite = infinite


// ex 3
// Is Optional<Either<A, B>> equivalent to Either<Optional<A>, Optional<B>>? If not, what additional values does one type have that the other doesn’t?

enum Either<A, B> {
    case left(A)
    case right(B)
}

Either<Bool, Bool>.left(false)
Either<Bool, Bool>.left(true)
Either<Bool, Bool>.left(false)
Either<Bool, Bool>.left(true) // 4 possible values

Optional<Either<Bool, Bool>>.none // 4 + 1

Either<Optional<Bool>, Optional<Bool>> // 3 + 3 = 6


// ex 4
// Is Either<Optional<A>, B> equivalent to Optional<Either<A, B>>?

// for Bool:
// 3 + 2  == 4 + 1


/* ex 5
 Swift allows you to pass types, like A.self, to functions that take arguments of A.Type. Overload the * and + infix operators with functions that take any type and build up an algebraic representation using Pair and Either. Explore how the precedence rules of both operators manifest themselves in the resulting types.
 */

