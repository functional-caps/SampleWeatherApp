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

// Gone up to 28:34 - multiple witnesses

//: [Next](@next)
