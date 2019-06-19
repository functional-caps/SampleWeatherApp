import Cocoa
import SwiftSyntax

let url = Bundle.main.url(forResource: "Enums", withExtension: "swift")!

let tree = try SyntaxTreeParser.parse(url)

final class Visitor: SyntaxVisitor {
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        print("extension \(node.identifier.withoutTrivia()) {")
        print("")
        return .visitChildren
    }
    
    override func visitPost(_ node: Syntax) {
        if node is EnumDeclSyntax {
            print("}")
            print("")
        }
    }
    
    override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
        if let associatedValue = node.associatedValue {
            let propertyType = associatedValue.parameterList.count == 1
                ? "\(associatedValue.parameterList[0].type!)"
                : "(\(associatedValue.parameterList))"
            print("  var \(node.identifier): \(propertyType)? {")
            print("    guard case let .\(node.identifier)(value) = self else { return nil }")
            print("    return value")
        } else if let parent = node.parent?.parent?.parent?.parent?.parent?.parent as? EnumDeclSyntax {
            print("  var \(node.identifier): \(parent.identifier)? {")
            print("    guard case .\(node.identifier) = self else { return nil }")
            print("    return self")
        }
        print("  }")
        print("")
        //    let capitalizedIdentifier = "\(node.identifier)".capitalized
        let identifier = "\(node.identifier)"
        let capitalizedIdentifier = "\(identifier.first!.uppercased())\(identifier.dropFirst())"
        print("  var is\(capitalizedIdentifier): Bool {")
        print("    return self.\(node.identifier) != nil")
        print("  }")
        print("")
        return .skipChildren
    }
}

let visitor = Visitor()

tree.walk(visitor)


enum Validated<Valid, Invalid> {
    case valid(Valid)
    case invalid([Invalid])
}

extension Validated {
    
    var valid: Valid? {
        guard case let .valid(value) = self else { return nil }
        return value
    }
    
    var invalid: [Invalid]? {
        guard case let .invalid(value) = self else { return nil }
        return value
    }
    
}

let validatedValues: [Validated<Int, String>] = [
    .valid(1),
    .invalid(["Failed"]),
    .valid(42)
]

validatedValues
    .compactMap { $0.valid }

/*
 
 Exercise 1.
 
 One problem with our enum property code generator is that it only handles enum cases with a single associated value. Update it to handle enum cases with no associated values. What type of value does this enum property return?
 
 */

let url1 = Bundle.main.url(forResource: "Exercise1", withExtension: "swift")!
let tree1 = try SyntaxTreeParser.parse(url1)
let visitor1 = Visitor()
tree1.walk(visitor1)

enum Optional<A> {
    case some(A)
    case none
}

extension Optional {
    
    var some: (A)? {
        guard case let .some(value) = self else { return nil }
        return value
    }
    
    var none: Optional? {
        guard case .none = self else { return nil }
        return self
    }
    
}

let optionalValues: [Optional<Int>] = [
    .some(1),
    .none,
    .some(42)
]

optionalValues
    .compactMap { $0.none }

optionalValues
    .compactMap { $0.some }
 
 /*
 
 Exercise 2.
 
 Update our code generator to handle enum cases with several associated values.
 
 */

let url2 = Bundle.main.url(forResource: "Exercise2", withExtension: "swift")!
let tree2 = try SyntaxTreeParser.parse(url2)
let visitor2 = Visitor()
tree2.walk(visitor2)

enum Multiple<A, B, C> {
    case zero
    case one(A)
    case two(B, A)
    case three(C, A, B)
}

extension Multiple {
    
    var zero: Multiple? {
        guard case .zero = self else { return nil }
        return self
    }
    
    var one: A? {
        guard case let .one(value) = self else { return nil }
        return value
    }
    
    var two: (B, A)? {
        guard case let .two(value) = self else { return nil }
        return value
    }
    
    var three: (C, A, B)? {
        guard case let .three(value) = self else { return nil }
        return value
    }
    
}

let multipleValues: [Multiple<Int, String, Float>] = [
    .zero,
    .one(1),
    .two("1", 1),
    .three(1.0, 1, "1")
]

multipleValues
    .compactMap { $0.zero }

multipleValues
    .compactMap { $0.one }

multipleValues
    .compactMap { $0.two }

multipleValues
    .compactMap { $0.three }

/*
 
 Exercise 3.
 
 Update our code generator to handle enum cases with labeled associated values. For example, we defined a Node enum in our episode on building a Swift HTML DSL:
 
 enum Node {
 case el(tag: String, attributes: [String: String], children: [Node])
 case text(String)
 }
 How might labels enhance our enum properties?
 
 */

let url3 = Bundle.main.url(forResource: "Exercise3", withExtension: "swift")!
let tree3 = try SyntaxTreeParser.parse(url3)
let visitor3 = Visitor()
tree3.walk(visitor3)

enum Node {
    case el(tag: String, attributes: [String: String], children: [Node])
    case text(String)
}

extension Node {
    
    var el: (tag: String, attributes: [String: String], children: [Node])? {
        guard case let .el(value) = self else { return nil }
        return value
    }
    
    var text: String? {
        guard case let .text(value) = self else { return nil }
        return value
    }
    
}

/*
 
 Exercise 4.
 
 After you add support for labeled enum cases, ensure that the code generator properly handles enum cases with a single, labeled value.
 
 */

let url4 = Bundle.main.url(forResource: "Exercise4", withExtension: "swift")!
let tree4 = try SyntaxTreeParser.parse(url4)
let visitor4 = Visitor()
tree4.walk(visitor4)

enum Node2 {
    case el(children: [Node])
    case text(String)
}

extension Node2 {
    
    var el: [Node]? {
        guard case let .el(value) = self else { return nil }
        return value
    }
    
    var text: String? {
        guard case let .text(value) = self else { return nil }
        return value
    }
    
}
