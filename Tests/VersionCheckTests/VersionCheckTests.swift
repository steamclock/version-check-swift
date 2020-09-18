import XCTest
@testable import VersionCheck

final class VersionCheckTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VersionCheck().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
