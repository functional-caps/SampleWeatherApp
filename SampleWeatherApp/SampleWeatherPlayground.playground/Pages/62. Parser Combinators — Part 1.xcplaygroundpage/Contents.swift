//: [Previous](@previous)

import Foundation

struct Parser<A> {
    let run: (inout Substring) -> A?
}

let int = Parser<Int> { str in
    let prefix = str.prefix(while: { $0.isNumber })
    let match = Int(prefix)
    str.removeFirst(prefix.count)
    return match
}

let double = Parser<Double> { str in
    let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
    let match = Double(prefix)
    str.removeFirst(prefix.count)
    return match
}

let char = Parser<Character> { str in
    guard !str.isEmpty else { return nil }
    return str.removeFirst()
}

func literal(_ p: String) -> Parser<Void> {
    return Parser<Void> { str in
        guard str.hasPrefix(p) else { return nil }
        str.removeFirst(p.count)
        return ()
    }
}

func always<A>(_ a: A) -> Parser<A> {
    return Parser<A> { _ in a }
}

extension Parser {
    static var never: Parser {
        return Parser { _ in nil }
    }
}

extension Parser {
    func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
        return Parser<B> { str -> B? in
            self.run(&str).map(f)
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
        return Parser<B> { str -> B? in
            let original = str
            let matchA = self.run(&str)
            let parserB = matchA.map(f)
            guard let matchB = parserB?.run(&str) else {
                str = original
                return nil
            }
            return matchB
        }
    }
}

func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
    return Parser<(A, B)> { str -> (A, B)? in
        let original = str
        guard let matchA = a.run(&str) else { return nil }
        guard let matchB = b.run(&str) else {
            str = original
            return nil
        }
        return (matchA, matchB)
    }
}

func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
    ) -> Parser<(A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}
func zip<A, B, C, D>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>
    ) -> Parser<(A, B, C, D)> {
    return zip(a, zip(b, c, d))
        .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}
func zip<A, B, C, D, E>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>
    ) -> Parser<(A, B, C, D, E)> {
    
    return zip(a, zip(b, c, d, e))
        .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}
func zip<A, B, C, D, E, F>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>
    ) -> Parser<(A, B, C, D, E, F)> {
    return zip(a, zip(b, c, d, e, f))
        .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}
func zip<A, B, C, D, E, F, G>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>,
    _ g: Parser<G>
    ) -> Parser<(A, B, C, D, E, F, G)> {
    return zip(a, zip(b, c, d, e, f, g))
        .map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
}

extension Parser {
    func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
    return Parser<Substring> { str in
        let prefix = str.prefix(while: p)
        str.removeFirst(prefix.count)
        return prefix
    }
}

let zeroOrMoreSpaces = prefix(while: { $0 == " " })
    .map { _ in }

//    Parser<Void> { str -> Void? in
//    let prefix = str.prefix(while: { $0 == " " })
//    str.removeFirst(prefix.count)
//    return ()
//}

let oneOrMoreSpaces = prefix(while: { $0 == " " })
    .flatMap { $0.isEmpty ? .never : always(()) }

//Parser<Void> { str -> Void? in
//    let prefix = str.prefix(while: { $0 == " " })
//    guard !prefix.isEmpty else { return nil }
//    str.removeFirst(prefix.count)
//    return ()
//}

// 40.446° N, 79.982° W
struct Coordinate {
    let latitude: Double
    let longitude: Double
}

let northSouth = char
    .flatMap {
        $0 == "N" ? always(1.0)
            : $0 == "S" ? always(-1)
            : .never
    }
let eastWest = char
    .flatMap {
        $0 == "E" ? always(1.0)
            : $0 == "W" ? always(-1)
            : .never
    }

let latitude = zip(double, literal("°"), oneOrMoreSpaces, northSouth)
    .map { lat, _, _,  latSign in lat * latSign }

