//: [Previous](@previous)

// Either<A, B> = A + B
// Pair<A, B>   = A * B
// Func<A, B>   = B ^ A

// Algebra      | Swift Type System
// --------------------------------
// Sums         | Enums
// Products     | Structs
// Exponentials | Functions
// Functions    | Generics

enum NaturalNumber {
    case zero
    indirect case successor(NaturalNumber)
}

func predecessor(_ nat: NaturalNumber) -> NaturalNumber? {
    switch nat {
    case .zero: return nil
    case .successor(let predecessor): return predecessor
    }
}

extension NaturalNumber: Equatable {
    static func == (lhs: NaturalNumber, rhs: NaturalNumber) -> Bool {
        switch (lhs, rhs) {
        case (.zero, .zero): return true
        case (.successor(let lpr), .successor(let rpr)): return lpr == rpr
        default: return false
        }
    }
}

let zero = NaturalNumber.zero
let one = NaturalNumber.successor(zero)
let two = NaturalNumber.successor(one)
let three = NaturalNumber.successor(two)
let four = NaturalNumber.successor(three)
let five = NaturalNumber.successor(four)
let six = NaturalNumber.successor(five)
let seven = NaturalNumber.successor(six)

enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

func sum(_ xs: List<Int>) -> Int {
    switch xs {
    case .empty: return 0
    case let .cons(head, tail):
        return head + sum(tail)
    }
}

struct NonEmptyList_Old<A> {
    let head: A
    let tail: List<A>
}

enum NonEmptyList<A> {
    case singleton(A)
    indirect case cons(A, NonEmptyList<A>)
}

extension NonEmptyList {
    var first: A {
        switch self {
        case .singleton(let first): return first
        case .cons(let head, _): return head
        }
    }
}

/*

 Exercise 1:

 Define addition and multiplication on NaturalNumber:
 func +(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber
 func *(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber

 Answer 1:

 */

func + (lhs: NaturalNumber, rhs: NaturalNumber) -> NaturalNumber {
    switch (lhs, rhs) {
    case (.zero, let result), (let result, .zero): return result
    case (.successor(let lpr), .successor(let rpr)):
        // a, b
        // a = x + 1, b = y + 1
        // a + b = (x + y) + 2
        // a + b = (x + 2) + y
        return .successor(.successor(lpr + rpr))
    }
}

one + four == five

func * (lhs: NaturalNumber, rhs: NaturalNumber) -> NaturalNumber {
    switch (lhs, rhs) {
    case (.zero, _), (_, .zero): return .zero
    case (.successor(let lpr), .successor(let rpr)):
        // a, b
        // a = x + 1, b = y + 1
        // a * b == (x + 1) * (y + 1)
        // a * b == x*y + x + y + 1
        return lpr * rpr + lpr + rpr + one
    }
}

two * two == four
two * two == five
two * three == five
two * three == six

/*

 Exercise 2:

 Implement the exp function on NaturalNumber that takes a number to a power:

 exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber

 Answer 2:

 */

func exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber {
    switch (base, power) {
    case (_, .zero): return one
    case (_, .successor(let ppr)): return base * exp(base, ppr)
    }
}

exp(zero, zero) == one
exp(zero, one) == zero
exp(zero, two) == zero

exp(one, zero) == one
exp(one, one) == one
exp(one, two) == one

exp(two, zero) == one
exp(two, one) == two
exp(two, two) == four

/*

 Exercise 3:

 Conform NaturalNumber to the Comparable protocol.

 Answer 3:

 */

extension NaturalNumber: Comparable {
    static func < (lhs: NaturalNumber, rhs: NaturalNumber) -> Bool {
        if lhs == rhs { return false } // Irreflexivity
        switch (lhs, rhs) {
        case (.zero, _): return true
        case (_, .zero): return false
        case (.successor(let lpr), .successor(let rpr)):
            return lpr < rpr
        }
    }
}

