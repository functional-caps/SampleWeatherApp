//: [Previous](@previous)

import Foundation

enum Expr: Equatable {
    case int(Int)
    case `var`(String)
    indirect case add(Expr, Expr)
    indirect case mul(Expr, Expr)
    indirect case bind([String: Expr], in: Expr)
}

extension Expr: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Expr: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .var(value)
    }
}

extension Expr {
    static func + (lhs: Expr, rhs: Expr) -> Expr {
        return .add(lhs, rhs)
    }
    
    static func * (lhs: Expr, rhs: Expr) -> Expr {
        return .mul(lhs, rhs)
    }
}

func eval(_ expr: Expr, with values: [String: Int] = [:]) -> Int? {
    switch expr {
    case let .int(value):
        return value
    case let .add(lhs, rhs):
        guard let first = eval(lhs, with: values), let second = eval(rhs, with: values) else { return nil }
        return first + second
    case let .mul(lhs, rhs):
        guard let first = eval(lhs, with: values), let second = eval(rhs, with: values) else { return nil }
        return first * second
    case .var(let name):
        return values[name]
    case let .bind(bindings, in: scopedExpr):
        var newValues = values
        for (name, boundExpr) in bindings {
            guard let boundValue = eval(boundExpr, with: values) else { return nil }
            newValues.merge([name: boundValue], uniquingKeysWith: { $1 })
        }
        return eval(scopedExpr, with: newValues)
    }
}

func print(_ expr: Expr) -> String {
    
    switch expr {
    case let .int(value):
        return "\(value)"
    case let .add(lhs, rhs):
        return "(\(print(lhs)) + \(print(rhs)))"
    case let .mul(lhs, rhs):
        return "(\(print(lhs)) * \(print(rhs)))"
    case .var(let name):
        return name
    case let .bind(bindings, scopedExpr):
        let boundString = bindings.map { key, value in
            return "(let \(key) = \(print(value)))"
        }.joined(separator: ", ")
        return "(\(boundString) in \(print(scopedExpr)))"
    }
    
}

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
    case .bind:
        return expr
    }
}

func simplify(_ expr: Expr) -> Expr {
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
    case .bind: return expr
    }
}

let expr1 = Expr.mul(3, .bind(["z": .add("x", 2)], in: .mul("z", "z")))
print(expr1)

eval(expr1, with: ["x": 4])

let expr2 = Expr.bind(["x": 4], in: .mul(3, .bind(["z": .add("x", 2)], in: .mul("z", "z"))))
print(expr2)
eval(expr2)

/*
 
 Exercise 1.
 
 Implement an inliner function inline: (Expr) -> Expr that removes all let-bindings and inlines the body of the binding directly into the subexpression.
 
 */

func actualInline(_ expr: Expr, bindings: [String: Expr]) -> Expr {
    switch expr {
    case let .bind(bounds, in: scoped):
        var newBindings = bindings
        for (name, bound) in bounds {
            newBindings[name] = bound
        }
        return actualInline(scoped, bindings: newBindings)
    case let .add(lhs, rhs):
        return .add(actualInline(lhs, bindings: bindings), actualInline(rhs, bindings: bindings))
    case let .mul(lhs, rhs):
        return .mul(actualInline(lhs, bindings: bindings), actualInline(rhs, bindings: bindings))
    case .int: return expr
    case .var(let name):
        return bindings[name] ?? expr
    }
}

func inline(_ expr: Expr) -> Expr {
    return actualInline(expr, bindings: [:])
}

print(inline(expr1))

/*
 
 Exercise 2.
 
 Implement a function freeVars: (Expr) -> String that collects all of the variables used in an expression.
 
 */

func freeVars(_ expr: Expr) -> Set<String> {
    switch expr {
    case .var(let name): return [name]
    case .int: return []
    case let .add(lhs, rhs), let .mul(lhs, rhs): return freeVars(lhs).union(freeVars(rhs))
    case .bind: return freeVars(inline(expr))
    }
}

freeVars(expr1)

/*
 
 Exercise 3.
 
 Define an infix operator .= to mimic let-bindings. At the call site its usage might look something like: ("x" .= 3)("x" * 2 + 3), where we are using the infix operators * and + defined in the exercises of the last episode.
 
 */

infix operator .=

extension Expr {
    static func .= (name: String, bound: Expr) -> (Expr) -> Expr {
        return { scoped in .bind([name: bound], in: scoped) }
    }
}

print(("x" .= 3)("x" * 2 + 3))

/*
 
 Exercise 4.
 
 Update bind to take a dictionary of bindings rather than a single binding.
 
 */

// done?!

print(.bind(["x": 2, "y": 5], in: .mul("x", "y")))

/*
 
 Exercise 5.1
 
 In this exercise we are going to implement a function D: (String) -> (Expr) -> Expr that computes the derivative of any expression you give it. This may sound scary, but we’ll take it one step at a time!
 
 Let’s start simple. The signature D: (String) -> (Expr) -> Expr represents the concept of taking the derivative of an expression with respect to some variable, specified by the String argument. Write down the signature of this function, and call the string argument variable. This string is the variable with respect to which you will be differentiating. Also implement the body as a closure that takes a single argument (the expression), and inside the closure implement the switch over that argument while leaving all the cases unimplemented.
 
 */

