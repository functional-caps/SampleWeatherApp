//: [Previous](@previous)

import Foundation
import UIKit
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

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
}

struct Snapshotting<A, Snapshot> {
    let diffing: Diffing<Snapshot>
    let pathExtension: String
    let snapshot: (A) -> Parallel<Snapshot>
}

extension Snapshotting {
    init(diffing: Diffing<Snapshot>,
         pathExtension: String,
         snapshot: @escaping (A) -> Snapshot) {
        self.diffing = diffing
        self.pathExtension = pathExtension
        self.snapshot = { value in Parallel { $0(snapshot(value)) } }
    }
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
        
        let parallel = witness.snapshot(value)
        var snapshot: Snapshot!
        let loaded = expectation(description: "Loaded")
        parallel.run { value in
            snapshot = value
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        
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
}

extension Snapshotting where A == UIView, Snapshot == UIImage {
    
    static let image: Snapshotting =
        Snapshotting<CALayer, UIImage>.image.pullback { view in
            view.layer
    }
}

extension Snapshotting where A == UIViewController, Snapshot == UIImage {
    
    static let image: Snapshotting<UIViewController, UIImage> =
        Snapshotting<UIView, UIImage>.image.pullback { vc in vc.view }

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
    
    func asyncPullback<A0>(_ f: @escaping (A0) -> Parallel<A>) -> Snapshotting<A0, Snapshot> {
        return Snapshotting<A0, Snapshot>(
            diffing: self.diffing,
            pathExtension: self.pathExtension,
            snapshot: { (a0) -> Parallel<Snapshot> in
                return Parallel<Snapshot> { callback in
                    let parallelA = f(a0)
                    parallelA.run { a in
                        let parallelSnapshot = self.snapshot(a)
                        parallelSnapshot.run { snapshot in
                            callback(snapshot)
                        }
                    }
                }
        }
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
}

extension Snapshotting where A == UIViewController, Snapshot == String {
    static let recursiveDescription: Snapshotting =
        Snapshotting<UIView, String>.recursiveDescription.pullback { $0.view }
}


// HERE EPISODE STARTS

extension Snapshotting
where A == NSAttributedString, Snapshot == UIImage {
    static let image: Snapshotting = Snapshotting<UIView, UIImage>.image
        .pullback { string in
            let label = UILabel()
            label.attributedText = string
            label.numberOfLines = 0
            label.backgroundColor = .white
            label.frame.size = label.systemLayoutSizeFitting(
                CGSize(width: 300, height: 0),
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .defaultLow
            )
            return label
        }
}

let string = NSAttributedString(
    string: "elo", attributes: [.foregroundColor : UIColor.green]
)

Snapshotting.image.snapshot(string).run {
    _ = $0
    print($0)
}

/*

 Exercise 1.
 
 Write an .html strategy for snapshotting NSAttributedString. You will want to use the data(from:documentAttributes:) method on NSAttributedString with the NSAttributedString.DocumentType.html attribute to convert any attribtued string into an HTML document.
 
 */

extension Snapshotting
where A == NSAttributedString, Snapshot == String {
    
    static let html: Snapshotting = Snapshotting<String, String>.lines
        .pullback { (attributedString: NSAttributedString) in
            let data = try! attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: [.documentType : NSAttributedString.DocumentType.html]
            )
            return String(data: data, encoding: .utf8)!

        }
}

let string2 = NSAttributedString(
    string: "hello world",
    attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]
)

Snapshotting<NSAttributedString, String>.html.snapshot(string)
    .run { print($0) }

Snapshotting<NSAttributedString, String>.html.snapshot(string2)
    .run { print($0) }

 /*
 
 Exercise 2.
 
 Integrate the snapshot testing library into one of your projects, and write a snapshot test.
 
 */

// cannot do it here :(

/*
 
 Exercise 3.
 
 Create a custom, domain-specific snapshot strategy for one of your types.
 
 */

enum TryTypeSpecificError : Error {
    case derivedFromNil
    case unexpectedElementInTry
    case unexpectedErrorInTry
    case computationUndefinedInTry
    case unexpectedErrorType(originalErrorType: Error.Type)
}

enum TryTyped<Element, ErrorParam : Error> {
    
