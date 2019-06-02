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

typealias IndexedLine = (Int, String.SubSequence)

enum Diff {
    
    private static func toIndexedLines(_ string: String) -> [IndexedLine] {
        let lines = string.split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
        var linesWithIndices: [IndexedLine] = []
        for (index, line) in lines.enumerated() {
            linesWithIndices.append((index, line))
        }
        return linesWithIndices
    }
    
    // This is step 1. and 2. from https://bramcohen.livejournal.com/73318.html
    private static func identifyMatchingPrefixAndSuffix(
        firstLines: [IndexedLine], secondLines: [IndexedLine]
    ) -> (prefix: [(IndexedLine, IndexedLine)], suffix: [(IndexedLine, IndexedLine)],
          restFirst: [IndexedLine], restSecond: [IndexedLine]) {
        // Step 1 from https://bramcohen.livejournal.com/73318.html
        let commonLinesStart = zip(firstLines, secondLines)
            .prefix { firstLine, secondLine -> Bool in firstLine == secondLine }
        
        let restFirstStart = firstLines[commonLinesStart.count...]
        let restSecondStart = secondLines[commonLinesStart.count...]
        
        // Step 2 from https://bramcohen.livejournal.com/73318.html
        let commonLinesEnd = zip(restFirstStart.reversed(),
                                 restSecondStart.reversed())
            .prefix { firstLine, secondLine -> Bool in firstLine == secondLine }
        
        let restFirst = Array(restFirstStart.reversed()[commonLinesStart.count...].reversed())
        let restSecond = Array(restSecondStart.reversed()[commonLinesStart.count...].reversed())

        return (prefix: commonLinesStart, suffix: commonLinesEnd,
                restFirst: restFirst, restSecond: restSecond)
    }
    
    private static func findUnique<T>(_ lines: [T], comparator: (T, T) -> Bool)
        -> (unique: [T], rest: [T]) {
            var unique: [T] = []
            var rest: [T] = []
            for line in lines {
                if let index = unique.firstIndex(where: { comparator($0, line) }) {
                    let previousLine = unique.remove(at: index)
                    rest.append(previousLine)
                    rest.append(line)
                    } else if rest.contains(where: { comparator($0, line) }) {
                    rest.append(line)
                } else {
                    unique.append(line)
                }
            }
            return (unique: unique, rest: rest)
    }
    
    private static func findCrossUniqueLines(
        _ uniqueFromFirst: [IndexedLine], _ second: [IndexedLine]
    ) -> (unique: [IndexedLine], rest: [IndexedLine]) {
        var unique: [IndexedLine] = []
        var rest: [IndexedLine] = []
        for line in uniqueFromFirst {
            if second.contains(where: { $0.1 == line.1 }) {
                if let index = unique.firstIndex(where: { $0.1 == line.1 }) {
                    unique.remove(at: index)
                }
                rest.append(line)
            } else {
                unique.append(line)
            }
        }
        return (unique: unique, rest: rest)
    }
    
    private static func matchBothSides(
        _ first: [IndexedLine], _ second: [IndexedLine]
    ) -> (firstUnique: [IndexedLine], secondUnique: [IndexedLine],
          doublePaired: [(IndexedLine, IndexedLine)]) {
            var firstUnique: [IndexedLine] = []
            var secondUnique: [IndexedLine] = []
            var doublePaired: [(IndexedLine, IndexedLine)] = []
            for line in first {
                if let secondLine = second.first(where: { $0.1 == line.1 }) {
                    doublePaired.append((line, secondLine))
                } else {
                    firstUnique.append(line)
                }
            }
            for line in second {
                if let firstLine = first.first(where: { $0.1 == line.1 }) {
                    continue //doublePaired.append((firstLine, line))
                } else {
                    secondUnique.append(line)
                }
            }
            doublePaired
            return (firstUnique: firstUnique, secondUnique: secondUnique, doublePaired: doublePaired)
    }
    
