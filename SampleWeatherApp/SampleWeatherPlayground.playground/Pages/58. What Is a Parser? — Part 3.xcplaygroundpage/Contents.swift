//: [Previous](@previous)

import Foundation

// 40.6782° N, 73.9442° W

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

struct Parser<A> {
    //    let run: (String) -> A?
    //    let run: (String) -> (match: A?, rest: String)
    let run: (inout Substring) -> A?
    func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

let int = Parser<Int> { str in
    let prefix = str.prefix(while: {
        $0.isNumber || $0 == "-"
    })
    guard let int = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return int
}

let double = Parser<Double> { str in
    let prefix = str.prefix(while: {
        $0.isNumber || "-+.eExXnNaA()iIfFtTyY".contains($0)
    })
    guard let double = Double(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return double
}

double.run("1.2")
double.run("-1.2")
double.run("-1.222e-12")
double.run("inf")

func literal(_ string: String) -> Parser<Void> {
    return Parser<Void> { str in
        guard str.hasPrefix(string) else { return nil }
        str.removeFirst(string.count)
        return ()
    }
}

literal("a").run("ab")
literal("a").run("ba")
literal("a").run("aaba")

func always<A>(_ a: A) -> Parser<A> {
    return Parser<A> { _ in a }
}

always("cat").run("dog")

func never<A>() -> Parser<A> {
    return Parser<A> { _ in nil }
}

extension Parser {
    static var never: Parser {
        return Parser { _ in nil }
    }
}

Parser<Int>.never.run("dog")

// 40.6782° N, 73.9442° W

let northSouth = Parser<Double> { str in
    guard
        let cardinal = str.first,
        cardinal == "N" || cardinal == "S"
    else { return nil }
    str.removeFirst(1)
    return cardinal == "N" ? 1 : -1
}

let eastWest = Parser<Double> { str in
    guard
        let cardinal = str.first,
        cardinal == "E" || cardinal == "W"
        else { return nil }
    str.removeFirst(1)
    return cardinal == "E" ? 1 : -1
}

func parseLatLong(_ str: String) -> Coordinate? {
    var str = str[...]
    guard
        let lat = double.run(&str),
        literal("° ").run(&str) != nil,
        let latSign = northSouth.run(&str),
        literal(", ").run(&str) != nil,
        let long = double.run(&str),
        literal("° ").run(&str) != nil,
        let longSign = eastWest.run(&str)
    else { return nil }
    return Coordinate(
        latitude: lat * latSign,
        longitude: long * longSign
    )
//    let parts = str.split(separator: " ")
//    guard parts.count == 4 else { return nil }
//    guard
//        let lat = Double(parts[0].dropLast()),
//        let long = Double(parts[2].dropLast())
//        else { return nil }
//    let latCard = parts[1].dropLast()
//    let longCard = parts[3]
//    guard latCard == "N" || latCard == "S" else { return nil }
//    guard longCard == "E" || longCard == "W" else { return nil }
//    let latSign = latCard == "N" ? 1.0 : -1.0
//    let longSign = longCard == "E" ? 1.0 : -1.0
//    return Coordinate(
//        latitude: lat * latSign,
//        longitude: long * longSign
//    )
}

print(parseLatLong("40.6782° N, 73.9442° W"))

/*
 
 Exercise 1.
 
 Right now all of our parsers (int, double, literal, etc.) are defined at the top-level of the file, hence they are defined in the module namespace. While that is completely fine to do in Swift, it can sometimes improve the ergonomics of using these values by storing them as static properties on the Parser type itself. We have done this a bunch in previous episodes, such as with our Gen type and Snapshotting type.
 
 Move all of the parsers we have defined so far to be static properties on the Parser type. You will want to suitably constrain the A generic in the extension in order to further restrict how these parsers are stored, i.e. you shouldn’t be allowed to access the integer parser via Parser<String>.int.
 
 */



/*

 Exercise 2.
 
 We have previously devoted an entire episode (here) to the concept of map, then 3 entire episodes (part 1, part 2, part 3) to zip, and then 5 (!) entire episodes (part 1, part 2, part 3, part 4, part 5) to flatMap. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.
 
 Define map, zip and flatMap on the Parser type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume any of the input string if the parser fails.
 
 */



/*

 Exercise 3.
 
 Create a parser end: Parser<Void> that simply succeeds if the input string is empty, and fails otherwise. This parser is useful to indicate that you do not intend to parse anymore.
 
 */



/*

 Exercise 4.
 
 Implement a function that takes a predicate (Character) -> Bool as an argument, and returns a parser Parser<Substring> that consumes from the front of the input string until the predicate is no longer satisfied. It would have the signature func pred: ((A) -> Bool) -> Parser<Substring>.
 
 */



/*

 Exercise 5.
 
 Implement a function that transforms any parser into one that does not consume its input at all. It would have the signature func nonConsuming: (Parser<A>) -> Parser<A>.
 
 */



/*

 Exercise 6.
 
 Implement a function that transforms a parser into one that runs the parser many times and accumulates the values into an array. It would have the signature func many: (Parser<A>) -> Parser<[A]>.
 
 */



/*

 Exercise 7.
 
 Implement a function that takes an array of parsers, and returns a new parser that takes the result of the first parser that succeeds. It would have the signature func choice: (Parser<A>...) -> Parser<A>.
 
 */



/*

 Exercise 8.
 
 Implement a function that takes two parsers, and returns a new parser that returns the result of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func either: (Parser<A>, Parser<B>) -> Parser<Either<A, B>> where Either is defined:
 
 enum Either<A, B> {
 case left(A)
 case right(B)
 }
 
 */



/*

 Exercise 9.
 
 Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the first and discards the second. It would have the signature func keep(_: Parser<A>, discard: Parser<B>) -> Parser<A>. Make sure to not consume any of the input string if either of the parsers fail.
 
 */



/*

 Exercise 10.
 
 Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the second and discards the first. It would have the signature func discard(_: Parser<A>, keep: Parser<B>) -> Parser<B>. Make sure to not consume any of the input string if either of the parsers fail.
 
 */



/*

 Exercise 11.
 
 Implement a function that takes two parsers and returns a new parser that returns of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func choose: (Parser<A>, Parser<A>) -> Parser<A>. Consume as little of the input string when implementing this function.
 
 */



/*

 Exercise 12.
 
 Generalize the previous exercise by implementing a function of the form func choose: ([Parser<A>]) -> Parser<A>.
 
 */



/*

 Exercise 13.
 
 Right now our parser can only fail in a single way, by returning nil. However, it can often be useful to have parsers that return a description of what went wrong when parsing.
 
 Generalize the Parser type so that instead of returning an A? value it returns a Result<A, String> value, which will allow parsers to describe their failures. Update all of our parsers and the ones in the above exercises to work with this new type.
 
 */



/*

 Exercise 14.
 
 Right now our parser only works on strings, but there are many other inputs we may want to parse. For example, if we are making a router we would want to parse URLRequest values.
 
 Generalize the Parser type so that it is generic not only over the type of value it produces, but also the type of values it parses. Update all of our parsers and the ones in the above exercises to work with this new type (you may need to constrain generics to work on specific types instead of all possible input types).
 
 */



//: [Next](@next)
