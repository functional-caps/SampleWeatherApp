//: [Previous](@previous)

import Foundation

Int("42")
Int("42-")
Double("42")
Double("42.32435")
Bool("true")
Bool("false")
Bool("f")

UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")
UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEE")
UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEZ")

URL.init(string: "https://www.pointfree.co")
URL.init(string: "^https://www.pointfree.co")

let components = URLComponents.init(string: "https://www.pointfree.co?ref=twitter")
components?.queryItems

let df = DateFormatter()
df.timeStyle = .none
df.dateStyle = .short
type(of: df.date(from: "1/29/17"))
df.date(from: "-1/29/17")

let emailRegex = try NSRegularExpression(pattern: #"\S+@\S+"#)
let emailString = "You log blob@pointfree.co"
let emailRange = emailString.startIndex..<emailString.endIndex
let match = emailRegex.firstMatch(
    in: emailString,
    range: NSRange(emailRange, in: emailString)
    )!
emailString[Range(match.range(at: 0), in: emailString)!]

let scanner = Scanner(string: "42 hello")
//var int = 0
//scanner.scanInt(&int)
//int

// 40.6782° N, 73.9442° W

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

func parseLatLong(_ str: String) -> Coordinate? {
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

print(parseLatLong("40.6782° N, 73.9442° W"))

// typealias Parser<A> = (String) -> A?

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
        $0.isNumber || "-+".contains($0)
    })
    guard let int = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return int
}

//Substring

int.run("42")
int.run("42 hello")
int.run("hello")

// (A) -> A
// (inout A) -> Void

enum Route {
    case home
    case profile
    case episodes
    case episode(id: Int)
}

let router = Parser<Route> { str in
    fatalError("asdasd")
}

//router.run("/") // .home
//router.run("/episodes/42") // .episode(id: 42)

//switch router.run("/episodes/42") {
//case .home?:
//case .profile?:
//case .episodes?
//case let .episode(id):
//case nil:
//}

enum EnumPropertyGenerator {
    case help
    case version
    case invoke(urls: [URL], dryRun: Bool)
}

let cli = Parser<EnumPropertyGenerator> { str in
    fatalError()
}

//cli.run("generate-enum-properties --version") // .version
//cli.run("generate-enum-properties --help") // .help
//cli.run("generate-enum-properties --dry-run /path/file.swift") // .invoke(urls: ["/path/file.swift"], dryRun: true)

//switch cli.run("generate-enum-properties --dry-run /path/file.swift") {
//case .help?:
//case .version?:
//case let invoke(urls, dryRun):
//case nil:
//}

/*
 
 Exercise 1.
 
 Create a parser char: Parser<Character> that will parser a single character off the front of the input string.
 
 */

let char = Parser<Character> { str in
    guard let first = str.first else { return nil }
    str.removeFirst()
    return first
}

char.run("Hello")

/*
 
 Exercise 2.
 
 Create a parser whitespace: Parser<Void> that consumes all of the whitespace from the front of the input string. Note that this parser is of type Void because we probably don’t care about the actual whitespace we consumed, we just want it consumed.
 
 */

let whitespace = Parser<Void> { str in
    let white = str.prefix(while: { $0.isWhitespace })
    guard !white.isEmpty else { return nil }
    str.removeFirst(white.count)
    return ()
}

whitespace.run("aaaa")
whitespace.run("aaaa    ")
whitespace.run("     aa  aa    ")

/*
 
 Exercise 3.
 
 Right now our int parser doesn’t work for negative numbers, for example int.run("-123") will fail. Fix this deficiency in int.
 
 */

int.run("-42")

/*
 
 Exercise 4.
 
 Create a parser double: Parser<Double> that consumes a double from the front of the input string.
 
 */

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

/*
 
 Exercise 5.
 
 Define a function literal: (String) -> Parser<Void> that takes a string, and returns a parser which will parse that string from the beginning of the input. This exercise shows how you can build complex parsers: you can use a function to take some up-front configuration, and then use that data in the definition of the parser.
 
 */

func literal(_ string: String) -> Parser<Void> {
    return Parser<Void> { str in
        let common = str.commonPrefix(with: string)
        guard common == string else { return nil }
        str.removeFirst(string.count)
        return ()
    }
}

literal("a").run("ab")
literal("a").run("ba")
literal("a").run("aaba")

/*
 
 Exercise 6.
 
 In this episode we mentioned that there is a correspondence between functions of the form (A) -> A and functions (inout A) -> Void. We even covered this in a previous episode, but it is instructive to write it out again. So, define two functions toInout and fromInout that will transform functions of the form (A) -> A to functions (inout A) -> Void, and vice-versa.
 
 */

func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { $0 = f($0) }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var copyA = a
        f(&copyA)
        return copyA
    }
}

toInout { (int: String) -> String in return "elo \(int)" }
fromInout(
    toInout { (int: String) -> String in return "elo \(int)" }
)

//: [Next](@next)
