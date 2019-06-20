import XCTest
import SwiftSyntax
import SnapshotTesting
@testable import EnumProperties

extension Snapshotting where Value == URL, Format == String {
    static var enumProperties: Snapshotting = {
        var snapshotting: Snapshotting = Snapshotting<String, String>.lines
            .pullback { url in
                let tree = try! SyntaxTreeParser.parse(url)
                let visitor = Visitor()
                tree.walk(visitor)
                return visitor.output
            }
        snapshotting.pathExtension = "swift"
        return snapshotting
    }()
}

final class EnumPropertiesTests: XCTestCase {
    func testExample() throws {
        let url = URL(fileURLWithPath: String(#file))
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("Enums.swift")
        assertSnapshot(matching: url, as: .enumProperties)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