    private static func LCS(_ values: [Int]) -> [Int] {
        
        struct Entry {
            let value: Int
            let backtrack: [Entry?]
        }
        
        typealias Stack = [Entry]
        var stacks: [Stack] = []
        
        for value in values {
            var inserted = false
            for (index, var stack) in stacks.enumerated() {
                if let first = stack.first, first.value > value {
                    var backtrack: [Entry?] = []
                    if index != 0 {
                        backtrack = [stacks[index - 1].first]
                    }
                    stack.insert(Entry(value: value, backtrack: backtrack), at: 0)
                    stacks[index] = stack
                    inserted = true
                    break
                }
            }
            if !inserted {
                stacks.append([Entry(value: value, backtrack: [stacks.last?.first])])
            }
        }
        
        let toPrint = stacks.map { $0.map { $0.value } }
        
        print(toPrint)
        
        var entry: Entry? = stacks.last?.first
        var result: [Int] = []
        while let current = entry {
            result.append(current.value)
            entry = current.backtrack.first?.flatMap { $0 }
        }
        
        result.reverse()
        
        return result
    }
    
    static func diff(first: String, second: String) -> String? {
        
        let firstLines = toIndexedLines(first)
        let secondLines = toIndexedLines(second)
        
        print(firstLines)
        
        let (prefix, suffix, restFirst, restSecond) =
            identifyMatchingPrefixAndSuffix(firstLines: firstLines, secondLines: secondLines)
        
        // Step 3 from https://bramcohen.livejournal.com/73318.html
        
        //// Find all lines which occur exactly once on both sides
        
        let (potentiallyUniqueFirst, potentiallyDuplicateFirst) = findUnique(restFirst, comparator: { $0.1 == $1.1 })
        let (potentiallyUniqueSecond, potentiallyDuplicateSecond) = findUnique(restSecond, comparator: { $0.1 == $1.1 })
        
        //// now potentiallyUnique are lines that are only once on particular side
        
        let (uniqueFirst, actuallyDuplicateFirst) =
            findCrossUniqueLines(potentiallyUniqueFirst, potentiallyDuplicateSecond)
        let (uniqueSecond, actuallyDuplicateSecond) =
            findCrossUniqueLines(potentiallyUniqueSecond, potentiallyDuplicateFirst)
        
        //// match unique
        
        let duplicateFirst = potentiallyDuplicateFirst + actuallyDuplicateFirst
        let duplicateSecond = potentiallyDuplicateSecond + actuallyDuplicateSecond
        
        let (firstUnique, secondUnique, doublePaired) = matchBothSides(uniqueFirst, uniqueSecond)
        
        let sortedPaired =  doublePaired.sorted { firstPair, secondPair -> Bool in
            firstPair.1.0 < secondPair.1.0
        }
        
        
        let sequenceToLCS = sortedPaired.map { $0.0.0 }

//        print(firstUnique)
//        print(duplicateFirst)
//        print(secondUnique)
//        print(duplicateSecond)
//        print(sortedPaired)
//        print(sequenceToLCS)

        //// do longest common subsequence on those lines, matching them up
        
        let lcs = LCS(sequenceToLCS)
        
        let filteredPaired = sortedPaired.filter { lcs.contains($0.0.0) }
        
        print(filteredPaired)
        
//        let lcsedPaired = sortedPaired.sorted {
//            let indexFirst = $0.0.0
//            let indexSecond = $1.0.0
//            if let index1 = lcs.firstIndex(of: indexFirst),
//                let index2 = lcs.firstIndex(of: indexSecond) {
//                return index1 < index2
//            } else if lcs.contains(indexSecond) {
//                return true
//            }
//            return false
//        }
        
//        let lcs = LCS([9, 4, 6, 12, 8, 7, 1, 5, 10, 11, 3, 2, 13])
        
        print(lcs)
//        print(lcsedPaired)
        
        var index = 0
        for line in prefix {
            print("= \(line.1.1)")
            index = line.1.0
        }
        
//        print(index + 1)
        
        for line in suffix {
            print("= \(line.1.1)")
        }
        
        // Step 4 from https://bramcohen.livejournal.com/73318.html
        
//        let restFirst = restFirstStart.reversed()[commonLinesEnd.count...].reversed()
//        let restSecond = restSecondStart.reversed()[commonLinesEnd.count...].reversed()
        
        
        
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
