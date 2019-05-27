//: [Previous](@previous)

import Foundation

var str = "Hello, playground"

protocol Describable {
    var describe: String { get }
}

extension Int: Describable {
    var describe: String {
        return "\(self)"
    }
}

2.describe

protocol EmptyInitializable {
    init()
}

extension String: EmptyInitializable {}
extension Array: EmptyInitializable {}
extension Int: EmptyInitializable { init() { self = 1 }}

extension Optional: EmptyInitializable {
    init() { self = nil }
}

extension Array {
    func reduce<T: EmptyInitializable>(_ f: (T, Element) -> T) -> T {
        return reduce(T(), f)
    }
}

[1, 2, 3].reduce(+)
["Hello", " ", "Blob"].reduce(+)

protocol Combinable {
    func combine(with other: Self) -> Self
}

extension Int: Combinable {
    func combine(with other: Int) -> Int {
        return self * other
    }
}

extension String: Combinable {
    func combine(with other: String) -> String {
        return self + other
    }
}

extension Array: Combinable {
    func combine(with other: Array) -> Array {
        return self + other
    }
}

extension Optional: Combinable {
    func combine(with other: Optional) -> Optional {
        return self ?? other
    }
}

extension Array where Element: Combinable & EmptyInitializable {
    func reduce() -> Element {
        return reduce(Element()) { $0.combine(with: $1) }
    }
}

[1, 2, 3, 4].reduce()

//extension Int: Combinable {
//    func combine(with other: Int) -> Int {
//        return self * other
//    }
//}



//: [Next](@next)
