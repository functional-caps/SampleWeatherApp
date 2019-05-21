//: [Previous](@previous)

import Foundation

enum Node {
    indirect case el(String, [(String, String)], [Node])
    case text(String)
}

extension Node: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .text(value)
    }
}

func header(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("header", attrs, children)
}

func header(_ children: [Node]) -> Node {
    return .el("header", [], children)
}

func h1(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("h1", attrs, children)
}

func h1(_ children: [Node]) -> Node {
    return .el("h1", [], children)
}

func p(_ attrs: [(String, String)] = [], _ children: [Node]) -> Node {
    return .el("p", attrs, children)
}

func a(_ attrs: [(String, String)] = [], _ children: [Node]) -> Node {
    return .el("a", attrs, children)
}

func ul(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("ul", attrs, children)
}

func ul(_ children: [Node]) -> Node {
    return .el("ul", [], children)
}

func li(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("li", attrs, children)
}

func li(_ children: [Node]) -> Node {
    return .el("li", [], children)
}

func img(_ attrs: [(String, String)] = []) -> Node {
    return .el("img", attrs, [])
}

func id(_ value: String) -> (String, String) {
    return ("id", value)
}

func href(_ value: String) -> (String, String) {
    return ("href", value)
}

func src(_ value: String) -> (String, String) {
    return ("src", value)
}

func width(_ value: Int) -> (String, String) {
    return ("width", "\(value)")
}

func height(_ value: Int) -> (String, String) {
    return ("height", "\(value)")
}

let pf = header([
    h1(["Point-Free"]),
    p([id("blurb")], [
        "functional in Swift. ",
        a([href("/about")], ["Learn more"]),
        "!"
        ]),
    img([src("https://example.com/img"), width(64), height(64)])
    ])

func render(_ node: Node?) -> String {
    guard let node = node else { return "" }
    switch node {
    case .text(let text):
        return text.replacingOccurrences(of: "\"", with: "\\\"")
    case let .el(tag, attrs, children):
        var formattedAttrs: String = ""
        if attrs.count > 0 {
            formattedAttrs = " " + attrs
                .map { key, value in "\(key)=\\\"\(value)\\\"" }
                .joined(separator: " ")
        }
        if children.count > 0 {
            let formattedChildren = children.map(render).joined()
            return "<\(tag)\(formattedAttrs)>\(formattedChildren)</\(tag)>"
        } else {
            return "<\(tag)\(formattedAttrs)/>"
        }
    }
}

func reverse(_ node: Node) -> Node {
    switch node {
    case .text(let value): return .text(String(value.reversed()))
    case let .el("img", attrs, children):
        return .el("img", attrs + [("style", "transform: scaleX(-1)")], children)
    case let .el(tag, attrs, children):
        return .el(tag, attrs, children.reversed().map(reverse))
    }
}

let name = "Blob"
print(
    render(
        header([
            h1([.text(name)])
        ])
    )
)

func greet(name: String) -> Node {
    return header([h1([.text(name.uppercased())])])
}

print(render(greet(name: "Blob")))

struct User {
    let name: String
    let isAdmin: Bool
}

func adminDetail(user: User) -> [Node] {
    guard user.isAdmin else { return [] }
    return [header([
        h1([.text("Welcome admin: \(user.name)")])
    ])]
}

func render(_ nodes: [Node]) -> String {
    return nodes.map(render).joined()
}

print(render(adminDetail(user: User(name: "Blob Jr.", isAdmin: false))))

print(render(adminDetail(user: User(name: "Blob Sr.", isAdmin: true))))

func userItem(_ name: String) -> Node {
    return li([.text(name)])
}

func users(_ names: [String]) -> Node {
    return ul(names.map(userItem))
}

print(render(users(["Blob Jr.", "Blob", "Blob Sr."])))

/*
 
 Exercise 1.
 
 In this episode we expressed a lot of HTML “views” as just plain functions from some data type into the Node type. In past episodes we saw that functions (A) -> B have both a map and contramap defined, the former corresponding to post-composition and the latter pre-composition. What does map and contramap represent in the context of an HTML view (A) -> Node?
 
 */




/*

 Exercise 2.
 
 When building a website you often realize that you want to be able to reuse an outer “shell” of a view, and plug smaller views into it. For example, the header, nav and footer would consist of the “shell”, and then the content of your homepage, about page, contact page, etc. make up the inside. This is a kind of “view composition”, and most templating languages provide something like it (Rails calls it layouts, Stencil calls it inheritance).
 
 Formulate what this form of view composition looks like when you think of views as just functions of the form (A) -> Node.
 
 */




/*
 
 Exercise 3.

 In previous episodes on this series we have discussed the <> (diamond) operator. We have remarked that this operator comes up anytime we have a nice way of combining two values of the same type together into a third value of the same type, i.e. functions of the form (A, A) -> A.
 
 Given two views of the form v, w: (A) -> [Node], it is possible to combine them into one view. Define the diamond operator that performs this operation: <>: ((A) -> [Node], (A) -> [Node]) -> (A) -> [Node].
 
 */




/*
 
 Exercise 4.1

 Right now any node is allowed to be embedded inside any other node, even though certain HTML semantics forbid that. For example, the list item tag <li> is only allowed to be embedded in unordered lists <ul> and ordered lists <ol>. We can’t enforce this property through the Node type, but we can do it through the functions we define for constructing tags. The technique uses something known as phantom types, and it’s similar to what we did in our Tagged episode. Here is a series of exercises to show how it works:
 
 First define a new ChildOf type. It’s a struct that simply wraps a Node value, but most importantly it has a generic <T>. We will use this generic to control when certain nodes are allowed to be embedded inside other nodes.
 
 */




/*
 
 Exercise 4.2

 Define two new types, Ol and Ul, that will act as the phantom types for ChildOf. Since we do not care about the contents of these types, they can just be simple empty enums.
 
 */




/*
 
 Exercise 4.3

 Define a new protocol, ContainsLi, and make both Ol and Ul conform to it. Again, we don’t care about the contents of this protocol, it is only a means to tag Ol and Ul as having the property that they are allowed to contain <li> elements.
 
 */




/*
 
 Exercise 4.4

 Finally, define three new tag functions ol, ul and li that allow you to nest <li>’s inside <ol>’s and <ul>’s but prohibit you from putting li’s in any other tags. You will need to use the types ChildOf<Ol>, ChildOf<Ul> and ContainsLi to accomplish this.
 
 */



//: [Next](@next)
