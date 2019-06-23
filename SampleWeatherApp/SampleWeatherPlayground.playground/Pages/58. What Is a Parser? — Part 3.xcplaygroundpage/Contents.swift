//: [Previous](@previous)

import Foundation

// 40.6782° N, 73.9442° W

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

struct Parser<I, A> {
    //    let run: (String) -> A?
    //    let run: (String) -> (match: A?, rest: String)
    let run: (inout I) -> Result<A, String>
}

extension Parser where I == Substring {
    func run(_ str: String) -> (match: Result<A, String>, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

let int = Parser<Substring, Int> { str in
    let prefix = str.prefix(while: {
        $0.isNumber || $0 == "-"
    })
    guard let int = Int(prefix) else { return .failure("Int.init niled") }
    str.removeFirst(prefix.count)
    return .success(int)
}

let double = Parser<Substring, Double> { str in
    let prefix = str.prefix(while: {
        $0.isNumber || "-+.eExXnNaA()iIfFtTyY".contains($0)
    })
    guard let double = Double(prefix) else { return .failure("Double.init niled") }
    str.removeFirst(prefix.count)
    return .success(double)
}

double.run("1.2")
double.run("-1.2")
double.run("-1.222e-12")
double.run("inf")

func literal(_ string: String) -> Parser<Substring, Void> {
    return Parser<Substring, Void> { str in
        guard str.hasPrefix(string) else { return .failure("No prefix found") }
        str.removeFirst(string.count)
        return .success(())
    }
}

literal("a").run("ab")
literal("a").run("ba")
literal("a").run("aaba")

func always<I, A>(_ a: A) -> Parser<I, A> {
    return Parser<I, A> { _ in .success(a) }
}

always("cat").run("dog")

func never<I, A>() -> Parser<I, A> {
    return Parser<I, A> { _ in .failure("never") }
}

extension Parser {
    static var never: Parser {
        return Parser { _ in .failure("never") }
    }
}

Parser<Substring, Int>.never.run("dog")

// 40.6782° N, 73.9442° W

let northSouth = Parser<Substring, Double> { str in
    guard
        let cardinal = str.first,
        cardinal == "N" || cardinal == "S"
    else { return .failure("No N or S as first character") }
    str.removeFirst(1)
    return .success(cardinal == "N" ? 1 : -1)
}

let eastWest = Parser<Substring, Double> { str in
    guard
        let cardinal = str.first,
        cardinal == "E" || cardinal == "W"
    else { return .failure("No E or W as first character") }
    str.removeFirst(1)
    return .success(cardinal == "E" ? 1 : -1)
}

func parseLatLong(_ str: String) -> Coordinate? {
    var str = str[...]
    guard
        case let .success(lat) = double.run(&str),
        case .success = literal("° ").run(&str),
        case let .success(latSign) = northSouth.run(&str),
        case .success = literal(", ").run(&str),
        case let .success(long) = double.run(&str),
        case .success = literal("° ").run(&str),
        case let .success(longSign) = eastWest.run(&str)
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

print(parseLatLong("40.6782° N, 73.9442° W")!)

/*
 
 Exercise 1.
 
 Right now all of our parsers (int, double, literal, etc.) are defined at the top-level of the file, hence they are defined in the module namespace. While that is completely fine to do in Swift, it can sometimes improve the ergonomics of using these values by storing them as static properties on the Parser type itself. We have done this a bunch in previous episodes, such as with our Gen type and Snapshotting type.
 
 Move all of the parsers we have defined so far to be static properties on the Parser type. You will want to suitably constrain the A generic in the extension in order to further restrict how these parsers are stored, i.e. you shouldn’t be allowed to access the integer parser via Parser<String>.int.
 
 */

extension Parser where I == Substring, A == Int {

    static var int: Parser = Parser { str in
        let prefix = str.prefix(while: {
            $0.isNumber || $0 == "-"
        })
        guard let int = Int(prefix) else { return .failure("Int.init niled") }
        str.removeFirst(prefix.count)
        return .success(int)
    }
}

extension Parser where I == Substring, A == Double {
    
    static var double: Parser = Parser { str in
        let prefix = str.prefix(while: {
            $0.isNumber || "-+.eExXnNaA()iIfFtTyY".contains($0)
        })
        guard let double = Double(prefix) else { return .failure("Double.init niled") }
        str.removeFirst(prefix.count)
        return .success(double)
    }
}

extension Parser where I == Substring, A == Void {

    static func literal(_ string: String) -> Parser<Substring, Void> {
        return Parser<Substring, Void> { str in
            guard str.hasPrefix(string) else { return .failure("No prefix found") }
            str.removeFirst(string.count)
            return .success(())
        }
    }
}

extension Parser {

    static func always(_ a: A) -> Parser {
        return Parser { _ in .success(a) }
    }
}

extension Parser where I == Substring, A == Double {
    
    static var northSouth: Parser = Parser { str in
        guard
            let cardinal = str.first,
            cardinal == "N" || cardinal == "S"
            else { return .failure("No N or S as first character") }
        str.removeFirst(1)
        return .success(cardinal == "N" ? 1 : -1)
    }
}

extension Parser where I == Substring, A == Double {
    
    static var eastWest: Parser = Parser { str in
        guard
            let cardinal = str.first,
            cardinal == "E" || cardinal == "W"
        else { return .failure("No E or W as first character") }
        str.removeFirst(1)
        return .success(cardinal == "E" ? 1 : -1)
    }
}

/*

 Exercise 2.
 
 We have previously devoted an entire episode (here) to the concept of map, then 3 entire episodes (part 1, part 2, part 3) to zip, and then 5 (!) entire episodes (part 1, part 2, part 3, part 4, part 5) to flatMap. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.
 
 Define map, zip and flatMap on the Parser type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume any of the input string if the parser fails.
 
 */

extension Parser {
    func map<B>(_ f: @escaping (A) -> B) -> Parser<I, B> {
        return Parser<I, B> { str in
            return self.run(&str).map(f)
        }
    }
}

print(
    Parser<Substring, Int>.int.map { "found: \($0)" }.run("a 42 asd")
)

// I have two ideas for zip. The one that applies parsing "serially" and the one that applies it "concurently"

// First, serial one

func zip<I, A, B, C>(
    with f: @escaping (A, B) -> C
) -> (Parser<I, A>, Parser<I, B>) -> Parser<I, C> {
    return { parserA, parserB in
        return Parser<I, C> { str in
            var copyStr = str
            let result = zip(with: f)(
                parserA.run(&copyStr),
                parserB.run(&copyStr)
            )
            switch result {
            case .success: str = copyStr
            default: break
            }
            return result
        }
    }
}

let zippedParser = zip(with: { (int: Int, double: Double) -> String in
    "int: \(int), double: \(double)"
})(Parser<Substring, Int>.int, Parser<Substring, Double>.double)

zippedParser.run("4242.01 asd")

// Second, concurrent one

func zipC<A, B, C>(
    with f: @escaping (A, B) -> C
    ) -> (Parser<Substring, A>, Parser<Substring, B>) -> Parser<Substring, C> {
    return { parserA, parserB in
        return Parser<Substring, C> { str in
            var copyStrA = str
            var copyStrB = str
            let result = zip(with: f)(
                parserA.run(&copyStrA),
                parserB.run(&copyStrB)
            )
            switch result {
            case .success: str = copyStrA.count <= copyStrB.count ? copyStrA : copyStrB
            default: break
            }
            return result
        }
    }
}

let zippedCParser = zipC(with: { (int: Int, double: Double) -> String in
    "int: \(int), double: \(double)"
})(Parser<Substring, Int>.int, Parser<Substring, Double>.double)

zippedCParser.run("4242.01 asd")

// which one is the one?

extension Parser {
    
    func flatMap<B>(_ f: @escaping (A) -> Parser<I, B>) -> Parser<I, B> {
        return Parser<I, B> { str in
            switch self.run(&str) {
            case .success(let match): return f(match).run(&str)
            case .failure(let error): return .failure(error)
            }
        }
    }
}

Parser.literal("asd")
    .flatMap { Parser.literal("asd") }
    .run("asdasdasd")

/*

 Exercise 3.
 
 Create a parser end: Parser<Void> that simply succeeds if the input string is empty, and fails otherwise. This parser is useful to indicate that you do not intend to parse anymore.
 
 */

extension Parser where I == Substring, A == Void {
    
    static var end: Parser = Parser { str in
        guard str.isEmpty else { return .failure("Not empty") }
        return .success(())
    }
}

Parser.end.run("ads")
Parser.end.run("")

/*

 Exercise 4.
 
 Implement a function that takes a predicate (Character) -> Bool as an argument, and returns a parser Parser<Substring> that consumes from the front of the input string until the predicate is no longer satisfied. It would have the signature func pred: ((A) -> Bool) -> Parser<Substring>.
 
 */

extension Parser where I == Substring, A == Substring {
    static func pred(_ f: @escaping (Character) -> Bool) -> Parser<Substring, Substring> {
        return Parser<Substring, Substring> { str in
            let satisfying = str.prefix(while: f)
            guard !satisfying.isEmpty else { return .failure("No prefix") }
            str.removeFirst(satisfying.count)
            return .success(satisfying)
        }
    }
}

print(
    Parser<Substring, Substring>.pred({ $0.isNumber })
        .run("123asd12")
)

/*

 Exercise 5.
 
 Implement a function that transforms any parser into one that does not consume its input at all. It would have the signature func nonConsuming: (Parser<A>) -> Parser<A>.
 
 */

func nonConsuming<I, A>(from: Parser<I, A>) -> Parser<I, A> {
    return Parser<I, A> { str in
        var copyStr = str
        return from.run(&copyStr)
    }
}

nonConsuming(from: Parser<Substring, Int>.int)
    .run("123")

/*

 Exercise 6.
 
 Implement a function that transforms a parser into one that runs the parser many times and accumulates the values into an array. It would have the signature func many: (Parser<A>) -> Parser<[A]>.
 
 */

func many<I, A>(from: Parser<I, A>) -> Parser<I, [A]> {
    return Parser<I, [A]> { str in
        var results = [A]()
        var result = from.run(&str)
        while case .success(let match) = result {
            results.append(match)
            result = from.run(&str)
        }
        guard !results.isEmpty else {
            if case .failure(let error) = result {
                return .failure(error)
            } else {
                return .failure("Many did not do anything")
            }
        }
        return .success(results)
    }
}

many(from: Parser.literal("asd"))
    .run("asdasdasdasd")
    .match
    .map { $0.count }


/*

 Exercise 7.
 
 Implement a function that takes an array of parsers, and returns a new parser that takes the result of the first parser that succeeds. It would have the signature func choice: (Parser<A>...) -> Parser<A>.
 
 */

func choice<I, A>(_ parsers: Parser<I, A>...) -> Parser<I, A> {
    return Parser<I, A> { str in
        var result: A? = nil
        _ = parsers.first { parser -> Bool in
            guard case .success(let value) = parser.run(&str) else {
                return false
            }
            result = value
            return true
        }
        return result.map { .success($0) } ?? .failure("No parser passed choice")
    }
}

choice(Parser.literal("asd"), Parser.literal("dsa"), Parser.literal("dsad"))
    .run("dsada")

/*

 Exercise 8.
 
 Implement a function that takes two parsers, and returns a new parser that returns the result of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func either: (Parser<A>, Parser<B>) -> Parser<Either<A, B>> where Either is defined:
 
 enum Either<A, B> {
 case left(A)
 case right(B)
 }
 
 */

func either<I, A, B>(
    _ lhs: Parser<I, A>, _ rhs: Parser<I, B>
) -> Parser<I, Either<A, B>> {
    return Parser<I, Either<A, B>> { str in
        switch lhs.run(&str) {
        case .success(let value): return .success(.left(value))
        case .failure: return rhs.run(&str).map(Either.right)
        }
    }
}

either(Parser.literal("asd"), Parser<Substring, Int>.int)
    .run("123")

/*

 Exercise 9.
 
 Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the first and discards the second. It would have the signature func keep(_: Parser<A>, discard: Parser<B>) -> Parser<A>. Make sure to not consume any of the input string if either of the parsers fail.
 
 */

func keep<I, A, B>(_ parserA: Parser<I, A>, discard parserB: Parser<I, B>) -> Parser<I, A> {
    return Parser<I, A> { str in
        var copyStr = str
        switch parserA.run(&copyStr) {
        case .failure(let error): return .failure(error)
        case .success(let value):
            switch parserB.run(&copyStr) {
            case .failure(let error): return .failure(error)
            case .success:
                str = copyStr
                return .success(value)
            }
        }
    }
}

keep(Parser.literal("asd"), discard: Parser.literal("dsa"))
    .run("asddsaasd")

/*

 Exercise 10.
 
 Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the second and discards the first. It would have the signature func discard(_: Parser<A>, keep: Parser<B>) -> Parser<B>. Make sure to not consume any of the input string if either of the parsers fail.
 
 */

func discard<I, A, B>(_ parserA: Parser<I, A>, keep parserB: Parser<I, B>) -> Parser<I, B> {
    return Parser<I, B> { str in
        var copyStr = str
        switch parserA.run(&copyStr) {
        case .failure(let error): return .failure(error)
        case .success:
            switch parserB.run(&copyStr) {
            case .failure(let error): return .failure(error)
            case .success(let value):
                str = copyStr
                return .success(value)
            }
        }
    }
}

keep(Parser.literal("asd"), discard: Parser.literal("dsa"))
    .run("asddsaasd")
/*

 Exercise 11.
 
 Implement a function that takes two parsers and returns a new parser that returns of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func choose: (Parser<A>, Parser<A>) -> Parser<A>. Consume as little of the input string when implementing this function.
 
 */

func choose<I, A>(_ parserA: Parser<I, A>, _ parserB: Parser<I, A>) -> Parser<I, A> {
    return Parser<I, A> { str in
        switch parserA.run(&str) {
        case .success(let value): return .success(value)
        case .failure: return parserB.run(&str)
        }
    }
}

choose(Parser.literal("aasd"), Parser.literal("asdasd"))
    .run("asdasdasd")

/*

 Exercise 12.
 
 Generalize the previous exercise by implementing a function of the form func choose: ([Parser<A>]) -> Parser<A>.
 
 */

// it's the same as choice defined above

func choose<I, A>(_ parsers: [Parser<I, A>]) -> Parser<I, A> {
    return Parser<I, A> { str in
        var result: A? = nil
        _ = parsers.first { parser -> Bool in
            guard case .success(let value) = parser.run(&str) else {
                return false
            }
            result = value
            return true
        }
        return result.map { .success($0) } ?? .failure("No parser passed choice")
    }
}

choose([
    Parser.literal("asd"), Parser.literal("qwe"), Parser.literal("zxc")
]).run("zxczxc")

/*

 Exercise 13.
 
 Right now our parser can only fail in a single way, by returning nil. However, it can often be useful to have parsers that return a description of what went wrong when parsing.
 
 Generalize the Parser type so that instead of returning an A? value it returns a Result<A, String> value, which will allow parsers to describe their failures. Update all of our parsers and the ones in the above exercises to work with this new type.
 
 */

// DONE

/*

 Exercise 14.
 
 Right now our parser only works on strings, but there are many other inputs we may want to parse. For example, if we are making a router we would want to parse URLRequest values.
 
 Generalize the Parser type so that it is generic not only over the type of value it produces, but also the type of values it parses. Update all of our parsers and the ones in the above exercises to work with this new type (you may need to constrain generics to work on specific types instead of all possible input types).
 
 */

// DONE

//: [Next](@next)
