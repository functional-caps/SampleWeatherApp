//: [Previous](@previous)

import Foundation
import XCTest

enum Diff {
    static func lines(_ old: String, _ new: String) -> String? {
        return "tmp"
    }
}

struct Diffing<A> {
    let diff: (A, A) -> (String, [XCTAttachment])?
    let from: (Data) -> A
    let data: (A) -> Data
}

extension Diffing where A == String {
    static let lines = Diffing(
        diff: { old, new in
            guard let difference = Diff.lines(old, new) else { return nil }
            return ("Diff:\n\(difference)" , [XCTAttachment(string: difference)])
        },
        from: { String(decoding: $0, as: UTF8.self) },
        data: { Data($0.utf8) }
    )
}

struct Snapshotting<A, Snapshot> {
    let diffing: Diffing<Snapshot>
    let pathExtension: String
    let snapshot: (A) -> Snapshot
}

extension Snapshotting where A == String, Snapshot == String {
    static let lines = Snapshotting(
        diffing: .lines,
        pathExtension: "txt",
        snapshot: { $0 }
    )
}

func snapshotDirectoryUrl(file: StaticString) -> URL {
    let fileUrl = URL(fileURLWithPath: "\(file)")
    let directoryUrl = fileUrl
        .deletingLastPathComponent()
        .appendingPathComponent("__Snapshots__")
        .appendingPathComponent(fileUrl.deletingPathExtension().lastPathComponent)
    try! FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
    return directoryUrl
}

func snapshotUrl(file: StaticString, function: String) -> URL {
    return snapshotDirectoryUrl(file: file)
        .appendingPathComponent(String(function.dropLast(2)))
}

class SnapshotTestCase: XCTestCase {
    var record = false
    
    func assertSnapshot<V, Snapshot>(
        matching value: V,
        as witness: Snapshotting<V, Snapshot>,
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line) {
        
        let snapshot = witness.snapshot(value)
        let referenceUrl = snapshotUrl(file: file, function: function)
            .appendingPathExtension(witness.pathExtension)
        
        if !self.record, let referenceData = try? Data(contentsOf: referenceUrl) {
            let reference = witness.diffing.from(referenceData)
            guard let (failure, attachments) = witness.diffing.diff(reference, snapshot) else { return }
            XCTFail(failure, file: file, line: line)
            XCTContext.runActivity(named: "Attached failure diff") { activity in
                attachments
                    .forEach { image in activity.add(image) }
            }
        } else {
            try! witness.diffing.data(snapshot).write(to: referenceUrl)
            XCTFail("Recorded: …\n\"\(referenceUrl.path)\"", file: file, line: line)
        }
    }
}

extension Diffing where A == UIImage {
    static let image = Diffing(
        diff: { _,_ in nil }, // here comes the Diff helper that pointfree introduced
        from: { UIImage(data: $0, scale: UIScreen.main.scale)! },
        data: { $0.pngData()! }
    )
}

extension Snapshotting where A == UIImage, Snapshot == UIImage {
    static let image: Snapshotting<UIImage, UIImage> = Snapshotting(
        diffing: .image,
        pathExtension: "png",
        snapshot: { $0 }
    )
}

extension Snapshotting where A == CALayer, Snapshot == UIImage {
    
    static let image: Snapshotting = Snapshotting<UIImage, UIImage>.image.pullback { layer in
        UIGraphicsImageRenderer(size: layer.bounds.size)
            .image { ctx in layer.render(in: ctx.cgContext) }
    }
    
//    static let image: Snapshotting<CALayer, UIImage> = Snapshotting(
//        diffing: .image,
//        pathExtension: "png",
//        snapshot: { layer in
//            UIGraphicsImageRenderer(size: layer.bounds.size)
//                .image { ctx in layer.render(in: ctx.cgContext) }
//        }
//    )
    
}
extension Snapshotting where A == UIView, Snapshot == UIImage {
    
    static let image: Snapshotting =
        Snapshotting<CALayer, UIImage>.image.pullback { view in
            view.layer
        }
    
//    static let image: Snapshotting<UIView, UIImage> = Snapshotting(
//        diffing: .image,
//        pathExtension: "png",
//        snapshot: { view in
//            Snapshotting<CALayer, UIImage>.image.snapshot(view.layer)
//        }
//    )
}

extension Snapshotting where A == UIViewController, Snapshot == UIImage {
    
    static let image: Snapshotting<UIViewController, UIImage> =
        Snapshotting<UIView, UIImage>.image.pullback { vc in vc.view }
    
//    static let image: Snapshotting<UIViewController, UIImage> = Snapshotting(
//        diffing: .image,
//        pathExtension: "png",
//        snapshot: { vc in
//            Snapshotting<UIView, UIImage>.image.snapshot(vc.view)
//        }
//    )
}

