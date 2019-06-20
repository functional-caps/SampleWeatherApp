import SwiftSyntax

public final class Visitor: SyntaxVisitor {
    
    public private(set) var output: String = ""
    
    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        print("extension \(node.identifier.withoutTrivia()) {", to: &output)
        print("", to: &output)
        return .visitChildren
    }
    
    public override func visitPost(_ node: Syntax) {
        if node is EnumDeclSyntax {
            print("}", to: &output)
            print("", to: &output)
        }
    }
    
    public override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
        if let associatedValue = node.associatedValue {
            let propertyType = associatedValue.parameterList.count == 1
                ? "\(associatedValue.parameterList[0].type!)"
                : "(\(associatedValue.parameterList))"
            print("  var \(node.identifier): \(propertyType)? {", to: &output)
            print("    guard case let .\(node.identifier)(value) = self else { return nil }", to: &output)
            print("    return value", to: &output)
        } else if let parent = node.parent?.parent?.parent?.parent?.parent?.parent as? EnumDeclSyntax {
            print("  var \(node.identifier): \(parent.identifier)? {", to: &output)
            print("    guard case .\(node.identifier) = self else { return nil }", to: &output)
            print("    return self", to: &output)
        }
        print("  }", to: &output)
        print("", to: &output)
        //    let capitalizedIdentifier = "\(node.identifier)".capitalized
        let identifier = "\(node.identifier)"
        let capitalizedIdentifier = "\(identifier.first!.uppercased())\(identifier.dropFirst())"
        print("  var is\(capitalizedIdentifier): Bool {", to: &output)
        print("    return self.\(node.identifier) != nil", to: &output)
        print("  }", to: &output)
        print("", to: &output)
        return .skipChildren
    }
}

