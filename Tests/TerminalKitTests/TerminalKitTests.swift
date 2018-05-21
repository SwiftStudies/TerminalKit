import XCTest
@testable import TerminalKit

final class TerminalKitTests: XCTestCase {
    func testUsage() {
        let tool = Tool("test", version: "1.0.0", description: "A test tool", commands: [ParameteredCommand()])
        let usage = tool.commands[0].usage(command: ["test"])
        print(usage)
    }


    static var allTests = [
        ("testExample", testUsage),
    ]
}