zero < two
one < two
five < four
five < five
five < six

/*

 Exercise 4:

 Implement min and max functions for NaturalNumber.

 Answer 4:

 */

func min(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
    if lhs < rhs { return lhs } else { return rhs }
}

func max(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
    if lhs < rhs { return rhs } else { return lhs }
}

min(three, four) == four

min(three, four) == three
max(three, four) == four

min(five, four) == four
max(five, four) == five

min(four, four) == four
max(four, four) == four

/*

 Exercise 5:

 How could you implement all integers (both positive and negative) as an algebraic data type? Define all of the above functions and conformances on that type.

 Answer 5:

 */

enum AlgebraicInteger {
    enum Sign { case plus, minus }
    case number(NaturalNumber, Sign)

    static let zero: AlgebraicInteger = .number(.zero, .plus)
}

let izero = AlgebraicInteger.zero
let pone = AlgebraicInteger.number(one, .plus)
let ptwo = AlgebraicInteger.number(two, .plus)
let pthree = AlgebraicInteger.number(three, .plus)
let pfour = AlgebraicInteger.number(four, .plus)
let pfive = AlgebraicInteger.number(five, .plus)
let psix = AlgebraicInteger.number(six, .plus)
let pseven = AlgebraicInteger.number(seven, .plus)
let none = AlgebraicInteger.number(one, .minus)
let ntwo = AlgebraicInteger.number(two, .minus)
let nthree = AlgebraicInteger.number(three, .minus)
let nfour = AlgebraicInteger.number(four, .minus)
let nfive = AlgebraicInteger.number(five, .minus)
let nsix = AlgebraicInteger.number(six, .minus)
let nseven = AlgebraicInteger.number(seven, .minus)

extension AlgebraicInteger: Equatable {
    static func == (lhs: AlgebraicInteger, rhs: AlgebraicInteger) -> Bool {
        switch (lhs, rhs) {
        case (.number(.zero, _), .number(.zero, _)): return true
        case (_, .number(.zero, _)), (.number(.zero, _), _): return false
        case (.number(_, .plus), .number(_, .minus)),
             (.number(_, .minus), .number(_, .plus)): return false
        case let (.number(ln, .plus), .number(pn, .plus)),
             let (.number(ln, .minus), .number(pn, .minus)): return ln == pn
        }
    }
}

extension AlgebraicInteger: Comparable {
    static func < (lhs: AlgebraicInteger, rhs: AlgebraicInteger) -> Bool {
        if lhs == rhs { return false } // Irreflexivity
        switch (lhs, rhs) {
        case (.number(.zero, _), _), (.number(_, .minus), .number(_, .plus)): return true
        case (_, .number(.zero, _)), (.number(_, .plus), .number(_, .minus)): return false
        case let (.number(ln, .plus), .number(pn, .plus)): return ln < pn
        case let (.number(ln, .minus), .number(pn, .minus)): return ln > pn
        }
    }
}

func difference(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
    switch (lhs, rhs) {
    case (let result, .zero), (.zero, let result): return result
    case (.successor(let lpr), .successor(let rpr)):
        return difference(lpr, rpr)
    }
}

func + (lhs: AlgebraicInteger, rhs: AlgebraicInteger) -> AlgebraicInteger {
    switch (lhs, rhs) {
    case let (.number(.zero, _), other), let (other, .number(.zero, _)): return other
    case let (.number(ln, .plus), .number(pn, .plus)): return .number(ln + pn, .plus)
    case let (.number(ln, .minus), .number(pn, .minus)): return .number(ln + pn, .minus)
    case let (.number(ln, .plus), .number(pn, .minus)):
        if ln > pn { return .number(difference(ln, pn), .plus) }
        else if pn > ln { return .number(difference(ln, pn), .minus) }
        else { return .zero }
    case let (.number(ln, .minus), .number(pn, .plus)):
        if ln > pn { return .number(difference(ln, pn), .minus) }
        else if pn > ln { return .number(difference(ln, pn), .plus) }
        else { return .zero }
    }
}

