//
//  ComparisonTests.swift
//  

import XCTest
import VersionCheck

func versionsPatternMatch(pattern: String, value: String) -> Bool {
    return try! Version(string: pattern) ~= Version(string: value)
}

func versionsEqual(_ a: String, _ b: String) -> Bool {
    return try! Version(string: a) == Version(string: b)
}

func versionsOrderedAscending(_ a: String, _ b: String) -> Bool {
    return try! Version(string: a) < Version(string: b)
}

final class ComparisonTests: XCTestCase {
    func testBasicEquality() {
        let version = try? Version(string: "1.2.3-test@250")
        XCTAssertNotNil(version)
        XCTAssertEqual(version, version)
        XCTAssertEqual(version, try? Version(string: "1.2.3-test@250"))
        XCTAssertNotEqual(version, try? Version(string: "1.2.4-test@250"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.2.3"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.2.3", build: "300"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.1.4", build: "250"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.2.3", build: "300"))
        XCTAssertNotEqual(version, try? Version(marketing: "1.1.4", build: "250"))

    }

    func testAlternateConstructions() {
        XCTAssertEqual(try? Version(string: "1.2.3-test@250"), try? Version(marketing: "1.2.3-test", build: "250"))
        XCTAssertEqual(try? Version(string: "1.2.3-test@250"), try? Version(marketing: "1.2.3-different-text", build: "250")) // additional text ignored for comparison purposes
        XCTAssertEqual(try? Version(string: "@250"), try? Version(build: "250"))
        XCTAssertEqual(try? Version(string: "1.1.0"), try? Version(marketing: "1.1.0", build: nil))
    }

    func testMissingComponents() {
        // Check for equality with missing components (zero should be assumed for missing components
        XCTAssertTrue(versionsEqual("1.2", "1.2.0"))
        XCTAssertFalse(versionsEqual("1.2", "1.2.1"))
    }

    func testPatternMatch() {
        XCTAssertTrue(versionsPatternMatch(pattern: "1.2", value: "1.2.1"))
        XCTAssertTrue(versionsPatternMatch(pattern: "1.2.1", value: "1.2.1@400"))
        XCTAssertFalse(versionsPatternMatch(pattern: "@300", value: "1.2.1@400"))
        XCTAssertTrue(versionsPatternMatch(pattern: "1", value: "1.2.1"))
        XCTAssertFalse(versionsPatternMatch(pattern: "1.4", value: "1.2.1"))
    }

    func testOrdering() {
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
    }

    func testDevelopmentBuild() {
        // Check ordering rules with special handling of build 0 / development builds (build zero should count as "newer" if marketing versions are the same
        XCTAssertTrue(versionsOrderedAscending("1.2@250", "1.2@0"))
        XCTAssertFalse(versionsOrderedAscending("1.2@0", "1.2@250"))
        XCTAssertTrue(versionsOrderedAscending("1.2@250", "1.3@0"))
        XCTAssertFalse(versionsOrderedAscending("1.2@250", "1.1@0"))
    }

    static var allTests = [
        ("testBasicEquality", testBasicEquality),
        ("testAlternateConstructions", testAlternateConstructions),
        ("testMissingComponents", testMissingComponents),
        ("testPatternMatch", testPatternMatch),
        ("testOrdering", testOrdering),
        ("testDevelopmentBuild", testDevelopmentBuild),
    ]
}