    case some(Element)
    case error(ErrorParam)
    
    public static func orThrow(_ closure: () throws -> Element) throws -> TryTyped {
        return try TryTyped(throwing: closure)
    }
    
    public static func orThrow(_ closure: @autoclosure () throws -> Element) throws -> TryTyped {
        return try TryTyped(throwing: closure)
    }
    
    public init?(_ closure: @autoclosure () throws -> Element) {
        do {
            self = try TryTyped(throwing: closure)
        } catch {
            return nil
        }
    }
    
    private init(throwing: () throws -> Element) throws {
        do {
            let result = try throwing()
            self = TryTyped(elem: result)
        } catch let error as ErrorParam {
            self = TryTyped(error: error)
        } catch {
            throw TryTypeSpecificError.unexpectedErrorType(originalErrorType: type(of: error))
        }
    }
    
    init(elem: Element) {
        self = .some(elem)
    }
    
    init(error: ErrorParam) {
        self = .error(error)
    }
    
    public var asPossibleError: ErrorParam? {
        get {
            return try? self.errorOrThrow()
        }
    }
    
    public func errorOrThrow() throws -> ErrorParam {
        guard case .error(let error) = self else { throw TryTypeSpecificError.unexpectedElementInTry }
        return error
    }
    
    func elementOrThrow() throws -> Element {
        guard case .some(let elem) = self else { throw TryTypeSpecificError.unexpectedErrorInTry }
        return elem
    }
    
    var asPossibleElement: Element? {
        return try? self.elementOrThrow()
    }
}

struct StringLogger: TextOutputStream {
    
    private(set) var content: String = ""
    
    mutating func write(_ string: String) {
        content.append(contentsOf: string)
    }
}

extension Snapshotting where A == Any, Snapshot == String {
    static let dumping: Snapshotting = Snapshotting<String, String>.lines
        .pullback { object in
            var tos = StringLogger()
            dump(object, to: &tos)
            return tos.content
        }
}


extension Snapshotting {
    
    static func dumpingStrategy<T, E: Error>() -> Snapshotting<TryTyped<T, E>, String> {
        return Snapshotting<Any, String>.dumping
            .pullback { (a: TryTyped<T, E>) -> Any in
                switch a {
                case .some(let elem): return elem
                case .error(let error): return error
                }
            }
    }
}

enum RandomError: Error { case random }

let try1 = TryTyped<Int, RandomError>(elem: 42)
let try2 = TryTyped<Int, RandomError>.init(error: .random)

let strategy: Snapshotting<TryTyped<Int, RandomError>, String> = Snapshotting<TryTyped<Int, RandomError>, String>.dumpingStrategy()

strategy.snapshot(try1).run { print($0) }

strategy.snapshot(try2).run { print($0) }

/*
 
 Exercise 4.
 
 Send us a pull request to add a snapshot strategy for a Swift standard library or cocoa data type that we haven’t yet implemented.
 
 */

import CoreBluetooth

let central = CBCentralManager(delegate: nil, queue: nil)

extension CBManagerState {
    var description: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        @unknown default: return "some new state that we do not know of"
        }
    }
}

extension Snapshotting where A == CBCentralManager, Snapshot == String {
    
    static let recursiveDescription: Snapshotting =
        Snapshotting<String, String>.lines
            .pullback { (manager: CBCentralManager) in
                let delegate = central.delegate
                    .map { "instance of \(type(of: $0))" } ?? "nil"
                return """
                CBCentralManager:
                - delegate: \(delegate)
                - isScanning: \(central.isScanning)
                - state: \(central.state.description)
                """
            }
}

Snapshotting<CBCentralManager, String>.recursiveDescription
    .snapshot(central).run { print($0) }

// now it's time to make it pull request!

//: [Next](@next)
