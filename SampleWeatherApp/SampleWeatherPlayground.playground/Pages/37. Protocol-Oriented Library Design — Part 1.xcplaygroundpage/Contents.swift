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

/*
 
 Exercise 1.
 
 There’s one protocol requirement we missed: the fact that we hard-code the path extension of the snapshot reference to “png”. Move this requirement into our protocols. Which protocol does it belong to?
 */

// it belongs to Diffable protocol, because Diffable defines the data
// and its implementations will decide what format the data comes in

/*
 
 Exercise 2.
 
 Add a default implementation of path extension so that those conforming their own types to be Snapshottable do not need to declare "png" every time.
 
 */

extension Diffable {
    var `extension`: String { return "png" }
}

extension Snapshotable {
    var `extension`: String { return snapshot.extension }
}

/*
 
 Exercise 3.
 
 Showing the difference between two images is a matter of using a Core Image difference filter. Unfortunately, Apple provides no such API to show the difference between two strings. Implement a line diff algorithm to describe the difference between two strings in Swift.
 
 A popular, human-readable algorithm is called the “patience diff”. Here are some resources:
 
 Patience Diff, a brief summary, Patience Diff Advantages: a brief introduction and description of advantages by the author.
 
 diff.py, lcsmatch.py: one of the original implementations, in Python.
 
 Enumerating longest increasing subsequences and patience sorting: a paper that describes the algorithm.
 
 */

enum Diff {
    static func diff(first: String, second: String) -> String? {
        let firstLines = first.split(separator: "\n")
        let secondLines = first.split(separator: "\n")
        
        // Step 1 from https://bramcohen.livejournal.com/73318.html
        let commonLinesStart = zip(firstLines, secondLines)
            .prefix { firstLine, secondLine -> Bool in firstLine == secondLine }
        
        let restFirstStart = firstLines[commonLinesStart.count...]
        let restSecondStart = secondLines[commonLinesStart.count...]
        
        // Step 2 from https://bramcohen.livejournal.com/73318.html
        let commonLinesEnd = zip(firstLines.reversed(), secondLines.reversed())
            .prefix { firstLine, secondLine -> Bool in firstLine == secondLine }
        
        // Step 3 from https://bramcohen.livejournal.com/73318.html
        
        
        
        // Step 4 from https://bramcohen.livejournal.com/73318.html
        
        let restFirst = restFirstStart.reversed()[commonLinesEnd.count...].reversed()
        let restSecond = restSecondStart.reversed()[commonLinesEnd.count...].reversed()
        
        
        
        return nil
    }
}

let firstFilePath = Bundle.main.path(forResource: "first", ofType: "txt")!
let secondFilePath = Bundle.main.path(forResource: "second", ofType: "txt")!
let firstString = try! String(contentsOf: URL(fileURLWithPath: firstFilePath))
let secondString = try! String(contentsOf: URL(fileURLWithPath: secondFilePath))

print(firstString)
print(secondString)
print(String(describing: Diff.diff(first: firstString, second: secondString)))

//: [Next](@next)
