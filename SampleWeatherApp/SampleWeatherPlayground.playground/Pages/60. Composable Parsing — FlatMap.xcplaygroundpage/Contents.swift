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
    let prefix = str.prefix(while: {
        $0.isNumber || $0 == "-"
    })
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

/*
 
 Exercise 1.
 
 We have previously devoted 3 entire episodes (part 1, part 2, part 3) to zip. In those episodes we showed that those operations are very general, and go far beyond what Swift gives us in the standard library for arrays and optionals.
 
 Define zip and flatMap on the Parser type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume any of the input string if the parser fails.
 
 */

func zip<I, A, B, C>(
    with f: @escaping (A, B) -> C
) -> (GenericParser<I, A>, GenericParser<I, B>) -> GenericParser<I, C> {
    return { parserA, parserB in
        return GenericParser<I, C> { str in
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
 
/*
 
 Exercise 2.
 
 Use the zip function defined in the previous exercise to construct a Parser<Coordinate> for parsing strings of the form "40.446° N, 79.982° W". You may want to define zip overloads that work on more than 2 parsers at a time.
 
 */

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


let coordinates2 = zip(with: { (lat, _, latSign, _, long, _, longSign) in
    Coordinate(latitude: lat * latSign, longitude: long * longSign)
})(
    double,
    literal("° "),
    northSouth,
    literal(", "),
    double,
    literal("° "),
    eastWest
)

print(
    coordinates2.run("40.446° N, 79.982° W")
)

print(
    coordinates2.run("40.446° Z, 79.982° W")
)

//: [Next](@next)
