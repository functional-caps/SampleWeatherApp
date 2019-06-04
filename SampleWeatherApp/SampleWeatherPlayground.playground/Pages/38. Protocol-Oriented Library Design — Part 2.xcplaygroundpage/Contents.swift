//: [Previous](@previous)

import Foundation
import XCTest
import UIKit

protocol Snapshotable {
    associatedtype Snapshot: Diffable
    var snapshot: Snapshot { get }
    static var pathExtension: String { get }
}

extension Snapshotable {
    static var pathExtension: String { return "png" }
}

protocol Diffable {
    static func diff(old: Self, new: Self) -> (String, [XCTAttachment])?
    static func from(data: Data) -> Self
    var data: Data { get }
}

extension UIImage: Diffable {
    static func from(data: Data) -> Self {
        return self.init(data: data, scale: UIScreen.main.scale)!
    }
    
    static func diff(old: UIImage, new: UIImage) -> (String, [XCTAttachment])? {
        return nil // here comes the Diff helper that pointfree introduced
    }
    
    var data: Data {
        return pngData()!
    }
}

extension CALayer: Snapshotable {
    var snapshot: UIImage {
        return UIGraphicsImageRenderer(size: bounds.size)
            .image { ctx in self.render(in: ctx.cgContext) }
    }
}

extension UIImage: Snapshotable {
    var snapshot: UIImage {
        return self
    }
}

extension Snapshotable where Snapshot == String {
    static var pathExtension: String { return "txt" }
}

extension UIView: Snapshotable {
//    var snapshot: UIImage {
//        return layer.snapshot
//    }
    
    var snapshot: String {
        return (self.perform(Selector(("recursiveDescription")))?
            .takeUnretainedValue() as! String)
            .replacingOccurrences(of: "0x............", with: "", options: [.regularExpression], range: nil) // strip adresses
    }
}

extension UIViewController: Snapshotable {
//    var snapshot: UIImage {
//        return view.snapshot
//    }
    var snapshot: String {
        return view.snapshot
    }
}

enum Diff {
    static func lines(_ old: String, _ new: String) -> String? {
        return "tmp"
    }
}

extension String: Diffable {
    
    var data: Data {
        return Data(self.utf8)
    }
    
    static func diff(old: String, new: String) -> (String, [XCTAttachment])? {
        guard let difference = Diff.lines(old, new) else { return nil }
        return ("Diff:\n\(difference)" , [XCTAttachment(string: difference)])
    }
    
    static func from(data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
}

extension String: Snapshotable {
    var snapshot: String {
        return self
    }
    
    static var pathExtension: String {
        return "txt"
    }
}

let view = UIView()
print(view.snapshot)


/*
 
 Exercise 1.
 
 Using our series on protocol witnesses (part 1, part 2, part 3, part 4) as a guide, translate the Diffable protocol into a Diffing struct.
 
 */

struct Diffing<A> {
    let diff: (A, A) -> (String, [XCTAttachment])?
    let from: (Data) -> A
    let data: (A) -> Data
}

/*

 Exercise 2.

 Translate the Snapshottable protocol into a Snapshotting struct. How do you capture the associated type constraint?
 
 */

struct Snapshotting<Snapshot: Diffable, A> {
    let snapshot: (A) -> Snapshot
    let pathExtension: String
    
    init(snapshot: @escaping (A) -> Snapshot, pathExtension: String = "png") {
        self.snapshot = snapshot
        self.pathExtension = pathExtension
    }
}

extension Snapshotting where Snapshot == String {
    init(snapshot: @escaping (A) -> Snapshot) {
        self.snapshot = snapshot
        self.pathExtension = "txt"
    }
}

/*
 
 Exercise 3.
 
 Translate each conformance of Diffable into a witness value on Diffing.
 
 String
 UIImage
 
 */

let diffingString = Diffing(
    diff: { old, new in
        guard let difference = Diff.lines(old, new) else { return nil }
        return ("Diff:\n\(difference)" , [XCTAttachment(string: difference)])
    },
    from: { String(decoding: $0, as: UTF8.self) },
    data: { Data($0.utf8) }
)

let diffingUIImage = Diffing(
    diff: { _,_ in nil }, // here comes the Diff helper that pointfree introduced
    from: { UIImage(data: $0, scale: UIScreen.main.scale)! },
    data: { $0.pngData()! }
)

/*
 
 Exercise 4.
 
 Translate the Snapshottable protocol into a Snapshotting struct. How do you capture the associated type constraint?
 
 */

// same as exercise 4.

/*
 
 Exercise 5.
 
 Translate each conformance of Snapshottable into a witness value on Snapshotting.
 
 String
 UIImage
 CALayer
 UIView
 UIViewController
 
 */

let snapshottingString = Snapshotting(snapshot: { $0 })

let snapshottingUIImage = Snapshotting(snapshot: { $0 })

let snapshottingCALayer = Snapshotting(snapshot: { (layer: CALayer) in
    UIGraphicsImageRenderer(size: layer.bounds.size)
        .image { ctx in layer.render(in: ctx.cgContext) }
})

let snapshottingUIViewImage = Snapshotting(snapshot: { (view: UIView) in
    snapshottingCALayer.snapshot(view.layer)
})

let snapshottingUIViewText = Snapshotting(snapshot: { (view: UIView) in
    (view.perform(Selector(("recursiveDescription")))?
        .takeUnretainedValue() as! String)
        .replacingOccurrences(of: "0x............", with: "", options: [.regularExpression], range: nil) // strip adresses
})

let snapshottingUIViewControllerImage = Snapshotting(snapshot: { (vc: UIViewController) in
    return snapshottingUIViewImage.snapshot(vc.view)
})

let snapshottingUIViewControllerText = Snapshotting { (vc: UIViewController) in
    snapshottingUIViewText.snapshot(vc.view)
}

/*
 
 Exercise 6.
 
 Translate the assertSnapshot generic algorithm to take an explicit Snapshotting witness.
 
 */




//: [Next](@next)
