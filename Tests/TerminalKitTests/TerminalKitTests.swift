import XCTest
@testable import TerminalKit

final class TerminalKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TerminalKit().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