//func D(_ variable: String) -> (Expr) -> Expr {
//    return { expr in
//        switch expr {
//        case .int(_):
//            <#code#>
//        case .var(_):
//            <#code#>
//        case .add(_, _):
//            <#code#>
//        case .mul(_, _):
//            <#code#>
//        case .bind(_, let in):
//            <#code#>
//        @unknown default:
//            <#code#>
//        }
//    }
//}


/*
 
 Exercise 5.2
 
 Derivatives have the simple property that they annihilate constants: D(1) = 0, D(-1) = 0, D(2) = 0, i.e. the derivate of any constant is zero. Use this fact to implement the .lit case in the switch you defined above.
 
 */

//func D(_ variable: String) -> (Expr) -> Expr {
//    return { expr in
//        switch expr {
//        case .int:
//            return .int(0)
//        case .var(_):
//            <#code#>
//        case .add(_, _):
//            <#code#>
//        case .mul(_, _):
//            <#code#>
//        case .bind(_, _):
//            <#code#>
//    }
//}

/*
 
 Exercise 5.3
 
 Derivatives also have a simple property for variables. The derivative of a variable with respect to that variable is simply 1, and the derivative of any variable with respect to any other variable is 0. Use this fact to implement the .var case in the switch you defined above.
 
 */

//func D(_ variable: String) -> (Expr) -> Expr {
//    return { expr in
//        switch expr {
//        case .int:
//            return .int(0)
//        case .var(let name):
//            guard name == variable else { return .int(0) }
//            return .int(1)
//        case .add(_, _):
//            <#code#>
//        case .mul(_, _):
//            <#code#>
//        case .bind(_, _):
//            <#code#>
//        }
//}

/*
 
 Exercise 5.4
 
 Derivatives have the wonderful property that they distribute over addition: D(f + g) = D(f) + D(g), i.e. the derivative of a sum is the sum of the derivatives. Use this fact to implement the .add case in the switch you defined above.
 
 */

//func D(_ variable: String) -> (Expr) -> Expr {
//    return { expr in
//        switch expr {
//        case .int:
//            return .int(0)
//        case .var(let name):
//            guard name == variable else { return .int(0) }
//            return .int(1)
//        case let .add(lhs, rhs):
//            return D(variable)(lhs) + D(variable)(rhs)
//        case .mul(_, _):
//            <#code#>
//        case .bind(_, _):
//            <#code#>
//        }
//    }
//}

/*
 
 Exercise 5.5
 
 Derivatives have a slightly more complicated relationship with multplication. It is not true that derivatives distribute over multiplication, but they do something close: D(f * g) = D(f) * g + f * D(g). Use this fact to implement the .mul case in the switch you defined above.
 
 */

//func D(_ variable: String) -> (Expr) -> Expr {
//    return { expr in
//        switch expr {
//        case .int:
//            return .int(0)
//        case .var(let name):
//            guard name == variable else { return .int(0) }
//            return .int(1)
//        case let .add(lhs, rhs):
//            return D(variable)(lhs) + D(variable)(rhs)
//        case let .mul(lhs, rhs):
//            return D(variable)(lhs) * rhs + D(variable)(rhs) * lhs
//        case .bind(_, _):
//            <#code#>
//        }
//    }
//}

/*
 
 Exercise 5.5
 
 Finally, derivatives have an even more complicated relationship with let-bindings: D(f >>> g) = D(f) * (f >>> D(g)), where here we are using >>> as a shorthand to represent the idea that let-bindings are essentially function composition. It’s a lot to take in, but what this is saying is that you take the derivative of the expression you are binding D(f), multiply that with the derivative of the subexpression that uses the binding D(g) pre-composed with the binding f >>> D(g). Use this fact to implement the .bind case in the switch you defined above.
 
 If you can solve these exercises, you’ve essentially done a semester’s worth of calculus!
 
 */

func D(_ variable: String) -> (Expr) -> Expr {
    return { expr in
        switch expr {
        case .int:
            return .int(0)
        case .var(let name):
            guard name == variable else { return .int(0) }
            return .int(1)
        case let .add(lhs, rhs):
            return D(variable)(lhs) + D(variable)(rhs)
        case let .mul(lhs, rhs):
            return D(variable)(lhs) * rhs + D(variable)(rhs) * lhs
        case let .bind(bindings, scoped):
            // what to do with multiple bindings?
            // I DON'T KNOW!
            var dfs: [Expr] = []
            var dfout: Expr? = nil
            for (_, bound) in bindings {
                let Df = D(variable)(bound)
                dfs.append(Df)
                if let olddfout = dfout {
                    dfout = olddfout * Df
                } else {
                    dfout = Df
                }
            }
            let fDg = Expr.bind(bindings, in: D(variable)(scoped))
            guard let unwrappeddfout = dfout else { fatalError() }
            return unwrappeddfout * fDg
        }
    }
}

/*
 
 Exercise 6.
 
 Use the D function defined above to differentiate some expressions.

 */

print(simplify(D("x")("x" * "x")))
print(simplify(D("x")("x" * "x" * "x")))
print(D("x")(2 * "x"))
 
//: [Next](@next)
