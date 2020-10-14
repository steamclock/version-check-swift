//
//  ParsingTests.swift
//  

import XCTest
import VersionCheck

final class ParsingTests: XCTestCase {
    func testBasicParse() {
        let versionString = "1.2.3-test@250"

        let version = try? Version(string: versionString)
        XCTAssertNotNil(version)
        XCTAssertEqual(version?.description, versionString)
        XCTAssertEqual(version?.marketingComponents, [1,2,3])
        XCTAssertEqual(version?.additionalText, "-test")
        XCTAssertEqual(version?.build, 250)
        XCTAssertEqual(version?.isDevelopment, false)
    }

    func testValid() {
        let validVersionStrings = [
            "1",
            "1.2",
            "1.2.3.4.5", // do we want to support super long versions or should we cap?
            "1.12b",
            "1.0.0@250",
            "1.0.0-beta5@250",
            "@250"
        ]

        for valid in validVersionStrings {
            XCTAssertNoThrow(try Version(string: valid), "Valid version string \"\(valid)\" failed to parse")
        }
    }

    func testInvalid() {
        let invalidVersionStrings = [
            "1.0@4@5",
            "1.foo.0",
            "foo",
            "1.x",
            "",
            "."
        ]

        for invalid in invalidVersionStrings {
            XCTAssertThrowsError(try Version(string: invalid), "Invalid version string \"\(invalid)\" was accepted incorrectly")
        }
    }

    static var allTests = [
        ("testBasicParse", testBasicParse),
        ("testValid", testValid),
        ("testInvalid", testInvalid),
    ]
}