func * (lhs: AlgebraicInteger, rhs: AlgebraicInteger) -> AlgebraicInteger {
    switch (lhs, rhs) {
    case (.number(.zero, _), _), (_, .number(.zero, _)): return .zero
    case let (.number(ln, .plus), .number(pn, .plus)),
         let (.number(ln, .minus), .number(pn, .minus)): return .number(ln * pn, .plus)
    case let (.number(ln, .plus), .number(pn, .minus)),
         let (.number(ln, .minus), .number(pn, .plus)): return .number(ln * pn, .minus)
    }
}

func exp(_ base: AlgebraicInteger, _ power: AlgebraicInteger) -> AlgebraicInteger? {
    switch (base, power) {
    case (_, .number(.zero, _)): return .zero
    case (_, .number(_, .minus)): return nil
    case (_, .number(.successor(let ppr), .plus)):
        guard let rest = exp(base, .number(ppr, .plus)) else { return nil }
        return base * rest
    }
}

func min(_ lhs: AlgebraicInteger, _ rhs: AlgebraicInteger) -> AlgebraicInteger {
    if lhs < rhs { return lhs } else { return rhs }
}

func max(_ lhs: AlgebraicInteger, _ rhs: AlgebraicInteger) -> AlgebraicInteger {
    if lhs < rhs { return rhs } else { return lhs }
}

ptwo + pthree == pfive
ptwo * pthree == psix

/*

 Exercise 6:

 What familiar type is List<Void> equivalent to? Write to and from functions between those types showing how to travel back-and-forth between them.

 Answer 6:

 */

// List<A> = 1 + A + A*A + A*A*A + ...
// List<Void> = 1 + Void + Void*Void + Void*Void*Void + ...
//            = 1 + 1 + 1 + 1 + ...

func from(_ natural: NaturalNumber) -> List<Void> {
    switch natural {
    case .zero: return .empty
    case .successor(let nn): return .cons((), from(nn))
    }
}

func to(_ list: List<Void>) -> NaturalNumber {
    switch list {
    case .empty: return .zero
    case .cons(_, let tail): return .successor(to(tail))
    }
}

to(from(five)) == five
to(from(five)) == four

/*

 Exercise 7:

 Conform List and NonEmptyList to the ExpressibleByArrayLiteral protocol.

 Answer 7:

 */

extension List: ExpressibleByArrayLiteral {

    typealias ArrayLiteralElement = A

    init(arrayLiteral elements: A...) {
        self = List.init(elements: elements)
    }

    init(elements: [A]) {
        guard let first = elements.first else {
            self = .empty
            return
        }
        self = .cons(first, List.init(elements: Array(elements.dropFirst())))
    }
}

dump(List<Int>())
dump(List(arrayLiteral: 5))
dump(List(arrayLiteral: 1,2,3,4,5))

extension NonEmptyList_Old: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = A

    init(arrayLiteral elements: A...) {
        self.init(elements: elements)
    }

    private init(elements: [A]) {
        guard let first = elements.first else {
            fatalError("Cannot make empty nonempty")
        }
        let tail = Array(elements.dropFirst())
        self.head = first
        self.tail = List(elements: tail)
    }
}

//dump(NonEmptyList_Old<Int>())
dump(NonEmptyList_Old(arrayLiteral: 5))
dump(NonEmptyList_Old(arrayLiteral: 1, 2, 3, 4, 5))

extension NonEmptyList: ExpressibleByArrayLiteral {

    typealias ArrayLiteralElement = A

    init(arrayLiteral elements: A...) {
        self = NonEmptyList.init(elements: elements)
    }

    private init(elements: [A]) {
        guard let first = elements.first else {
            fatalError("Cannot make empty nonempty")
        }
        let tail = Array(elements.dropFirst())
        self = tail.count == 0 ? .singleton(first)
                               : .cons(first, NonEmptyList(elements: tail))
    }
}

