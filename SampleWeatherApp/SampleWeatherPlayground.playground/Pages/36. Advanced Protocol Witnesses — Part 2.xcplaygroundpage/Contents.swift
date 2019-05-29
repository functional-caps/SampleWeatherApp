//: [Previous](@previous)

import Foundation

struct Equating<A> {
    let equal: (A, A) -> Bool
}

let equalInt = Equating<Int> { $0 == $1 }
equalInt.equal(1, 2)
equalInt.equal(1, 1)

extension Equating where A == Int {
    static let int = Equating(equal: ==)
}

extension Equating {
    
    static func array(of equating: Equating) -> Equating<[A]> {
        return Equating<[A]> { first, second in
            guard first.count == second.count else { return false }
            for (lhs, rhs) in zip(first, second) {
                if !equating.equal(lhs, rhs) {
                    return false
                }
            }
            return true
        }
    }
}

Equating.array(of: .int).equal([], [])
Equating.array(of: .int).equal([1], [])
Equating.array(of: .int).equal([1], [1])
Equating.array(of: .int).equal([1], [1, 2])

extension Equating {
    func pullback<B>(_ f: @escaping (B) -> A) -> Equating<B> {
        return Equating<B> { lhs, rhs in
            self.equal(f(lhs), f(rhs))
        }
    }
}

extension Equating where A == Void {
    static let void = Equating { _, _ in true }
}

Equating.array(of: .void).equal([()], [()])

extension Equating {
    static func tuple<B>(_ a: Equating<A>, _ b: Equating<B>) -> Equating<(A, B)> {
        return Equating<(A, B)> { lhs, rhs in
            a.equal(lhs.0, rhs.0) && b.equal(lhs.1, rhs.1)
        }
    }
}

let stringCount: Equating<String> = Equating.int.pullback { $0.count }

Equating.tuple(.int, stringCount).equal((1, "1"), (1, "22"))

struct Combining<A> {
    let combine: (A, A) -> A
}

extension Combining {
    static var endo: Combining<(A) -> A> {
//        return Combining<(A) -> A> { f, g in
//            { a in g(f(a)) }
//        }
        return Combining<(A) -> A>(combine: >>>)
    }
}

struct EmptyInitializing<A> {
    let create: () -> A
}

extension EmptyInitializing {
    static var identity: EmptyInitializing<(A) -> A> {
        return EmptyInitializing<(A) -> A> { { $0 } }
    }
}

let endos: [(Double) -> Double] = [
    { $0 + 1.0 },
    { $0 * $0 },
    sin,
    { $0 * 1000.0 }
]

extension Array {
    func reduce(_ initial: EmptyInitializing<Element>,
                _ combining: Combining<Element>) -> Element {
        return reduce(initial.create(), combining.combine)
    }
}

endos.reduce(EmptyInitializing.identity, Combining.endo)(3)

struct Comparing<A> {
    
    let equating: Equating<A>
    
    let isLess: (A, A) -> Bool
//    let isLessOrEqual: (A, A) -> Bool
//    let isMoreOrEqual: (A, A) -> Bool
//    let isMore: (A, A) -> Bool
    
    func pullback<B>(_ f: @escaping (B) -> A) -> Comparing<B> {
        return Comparing<B>(
            equating: self.equating.pullback(f),
            isLess: { lhs, rhs in
                self.isLess(f(lhs), f(rhs))
            }
        )
    }
}

let comparingInt = Comparing<Int>(
    equating: equalInt, isLess: <//, isLessOrEqual: <=, isMoreOrEqual: >=, isMore: >
)

comparingInt.equating.equal(1, 1)
comparingInt.equating.equal(1, 3)
comparingInt.isLess(1, 3)
//comparingInt.isLessOrEqual(1, 3)
//comparingInt.isMore(1, 3)
//comparingInt.isMoreOrEqual(1, 3)

struct User { let id: Int, name: String }

let intAsc = Comparing(equating: .int, isLess: <)

let userAsc = intAsc.pullback { (u: User) in u.id }

userAsc.equating.equal(User(id: 1, name: "a"), User(id: 0, name: "a"))

extension Equating {
    var notEquals: (A, A) -> Bool { return { lhs, rhs in !self.equal(lhs, rhs) } }
}

public protocol Reusable {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

import UIKit

class UserCell: UITableViewCell {}
class EpisodeCell: UITableViewCell {}
extension UserCell: Reusable {}
extension EpisodeCell: Reusable {}

UserCell.reuseIdentifier

struct Reusing<A> {
    let reuseIdentifier: () -> String
    
    init(reuseIdentifier: @escaping () -> String = { String(describing: A.self) }) {
        self.reuseIdentifier = reuseIdentifier
    }
}

Reusing<UserCell>().reuseIdentifier()

//let collections: [Collection]

enum Directions: String {
    case down = "D"
    case up = "U"
}

Directions.down.rawValue

struct RawRepresenting<A, RawValue> {
    let convert: (RawValue) -> A?
    let rawValue: (A) -> RawValue
}

extension RawRepresenting where A == Int, RawValue == String {
    static let stringToInt = RawRepresenting(
        convert: Int.init, rawValue: String.init(describing:)
    )
}

extension RawRepresenting where A: RawRepresentable, A.RawValue == RawValue {
    static var rawRepresentable: RawRepresenting {
        return RawRepresenting(
            convert: A.init(rawValue:),
            rawValue: { $0.rawValue }
        )
    }
}

RawRepresenting<Directions, String>.rawRepresentable.rawValue(.down)

//: [Next](@next)
