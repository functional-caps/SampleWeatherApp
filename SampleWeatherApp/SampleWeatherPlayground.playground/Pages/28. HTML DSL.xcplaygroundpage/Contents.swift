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

func render(_ node: Node) -> String {
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

print(render(pf))

func reverse(_ node: Node) -> Node {
    switch node {
    case .text(let value): return .text(String(value.reversed()))
    case let .el("img", attrs, children):
        return .el("img", attrs + [("style", "transform: scaleX(-1)")], children)
    case let .el(tag, attrs, children):
        return .el(tag, attrs, children.reversed().map(reverse))
    }
}

import WebKit

let webView = WKWebView(frame: .init(x: 0, y: 0, width: 320, height: 480))
webView.loadHTMLString(render(reverse(pf)), baseURL: nil)

import PlaygroundSupport

PlaygroundPage.current.liveView = webView

/*
 
 Exercise 1.
 
 Our render function currently prints an extra space when attributes aren’t present: "<header ></header>". Fix the render function so that render(header([])) == "<header></header>".
 
 */

print(render(header([])))

 /*
 
 Exercise 2.
 
 HTML specifies a number of “void elements” (elements that have no closing tag). This includes the img element in our example. Update the render function to omit the closing tag on void elements.
 
 */

print(render(header([])))

/*

 Exercise 3.
 
 Our render function is currently unsafe: text node content isn’t escaped, which means it could be susceptible to cross-site scripting attacks. Ensure that text nodes are properly escaped during rendering.
 
 */

print(render("\"asdasdasdasdasda\""))

/*

 Exercise 4.
 
 Ensure that attribute nodes are properly escaped during rendering.
 
 */

print(render(a([href("/about")], ["Learn more"])))

/*

 Exercise 5.
 
 Write a function redacted, which transforms a Node and its children, replacing all non-whitespace characters with a redacted character: █.
 
 */

func redacted(_ node: Node) -> Node {
    switch node {
    case .text(let value):
        return .text(String(value.map { elem -> Character in
            guard elem.isWhitespace else { return "█" }
            return elem
        }))
    case let .el(tag, attrs, children):
        return .el(tag, attrs, children.map(redacted))
    }
}

// TODO: FINISH!

print(render(redacted(pf)))

/*

 Exercise 6.
 
 Write a function removingStyles, which removes all style nodes and attributes.
 
 */





/*

 Exercise 7.
 
 Write a function removingScripts, which removes all script nodes and attributes with the on prefix (like onclick).
 
 */





/*

 Exercise 8.
 
 Write a function plainText, which transforms HTML into human-readable text, which might be useful for rendering plain-text emails from HTML content.
 
 */





/*

 Exercise 9.
 
 One of the most popular way of rendering HTML is to use a templating language (Swift, for example, has Stencil). What are some of the pros and cons of using a templating language over a DSL.
 
 */

//: [Next](@next)
