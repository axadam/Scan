import XCTest
@testable import Scan

final class ScanTests: XCTestCase {
    func testEager() {
        // Eager version
        let a = (1..<6).scan(0, +)
        let b = [0, 1, 3, 6, 10, 15]
        XCTAssertEqual(a, b)
    }
    
    func testLazy() {
        // Lazy version
        let a = Array((1...).lazy.scan(0, +).prefix(6))
        let b = [0, 1, 3, 6, 10, 15]
        XCTAssertEqual(a, b)
    }

    static var allTests = [
        ("testEager", testEager),
        ("testLazy", testLazy),
    ]
}
