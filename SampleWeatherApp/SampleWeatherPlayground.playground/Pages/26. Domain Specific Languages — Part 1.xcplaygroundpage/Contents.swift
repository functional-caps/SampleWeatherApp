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

func simplify2(_ expr: Expr) -> Expr {
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

print(simplify2(.add(.mul(1, 2), .mul(3, 2))))
print(simplify2(.add(.mul(1, .var), .mul(3, .var))))

/*
 
 Exercise 1.2
 Reduce 1 * a and a * 1 to just a.

*/



/*

 Exercise 1.3
 Reduce 0 * a and a * 0 to just 0.

 */



/*
 
 Exercise 1.4
 Reduce 0 + a and a + 0 to just a.
 
 */



/*
 
 Exercise 1.5
 Are there any other simplification patterns you know of that you could implement?
 
 */



/*
 
 Exercise 2.
 Enhance Expr to allow for any number of variables. The eval implementation will need to change to allow passing values in for all of the variables introduced.
 
 */



/*
 
 Exercise 3.
 Implement infix operators * and + to work on Expr to get rid of the .add and .mul annotations.
 
 */



/*
 
 Exercise 4.
 Implement a function varCount: (Expr) -> Int that counts the number of .var’s used in an expression.
 
 */



/*
 
 Exercise 5.
 Write a pretty printer for Expr that adds a new line and indentation when printing the sub-expressions inside .add and .mul
 
 */


//: [Next](@next)