//dump(NonEmptyList<Int>())
dump(NonEmptyList(arrayLiteral: 5))
dump(NonEmptyList(arrayLiteral: 1, 2, 3, 4, 5))

/*

 Exercise 8:

 Conform List to the Collection protocol.

 Answer 8:

 */

//The startIndex and endIndex properties
//A subscript that provides at least read-only access to your type’s elements
//The index(after:) method for advancing an index into your collection

extension List: Collection {

    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        switch self {
        case .empty: return 0
        case .cons(_, let tail): return 1 + tail.endIndex
        }
    }

    subscript(position: Int) -> A {
        guard position < endIndex,
            case let .cons(head, tail) = self
        else { fatalError("") }
        if position == startIndex { return head }
        else { return tail[position - 1] }
    }

    func index(after i: Int) -> Int {
        return i + 1
    }
}

List(arrayLiteral: 1,2,3,4,5,6,7)[6]

/*

 Exercise 9:

 Conform each implementation of NonEmptyList to the Collection protocol.

 Answer 9:

 */

extension NonEmptyList_Old: Collection {

    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return 1 + tail.endIndex
    }

    subscript(position: Int) -> A {
        guard position < endIndex else { fatalError("") }
        if position == startIndex {
            return head
        } else {
            return tail[position - 1]
        }
    }

    func index(after i: Int) -> Int {
        return i + 1
    }
}

NonEmptyList_Old(arrayLiteral: 1,2,3,4,5,6,7)[0]

extension NonEmptyList: Collection {

    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        switch self {
        case .singleton: return 1
        case .cons(_, let tail): return 1 + tail.endIndex
        }
    }

    subscript(position: Int) -> A {
        guard position < endIndex else { fatalError("") }
        switch self {
        case .singleton(let elem): return elem
        case let .cons(head, tail):
            if position == startIndex { return head }
            else { return tail[position - 1] }
        }
    }

    func index(after i: Int) -> Int {
        return i + 1
    }
}

NonEmptyList(arrayLiteral: 1,2,3,4,5,6,7)[6]

/*

 Exercise 10:

 Consider the type enum List<A, B> { cae empty; case cons(A, B) }. It’s kinda like list without recursion, where the recursive part has just been replaced with another generic. Now consider the strange type:

 enum Fix<A> {
 case fix(ListF<A, Fix<A>>)
 }

 Construct a few values of this type. What other type does Fix seem to resemble?

 Answer 10:

 */

enum ListF<A, B> {
    case empty
    case cons(A, B)
}

indirect enum Fix<A> {
    case fix(ListF<A, Fix<A>>)
}

Fix<Int>.fix(.empty)
Fix<Int>.fix(.cons(1, .fix(.empty)))
Fix<Int>.fix(.cons(1, .fix(.cons(2, .fix(.empty)))))

// it's like a list

/*

 Exercise 11:

 Construct an explicit mapping between the List<A> and Fix<A> types by implementing:
 func to<A>(_ list: List<A>) -> Fix<A>
 func from<A>(_ fix: Fix<A>) -> List<A>

 The type Fix is known as the “fixed-point” of List. It is more generic than just dealing with lists, but unfortunately Swift does not have the type feature (higher-kinded types) to allow us to express this.

 Answer 11:

 */

func to<A>(_ list: List<A>) -> Fix<A> {
    switch list {
    case .empty: return .fix(.empty)
    case let .cons(head, tail): return .fix(.cons(head, to(tail)))
    }
}

dump(to(List(arrayLiteral: 1, 2, 3)))

func from<A>(_ fix: Fix<A>) -> List<A> {
    switch fix {
    case .fix(.empty): return .empty
    case let .fix(.cons(head, tailFix)):
        return .cons(head, from(tailFix))
    }
}

dump(from(to(List(arrayLiteral: 1, 2, 3))))

//: [Next](@next)
