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



/*

 Exercise 2.

 Translate the Snapshottable protocol into a Snapshotting struct. How do you capture the associated type constraint?
 
 
 */



/*
 
 Exercise 3.
 
 Translate each conformance of Diffable into a witness value on Diffing.
 
 String
 UIImage
 
 */



/*
 
 Exercise 4.
 
 Translate the Snapshottable protocol into a Snapshotting struct. How do you capture the associated type constraint?
 
 
 */



/*
 
 Exercise 5.
 
 Translate each conformance of Snapshottable into a witness value on Snapshotting.
 
 String
 UIImage
 CALayer
 UIView
 UIViewController
 
 
 */



/*
 
 Exercise 6.
 
 Translate the assertSnapshot generic algorithm to take an explicit Snapshotting witness.
 
 */




//: [Next](@next)
