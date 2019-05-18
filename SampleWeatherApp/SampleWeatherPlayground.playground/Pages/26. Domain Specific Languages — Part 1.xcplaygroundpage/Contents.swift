//: [Previous](@previous)

import Foundation

enum Expr: Equatable {
    case int(Int)
    case `var`
    indirect case add(Expr, Expr)
    indirect case mul(Expr, Expr)
}

Expr.int(3)
Expr.add(.int(3), .int(4))
Expr.add(.add(.int(3), .int(4)), .int(5))

extension Expr: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

Expr.add(3, 5)

func eval(_ expr: Expr, with value: Int) -> Int {
    switch expr {
    case let .int(value):
        return value
    case let .add(lhs, rhs):
        return eval(lhs, with: value) + eval(rhs, with: value)
    case let .mul(lhs, rhs):
        return eval(lhs, with: value) * eval(rhs, with: value)
    case .var:
        return value
    }
}

eval(.add(1, .add(2, 3)), with: 0)

func print(_ expr: Expr) -> String {
    
    switch expr {
    case let .int(value):
        return "\(value)"
    case let .add(lhs, rhs):
        return "(\(print(lhs)) + \(print(rhs)))"
    case let .mul(lhs, rhs):
        return "(\(print(lhs)) * \(print(rhs)))"
    case .var:
        return "x"
    }
    
}

print(.add(1, .add(2, 3)))
print(.mul(.add(3, 4), .add(5, 6)))

func swap(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(lhs, rhs):
        return .mul(swap(lhs), swap(rhs))
    case let .mul(lhs, rhs):
        return .add(swap(lhs), swap(rhs))
    case .var:
        return expr
    }
}

print(swap(.mul(.add(3, 4), .add(5, 6))))

func simplify(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a, b), .mul(c, d)) where a == c:
        return .mul(a, .add(b, d))
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(.add(.mul(2, 3), .mul(2, 4)))
print(simplify(.add(.mul(2, 3), .mul(2, 4))))
print(simplify(.add(.mul(.var, 3), .mul(.var, 4))))
eval(simplify(.add(.mul(.var, 3), .mul(.var, 4))), with: 2)

/*
 
 Exercise 1.
 Improve the simplify function to also recognize the following patterns:
 
 Exercise 1.1
 Factorize the c out of this expression: a * c + b * c.
 
 */