extension Snapshotting {
    func pullback<A0>(_ f: @escaping (A0) -> A)
        -> Snapshotting<A0, Snapshot> {
        return Snapshotting<A0, Snapshot>(
            diffing: self.diffing,
            pathExtension: self.pathExtension,
            snapshot: { a0 in self.snapshot(f(a0)) }
        )
    }
}

extension Snapshotting where A == UIView, Snapshot == String {
    
    static let recursiveDescription: Snapshotting =
        Snapshotting<String, String>.lines.pullback { view in
            view.setNeedsLayout()
            view.layoutIfNeeded()
            return (view.perform(Selector(("recursiveDescription")))?
                .takeUnretainedValue() as! String)
                .replacingOccurrences(of: "0x............", with: "", options: [.regularExpression], range: nil) // strip adresses

    }
    
//    static let recursiveDescription = Snapshotting(
//        diffing: .lines,
//        pathExtension: "txt",
//        snapshot: { view in
//            view.setNeedsLayout()
//            view.layoutIfNeeded()
//            return (view.perform(Selector(("recursiveDescription")))?
//                .takeUnretainedValue() as! String)
//                .replacingOccurrences(of: "0x............", with: "", options: [.regularExpression], range: nil) // strip adresses
//            }
//    )
}

extension Snapshotting where A == UIViewController, Snapshot == String {
    static let recursiveDescription: Snapshotting =
        Snapshotting<UIView, String>.recursiveDescription.pullback { $0.view }
}

/*
 
 Exercises
 Take our witness-oriented library and define some interesting strategies! Think about your own code base and specialized Snapshotting (and Diffing) instances you can define. Here are some suggestions to get you started!
 
 Define a dump strategy on Snapshotting<Any, String> that uses the output of Swift’s dump function. You can reuse logic from the recursiveDescription strategy to remove occurrences of memory addresses.
 
 */

struct StringLogger: TextOutputStream {
    
    private(set) var content: String = ""
    
    mutating func write(_ string: String) {
        content.append(contentsOf: string)
    }
    
}

extension Snapshotting where A == Any, Snapshot == String {
    static let dumping: Snapshotting = Snapshotting<Any, String>(
        diffing: .lines,
        pathExtension: "txt",
        snapshot: { object in
            var tos = StringLogger()
            dump(object, to: &tos)
            return tos.content
        }
    )
}

print(Snapshotting.dumping.snapshot(Snapshotting.dumping))

/*
 
 Define a Snapshotting<URLRequest, String> strategy that snapshots a raw HTTP request, pretty-printing the method, headers, and body of the request.
 
 */

extension Snapshotting where A == URLRequest, Snapshot == String {
    
    static let http: Snapshotting = Snapshotting<URLRequest, String>(
        diffing: .lines,
        pathExtension: "txt",
        snapshot: { (request: URLRequest) in
            let method = request.httpMethod ?? "unknown"
            let headers = request.allHTTPHeaderFields?
                .map { "\($0.0) : \($0.1)" }
                .joined(separator: "\n") ?? "-"
            let body = request.httpBody
                .flatMap { String(data: $0, encoding: .utf8) } ?? "-"
            return """
Method:
    \(method)
Headers:
    \(headers)
Body:
    \(body)
"""
        }
    )
}

let url = URL(string: "http://example.com")!
print(Snapshotting.http.snapshot(URLRequest(url: url)))

/*
 
 Define a Snapshotting<NSAttributedString, UIImage> strategy that snapshots images of attributed strings.
 
 */

extension Snapshotting
where A == NSAttributedString, Snapshot == UIImage {
    
    static let image: Snapshotting = Snapshotting<UIView, UIImage>.image
        .pullback { string in
        let label = UILabel()
        label.attributedText = string
        label.sizeToFit()
        return label
    }
}

let string = NSAttributedString(
    string: "hello world",
    attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]
)

Snapshotting<NSAttributedString, UIImage>.image.snapshot(string)

/*
 
 Define a Snapshotting<NSAttributedString, String> strategy that snapshots HTML representations of attributed strings.
 
 */

extension Snapshotting
where A == NSAttributedString, Snapshot == String {
    
    static let html: Snapshotting =
        Snapshotting<NSAttributedString, String>(
        diffing: .lines,
        pathExtension: "txt",
        snapshot: { string in
            let data = try! string.data(
                from: NSRange(location: 0, length: string.length),
                documentAttributes: [.documentType : NSAttributedString.DocumentType.html]
                )
            return String(data: data, encoding: .utf8)!
        }
    )
}

let string2 = NSAttributedString(
    string: "hello world",
    attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]
)

print(Snapshotting<NSAttributedString, String>.html.snapshot(string))


//: [Next](@next)
