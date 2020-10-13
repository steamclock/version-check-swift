import XCTest
@testable import VersionCheck

func versionsEqual(_ a: String, _ b: String) -> Bool {
    return try! Version(string: a) == Version(string: b)
}

func versionsOrderedAscending(_ a: String, _ b: String) -> Bool {
    return try! Version(string: a) < Version(string: b)
}


final class VersionCheckTests: XCTestCase {
    func testParsing() {
        let versionString = "1.2.3-test@250"

        let validVersionStrings = [
            "1",
            "1.2",
            "1.2.3.4.5", // do we want to support super long versions or should we cap?
            "1.12b",
            "1.0.0@250",
            "1.0.0-beta5@250",
            "@250"
        ]

        let invalidVersionStrings = [
            "1.0@4@5",
            "1.foo.0",
            "foo",
            "1.x",
            "",
            "."
        ]

        // Check basic parse and reconstruction
        let version = try? Version(string: versionString)
        XCTAssertNotNil(version)
        XCTAssertEqual(version?.description, versionString)
        XCTAssertEqual(version?.marketingComponents, [1,2,3])
        XCTAssertEqual(version?.additionalText, "-test")
        XCTAssertEqual(version?.build, 250)

        // check equality of different constructions
        XCTAssertEqual(version, try? Version(marketing: "1.2.3-test", build: "250"))
        XCTAssertEqual(version, try? Version(marketing: "1.2.3-different-text", build: "250")) // additional text ignored for comparison purposes
        XCTAssertEqual(try? Version(string: "@250"), try? Version(build: "250"))
        XCTAssertEqual(try? Version(string: "1.1.0"), try? Version(marketing: "1.1.0", build: nil))

        // verify inequality
        XCTAssertNotEqual(version, try? Version(marketing: "1.2.3", build: "300"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.1.4", build: "250"))

        // Check for equality with missing components (zero should be assumed for missing components
        XCTAssertTrue(versionsEqual("1.2", "1.2.0"))
        XCTAssertFalse(versionsEqual("1.2", "1.2.1"))

        // Check ordering
        XCTAssertTrue(versionsOrderedAscending("1.2", "1.2.1"))
        XCTAssertTrue(versionsOrderedAscending("1.2.2", "1.2.10"))
        XCTAssertFalse(versionsOrderedAscending("1.2.2", "1.2.1"))
        XCTAssertTrue(versionsOrderedAscending("1.2.4", "1.3.5"))
        XCTAssertTrue(versionsOrderedAscending("1.2.4", "3"))
        XCTAssertTrue(versionsOrderedAscending("3", "4.1"))
        XCTAssertTrue(versionsOrderedAscending("1.2.4", "1.3.4"))
        XCTAssertTrue(versionsOrderedAscending("1.2", "2"))
        XCTAssertTrue(versionsOrderedAscending("1.2@300", "1.2@301"))
        XCTAssertTrue(versionsOrderedAscending("1.2-b@300", "1.2-a@301"))
        XCTAssertFalse(versionsOrderedAscending("1.3@300", "1.2@200")) // bit of a trick question, build numbers are out of sequence, should probably warn in this case?

        // Check ordering rules with special handling of build 0 / development builds (build zero should count as "newer" if marketing versions are the same
        XCTAssertTrue(versionsOrderedAscending("1.2@250", "1.2@0"))
        XCTAssertFalse(versionsOrderedAscending("1.2@0", "1.2@250"))
        XCTAssertTrue(versionsOrderedAscending("1.2@250", "1.3@0"))
        XCTAssertFalse(versionsOrderedAscending("1.2@250", "1.1@0"))

        // check some other valid version strings will parse
        for valid in validVersionStrings {
            XCTAssertNoThrow(try Version(string: valid), "Valid version string \"\(valid)\" failed to parse")
        }

        // check some other invalid version strings won't parse
        for invalid in invalidVersionStrings {
            XCTAssertThrowsError(try Version(string: invalid), "Invalid version string \"\(invalid)\" was accepted incorrectly")
        }
    }

    static var allTests = [
        ("testParsing", testParsing),
    ]
}