let longitude = zip(double, literal("°"), oneOrMoreSpaces, eastWest)
    .map { long, _, _, longSign in long * longSign }

let coord = zip(zeroOrMoreSpaces, latitude, literal(","), oneOrMoreSpaces, longitude, zeroOrMoreSpaces)
    .map { _, lat, _, _, long, _ in
        Coordinate(
            latitude: lat,
            longitude: long
        )
}

coord.run("40.446° N, 79.982° W")
coord.run("40.446°  N, 79.982°  W")
coord.run("    40.446°  N, 79.982°  W   ")

let df = DateFormatter()
df.dateStyle = .medium
print(df.date(from: "Jan 29, 2018")!)
print(df.date(from: "Jan  29,     2018")!)
print(df.date(from: "    Jan  29,     2018")!)

try NSRegularExpression(pattern: " *")

Scanner().charactersToBeSkipped = .whitespaces


oneOrMoreSpaces.run("      Hello")
oneOrMoreSpaces.run("Hello")



/*
 
 Exercise 1.
 
 Define a parser combinator, zeroOrMore, that takes a parser of As as input and produces a parser of Array<A>s by running the existing parser as many times as it can.
 
 */

func zeroOrMore<A>(_ parser: Parser<A>) -> Parser<[A]> {
    return Parser<[A]> { str in
        var results = [A]()
        while let result = parser.run(&str) {
            results.append(result)
        }
        return results
    }
}

zeroOrMore(literal("a")).run("sd")
zeroOrMore(literal("a")).run("aaaasd")

/*
 
 Exercise 2.
 
 Define a parser combinator, oneOrMore, that takes a parser of As as input and produces a parser of Array<A>s that must include at least one value.
 
 */

func oneOrMore<A>(_ parser: Parser<A>) -> Parser<[A]> {
    return zeroOrMore(parser).flatMap {
        $0.isEmpty ? .never : always($0)
    }
}

oneOrMore(literal("a")).run("sd")
oneOrMore(literal("a")).run("aaaasd")

/*
 
 Exercise 3.
 
 Enhance the zeroOrMore and oneOrMore parsers to take a separatedBy argument in order to parse a comma-separated list. Ensure that only separators between parsed values are consumed.
 
 */

func zeroOrMore<A>(_ parser: Parser<A>, separatedBy: String) -> Parser<[A]> {
    let separatorEater = literal(separatedBy)
    return Parser<[A]> { str in
        var results = [A]()
        while let result = parser.run(&str) {
            results.append(result)
            if separatorEater.run(&str) == nil { break }
        }
        return results
    }
}

zeroOrMore(int, separatedBy: ", ").run("a")
zeroOrMore(int, separatedBy: ", ").run(", ")
zeroOrMore(int, separatedBy: ", ").run("1")
zeroOrMore(int, separatedBy: ", ").run("1, 2, 3")

func oneOrMore<A>(_ parser: Parser<A>,
                  separatedBy: String) -> Parser<[A]> {
    return zeroOrMore(parser, separatedBy: separatedBy).flatMap {
        $0.isEmpty ? .never : always($0)
    }
}

oneOrMore(int, separatedBy: ", ").run("a")
oneOrMore(int, separatedBy: ", ").run(", ")
oneOrMore(int, separatedBy: ", ").run("1")
oneOrMore(int, separatedBy: ", ").run("1, 2, 3")

/*
 
 Exercise 4.
 
 Redefine the zeroOrMoreSpaces and oneOrMoreSpaces parsers in terms of zeroOrMore and oneOrMore.
 
 */

let zeroOrMoreSpaces4 = zeroOrMore(literal(" ")).map { _ in }
let oneOrMoreSpaces4 = oneOrMore(literal(" ")).map { _ in }

zeroOrMoreSpaces4.run("      Hello")
zeroOrMoreSpaces4.run("Hello")
oneOrMoreSpaces4.run("      Hello")
oneOrMoreSpaces4.run("Hello")

//: [Next](@next)
