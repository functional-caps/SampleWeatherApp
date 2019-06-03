//: [Previous](@previous)

import Foundation
import XCTest
import UIKit

protocol Snapshotable {
    associatedtype Snapshot: Diffable
    var snapshot: Snapshot { get }
}

protocol Diffable {
    static func diff(old: Self, new: Self) -> [XCTAttachment]
    static func from(data: Data) -> Self
    var data: Data { get }
    var `extension`: String { get }
}

extension UIImage: Diffable {
    static func from(data: Data) -> Self {
        return self.init(data: data, scale: UIScreen.main.scale)!
    }
    
    static func diff(old: UIImage, new: UIImage) -> [XCTAttachment] {
        return [] // here comes the Diff helper that pointfree introduced
    }
    
    var data: Data {
        return pngData()!
    }
    
    var `extension`: String {
        return "png"
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

extension UIView: Snapshotable {
    var snapshot: UIImage {
        return layer.snapshot
    }
}

extension UIViewController: Snapshotable {
    var snapshot: UIImage {
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
    
    static func diff(old: String, new: String) -> [XCTAttachment] {
        guard let difference = Diff.lines(old, new) else { return [] }
        return [XCTAttachment(string: difference)]
    }
    
    static func from(data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
    
    var `extension`: String {
        return "txt"
    }
}

extension String: Snapshotable {
    var snapshot: String {
        return self
    }
}





//: [Next](@next)
