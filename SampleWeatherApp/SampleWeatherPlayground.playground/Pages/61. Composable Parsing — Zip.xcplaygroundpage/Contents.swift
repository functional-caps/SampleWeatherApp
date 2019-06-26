//: [Previous](@previous)

import Foundation

struct GenericParser<I, A> {
    //    let run: (String) -> A?
    //    let run: (String) -> (match: A?, rest: String)
    let run: (inout I) -> Result<A, String>
}

extension GenericParser where I == Substring {
    func run(_ str: String) -> (match: Result<A, String>, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

let int = GenericParser<Substring, Int> { str in
    let prefix = str.prefix(while: { $0.isNumber })
    guard let int = Int(prefix) else { return .failure("Int.init niled") }
    str.removeFirst(prefix.count)
    return .success(int)
}

let double = GenericParser<Substring, Double> { str in
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

func literal(_ string: String) -> GenericParser<Substring, Void> {
    return GenericParser<Substring, Void> { str in
        guard str.hasPrefix(string) else { return .failure("No prefix found") }
        str.removeFirst(string.count)
        return .success(())
    }
}

literal("a").run("ab")
literal("a").run("ba")
literal("a").run("aaba")

func always<I, A>(_ a: A) -> GenericParser<I, A> {
    return GenericParser<I, A> { _ in .success(a) }
}

always("cat").run("dog")

func never<I, A>() -> GenericParser<I, A> {
    return GenericParser<I, A> { _ in .failure("never") }
}

extension GenericParser {
    static var never: GenericParser {
        return GenericParser { _ in .failure("never") }
    }
}

GenericParser<Substring, Int>.never.run("dog")

typealias Parser<A> = GenericParser<Substring, A>

// map: ((A) -> B) -> (F<A>) -> F<B>

// F<A> = Parser<A>
// map: ((A) -> B) -> (Parser<A>) -> Parser<B>

// map(id) = id

[1, 2, 3]
    .map { $0 }

Optional("Blob")
    .map { $0 }

extension GenericParser {
    func map<B>(_ f: @escaping (A) -> B) -> GenericParser<I, B> {
        return GenericParser<I, B> { str -> Result<B, String> in
            self.run(&str).map(f)
        }
    }
    
    func fakeMap<B>(_ f: @escaping (A) -> B) -> GenericParser<I, B> {
        return GenericParser<I, B> { _ in .failure("") }
    }
    
}

extension GenericParser where I == Substring {
    func fakeMap2<B>(_ f: @escaping (A) -> B) -> GenericParser<I, B> {
        return GenericParser<I, B> { str in
            let result = self.run(&str).map(f)
            str = ""
            return result
        }
    }
}

int
    .map { $0 }
    .run("123abc")

int
    .fakeMap { $0 }
    .run("123abc")

int
    .fakeMap2 { $0 }
    .run("123abc")

let even = int.map { $0 % 2 == 0 }
even.run("123 hello world")
even.run("42 hello world")

// 40.6782° N, 73.9442° W

let char = Parser<Character> { str in
    guard !str.isEmpty else { return .failure("empty") }
    return .success(str.removeFirst())
}

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

extension GenericParser {
    
    func flatMap<B>(
        _ f: @escaping (A) -> GenericParser<I, B>
        ) -> GenericParser<I, B> {
        return GenericParser<I, B> { str in
            var copyStr = str
            switch self.run(&copyStr) {
            case .success(let match):
                switch f(match).run(&copyStr) {
                case .success(let value):
                    str = copyStr
                    return .success(value)
                case .failure(let error):
                    return .failure(error)
                }
            case .failure(let error): return .failure(error)
            }
        }
    }
}

let northSouth = char.flatMap { str -> Parser<Double> in
    str == "N" ? always(1.0)
        : str == "S" ? always(-1.0) : .never
}

let eastWest = char.flatMap { str -> Parser<Double> in
    str == "E" ? always(1.0)
        : str == "W" ? always(-1.0) : .never
}

let coordinates = double
    .flatMap { lat in
        literal("° ")
            .flatMap { northSouth }
            .flatMap { latSign in
                literal(", ")
                    .flatMap { double }
                    .flatMap { long in
                        literal("° ")
                            .flatMap { eastWest }
                            .map { longSign in
                                Coordinate(latitude: lat * latSign,
                                           longitude: long * longSign)
                        }
                }
        }
}

print(
    coordinates.run("40.446° N, 79.982° W")
)

print(
    coordinates.run("40.446° Z, 79.982° W")
)

func zip<I, A, B, C>(
    with f: @escaping (A, B) -> C
) -> (GenericParser<I, A>, GenericParser<I, B>) -> GenericParser<I, C> {
    return { parserA, parserB in
        return GenericParser<I, C> { str in
            var copyStr = str
//            parserA.flatMap { a in
//                parserB.map { b in
//                    f(a, b)
//                }
//            }
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

func zip<I, A, B>(_ a: GenericParser<I, A>, _ b: GenericParser<I, B>) -> GenericParser<I, (A, B)> {
    return zip(with: { ($0, $1) })(a, b)
}

enum Currency {
    case eur
    case gbp
    case usd
}

"$10"
"£10"
"€10"

let currency = char.flatMap {
    $0 == "€" ? always(Currency.eur)
        : $0 == "£" ? always(Currency.gbp)
        : $0 == "$" ? always(Currency.usd)
        : never()
}

struct Money {
    let currency: Currency
    let value: Double
}

let money = zip(currency, double).map(Money.init)

print(
money.run("$10")
)
print(
money.run("£10")
)
print(
money.run("€10")
)

"40.446° N, 79.982° W"

func zip<I, A, B, C>(
    _ a: GenericParser<I, A>,
    _ b: GenericParser<I, B>,
    _ c: GenericParser<I, C>
) -> GenericParser<I, (A, B, C)> {
    return zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip<I, A, B, C, D>(
    _ a: GenericParser<I, A>,
    _ b: GenericParser<I, B>,
    _ c: GenericParser<I, C>,
    _ d: GenericParser<I, D>
    ) -> GenericParser<I, (A, B, C, D)> {
    return zip(a, zip(b, c, d))
        .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}

func zip<I, A, B, C, D, E>(
    _ a: GenericParser<I, A>,
    _ b: GenericParser<I, B>,
    _ c: GenericParser<I, C>,
    _ d: GenericParser<I, D>,
    _ e: GenericParser<I, E>
    ) -> GenericParser<I, (A, B, C, D, E)> {
    return zip(a, zip(b, c, d, e))
        .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

func zip<I, A, B, C, D, E, F>(
    _ a: GenericParser<I, A>,
    _ b: GenericParser<I, B>,
    _ c: GenericParser<I, C>,
    _ d: GenericParser<I, D>,
    _ e: GenericParser<I, E>,
    _ f: GenericParser<I, F>
) -> GenericParser<I, (A, B, C, D, E, F)> {
    return zip(a, zip(b, c, d, e, f))
        .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

func zip<I, A, B, C, D, E, F, G>(
    _ a: GenericParser<I, A>,
    _ b: GenericParser<I, B>,
    _ c: GenericParser<I, C>,
    _ d: GenericParser<I, D>,
    _ e: GenericParser<I, E>,
    _ f: GenericParser<I, F>,
    _ g: GenericParser<I, G>
    ) -> GenericParser<I, (A, B, C, D, E, F, G)> {
    return zip(a, zip(b, c, d, e, f, g))
        .map { a, bcdefg in
            (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5)
        }
}

func zip<I, A, B, C, D, E, F, G, Z>(
    with: @escaping (A, B, C, D, E, F, G) -> Z
    ) -> (
    GenericParser<I, A>,
    GenericParser<I, B>,
    GenericParser<I, C>,
    GenericParser<I, D>,
    GenericParser<I, E>,
    GenericParser<I, F>,
    GenericParser<I, G>
    ) -> GenericParser<I, Z> {
        return { parserA, parserB, parserC, parserD, parserE, parserF, parserG
            in
            return GenericParser<I, Z> { str in
                var copyStr = str
                let result = parserA.flatMap { a in
                    parserB.flatMap { b in
                        parserC.flatMap { c in
                            parserD.flatMap { d in
                                parserE.flatMap { e in
                                    parserF.flatMap { f in
                                        parserG.map { g in
                                            with(a, b, c, d, e, f, g)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    }.run(&copyStr)
                switch result {
                case .success: str = copyStr
                default: break
                }
                return result
            }
        }
}

let latitude = zip(double, literal("° "), northSouth)
    .map { lat, _, latSign in lat * latSign }

let longitude = zip(double, literal("° "), eastWest)
    .map { long, _, longSign in long * longSign }

let coordA = zip(latitude, literal(", "), longitude)
    .map { lat, _, long in
        Coordinate(latitude: lat, longitude: long)
    }


func parseLatLongByHand(_ str: String) -> Coordinate? {
    let parts = str.split(separator: " ")
    guard parts.count == 4 else { return nil }
    guard
        let lat = Double(parts[0].dropLast()),
        let long = Double(parts[2].dropLast())
        else { return nil }
    let latCard = parts[1].dropLast()
    let longCard = parts[3]
    guard latCard == "N" || latCard == "S" else { return nil }
    guard longCard == "E" || longCard == "W" else { return nil }
    let latSign = latCard == "N" ? 1.0 : -1.0
    let longSign = longCard == "E" ? 1.0 : -1.0
    return Coordinate(
        latitude: lat * latSign,
        longitude: long * longSign
    )
}

/*
 
 Exercise 1.
 
 Define an alternate parser that parses coordinates formatted as decimal degree minutes, like "40° 26.767′ N 79° 58.933′ W".
 
 */

let latitude1 = zip(int, literal("° "), double, literal("′ "), northSouth)
    .map { deg, _, min, _, sign in (Double(deg) + min / 60.0) * sign }

let longitude1 = zip(int, literal("° "), double, literal("′ "), eastWest)
    .map { deg, _, min, _, sign in (Double(deg) + min / 60.0) * sign }

let coord1 = zip(latitude1, literal(" "), longitude1)
    .map { lat, _, long in
        Coordinate(latitude: lat, longitude: long)
    }

print(
coord1.run("40° 26.767′ N 79° 58.933′ W")
)


/*
 
 Exercise 2.
 
 Define an alternate parser that parses coordinates formatted as decimal degree minutes and seconds, like "40° 26′ 46″ N 79° 58′ 56″ W".
 
 */

let latitude2 = zip(int, literal("° "), int, literal("′ "), int, literal("″ "), northSouth)
    .map { deg, _, min, _, sec, _, sign in (Double(deg) + Double(min) / 60.0 + Double(sec) / 3600) * sign }

let longitude2 = zip(int, literal("° "), int, literal("′ "), int, literal("″ "), eastWest)
    .map { deg, _, min, _, sec, _, sign in (Double(deg) + Double(min) / 60.0 + Double(sec) / 3600) * sign }

let coord2 = zip(latitude2, literal(" "), longitude2)
    .map { lat, _, long in
        Coordinate(latitude: lat, longitude: long)
}

print(
    coord2.run("40° 26′ 46″ N 79° 58′ 56″ W")
)

/*

 Exercise 3.

 Build an ISO-8601 parser that can parse the date string 2018-01-29T12:34:56Z.
 
 */

struct Year {
    let y: Int
    let m: Int
    let d: Int
}

struct Time {
    let h: Int
    let m: Int
    let s: Int
}

let year = zip(int, literal("-"), int, literal("-"), int)
    .map { Year(y: $0, m: $2, d: $4) }
let time = zip(int, literal(":"), int, literal(":"), int)
    .map { Time(h: $0, m: $2, s: $4) }
let iso = zip(year, literal("T"), time, literal("Z"))
    .map { (a: Year, _: Void, b: Time, _: Void) -> Date? in
        var comps = DateComponents()
        comps.year = a.y
        comps.month = a.m
        comps.day = a.d
        comps.hour = b.h
        comps.minute = b.m
        comps.second = b.s
        comps.calendar = .autoupdatingCurrent
        return comps.date
    }


//return comps.date

year.run("2018-01-29")

print(
iso.run("2018-01-29T12:34:56Z")
)

/*
 
 Exercise 4.

 Create a parser, oneOrMoreSpaces, that parses one or more spaces off the beginning of a string. Why can’t this parser be defined using map, flatMap, and/or zip?
 
 */

let oneOrMoreSpaces: GenericParser<Substring, Substring> = .init { str in
    var copyStr = str
    guard !copyStr.isEmpty else { return .failure("must not be empty") }
    let first = copyStr.removeFirst()
    guard first.isWhitespace else { return .failure("no spaces at all") }
    let prefix = str.prefix(while: { $0.isWhitespace })
    str.removeFirst(prefix.count)
    return .success(prefix)
}

oneOrMoreSpaces.run("asd")
oneOrMoreSpaces.run(" asd")
oneOrMoreSpaces.run("      asd")

// it cannot be defined using map, flatMap or zip because it's recursive. it's output should be fed to its input. the map, flatMap and zip are linear operations

/*
 
 Exercise 5.

 Create a parser, zeroOrMoreSpaces, that parses zero or more spaces off the beginning of a string. How does it differ from oneOrMoreSpaces?
 
 */

let zeroOrMoreSpaces: GenericParser<Substring, Substring> = .init { str in
    let prefix = str.prefix(while: { $0.isWhitespace })
    str.removeFirst(prefix.count)
    return .success(prefix)
}

zeroOrMoreSpaces.run("asd")
zeroOrMoreSpaces.run(" asd")
zeroOrMoreSpaces.run("      asd")

// the main difference is that the zeroOrMoreSpaces is always succeeding, because there is always at least zero whitespaces at the beginning of the string

/*
 
 Exercise 6.

 Define a function that shares the common parsing logic of oneOrMoreSpaces and zeroOrMoreSpaces. It should have the signature ((Character) -> Bool) -> Parser<Substring>. Redefine oneOrMoreSpaces and zeroOrMoreSpaces in terms of this function.
 
 */

func filter(_ f: @escaping (Character) -> Bool) -> GenericParser<Substring, Substring> {
    return GenericParser<Substring, Substring> { str in
        let prefix = str.prefix(while: f)
        str.removeFirst(prefix.count)
        return .success(prefix)
    }
}

let zeroOrMoreSpaces2 = filter { $0.isWhitespace }
zeroOrMoreSpaces2.run("asd")
zeroOrMoreSpaces2.run(" asd")
zeroOrMoreSpaces2.run("      asd")

let oneOrMoreSpaces2 = GenericParser<Substring, Substring> { str in
    guard let first = str.first, first.isWhitespace
    else { return .failure("must have at least one whitespace character at the front") }
    return .success(str)
}.flatMap { _ in
    filter { $0.isWhitespace }
}

oneOrMoreSpaces2.run("asd")
oneOrMoreSpaces2.run(" asd")
oneOrMoreSpaces2.run("      asd")

/*
 
 Exercise 7.

 Redefine zip on Parser in terms of flatMap on Parser.
 
 */

func zip7<I, A, B>(_ a: GenericParser<I, A>, _ b: GenericParser<I, B>) -> GenericParser<I, (A, B)> {
    return a.flatMap { valA in
        b.map { valB in
            (valA, valB)
        }
    }
}

let money7 = zip7(currency, double).map(Money.init)
print(money7.run("$10"))

//: [Next](@next)