func simplify11(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(.add(.mul(1, 2), .mul(3, 2)))
print(simplify11(.add(.mul(1, 2), .mul(3, 2))))
print(simplify11(.add(.mul(1, .var), .mul(3, .var))))

/*
 
 Exercise 1.2
 Reduce 1 * a and a * 1 to just a.

*/

func simplify12(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .mul(1, let e), .mul(let e, 1): return e
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(.mul(1, 2))
print(simplify12(.mul(1, 2)))
print(.mul(2, 1))
print(simplify12(.mul(2, 1)))

/*

 Exercise 1.3
 Reduce 0 * a and a * 0 to just 0.

 */

func simplify13(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .mul(1, let e), .mul(let e, 1): return e
    case .mul(0, _), .mul(_, 0): return 0
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(.mul(0, 2))
print(simplify13(.mul(0, 2)))
print(.mul(2, 0))
print(simplify13(.mul(2, 0)))

/*
 
 Exercise 1.4
 Reduce 0 + a and a + 0 to just a.
 
 */

func simplify14(_ expr: Expr) -> Expr {
    switch expr {
    case .int:
        return expr
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .add(0, let e), .add(let e, 0): return e
    case .mul(1, let e), .mul(let e, 1): return e
    case .mul(0, _), .mul(_, 0): return 0
    
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(.add(0, 2))
print(simplify14(.add(0, 2)))
print(.add(2, 0))
print(simplify14(.add(2, 0)))

/*
 
 Exercise 1.5
 Are there any other simplification patterns you know of that you could implement?
 
 */

func simplify15(_ expr: Expr) -> Expr {
    switch expr {
    case .int: return expr
        
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .add(0, let e), .add(let e, 0): return e
        
    case let .mul(.add(a, b), .add(c, d)): return .add(.add(.mul(a, c), .mul(a, d)), .add(.mul(b, c), .mul(b, d)))
    case .mul(1, let e), .mul(let e, 1): return e
    case .mul(0, _), .mul(_, 0): return 0
        
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print(simplify15(.mul(.add(5, 2), .add(3, 4))))

/*
 
 Exercise 2.
 Enhance Expr to allow for any number of variables. The eval implementation will need to change to allow passing values in for all of the variables introduced.
 
 */

enum Expr2: Equatable {
    case int(Int)
    case `var`(String)
    indirect case add(Expr2, Expr2)
    indirect case mul(Expr2, Expr2)
}

extension Expr2: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Expr2: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .var(value)
    }
}

func eval2(_ expr: Expr2, with values: [String: Int]) -> Int? {
    switch expr {
    case let .int(value):
        return value
    case let .add(lhs, rhs):
        guard let first = eval2(lhs, with: values), let second = eval2(rhs, with: values) else { return nil }
        return first + second
    case let .mul(lhs, rhs):
        guard let first = eval2(lhs, with: values), let second = eval2(rhs, with: values) else { return nil }
        return first * second
    case .var(let name):
        return values[name]
    }
}

func print2(_ expr: Expr2) -> String {
    
    switch expr {
    case let .int(value):
        return "\(value)"
    case let .add(lhs, rhs):
        return "(\(print2(lhs)) + \(print2(rhs)))"
    case let .mul(lhs, rhs):
        return "(\(print2(lhs)) * \(print2(rhs)))"
    case .var(let name):
        return name
    }
    
}

func swap2(_ expr: Expr2) -> Expr2 {
    switch expr {
    case .int:
        return expr
    case let .add(lhs, rhs):
        return .mul(swap2(lhs), swap2(rhs))
    case let .mul(lhs, rhs):
        return .add(swap2(lhs), swap2(rhs))
    case .var:
        return expr
    }
}

func simplify2(_ expr: Expr2) -> Expr2 {
    switch expr {
    case .int: return expr
        
    case let .add(.mul(a, b), .mul(c, d)) where a == c, let .add(.mul(b, a), .mul(d, c)) where a == c:
        return .mul(a, .add(b, d))
    case .add(0, let e), .add(let e, 0): return e
        
    case let .mul(.add(a, b), .add(c, d)): return .add(.add(.mul(a, c), .mul(a, d)), .add(.mul(b, c), .mul(b, d)))
    case .mul(1, let e), .mul(let e, 1): return e
    case .mul(0, _), .mul(_, 0): return 0
        
    case .add: return expr
    case .mul: return expr
    case .var: return expr
    }
}

print2(.mul("x", .add(2, "y")))
eval2(.mul("x", .add(2, "y")), with: ["x": 2, "y": 2])
print2(.mul("x", "y"))
eval2(.mul("x", "y"), with: ["x": 9, "y": 8])

/*
 
 Exercise 3.
 Implement infix operators * and + to work on Expr to get rid of the .add and .mul annotations.
 
 */

extension Expr2 {
    static func + (lhs: Expr2, rhs: Expr2) -> Expr2 {
        return .add(lhs, rhs)
    }
    
    static func * (lhs: Expr2, rhs: Expr2) -> Expr2 {
        return .mul(lhs, rhs)
    }
}

print2("a" * "b")
print2(1 + "a" * "b")

/*
 
 Exercise 4.
 Implement a function varCount: (Expr) -> Int that counts the number of .var’s used in an expression.
 
 */

func varCount(_ expr: Expr2) -> Int {
    switch expr {
    case .var: return 1
    case .int: return 0
    case let .add(lhs, rhs), let .mul(lhs, rhs): return varCount(lhs) + varCount(rhs)
    }
}

print2(2 * 3 + 1 + "a" * "b" * 5)
varCount(2 * 3 + 1 + "a" * "b" * 5)

/*
 
 Exercise 5.
 Write a pretty printer for Expr that adds a new line and indentation when printing the sub-expressions inside .add and .mul
 
 .add(1, .mul(2, 3))
 
 (
   1 +
     2 * 3
 */

func prettyPrint(_ expr: Expr2) -> String {
    
    func actualPrint(expr: Expr2, indentation: Int, line: Bool) -> String {
        let indent = String(repeating: " -> ", count: indentation)
        let newLine = line ? "\n" : ""
        let start = "\(newLine)\(indent)"
        switch expr {
        case let .int(value):
            return "\(indent)\(value)"
        case let .add(lhs, rhs):
            return "\(start)(\(actualPrint(expr: lhs, indentation: 0, line: true)) + \(actualPrint(expr: rhs, indentation: 0, line: true)))"
        case let .mul(lhs, rhs):
            return "\(start)(\(actualPrint(expr: lhs, indentation: 0, line: true)) * \(actualPrint(expr: rhs, indentation: 0, line: true)))"
        case .var(let name):
            return "\(indent)\(name)"
        }
    }
    return actualPrint(expr: expr, indentation: 0, line: false)
}

print(prettyPrint(1 * "x" + "y" * 4 + 123))

//: [Next](@next)
