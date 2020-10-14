import XCTest
import VersionCheck

var testURL = "https://gist.githubusercontent.com/nbrooke/0a7ee7a20b75b3d81555c913f7754978/raw/af365cda43cec1fa990fbf2a66a27d913bc6926d/version.json"

struct TestAppVersion: AppVersionFetcher {
    var marketing: String?
    var build: String?
}

struct TestURLFetcher: URLFetcher {
    var string: String
    func data(for: URL) -> Data? {
        return string.data(using: .utf8)
    }
}

let testJSON =
    """
    {
      "ios" : {
        "minimumVersion": "2.1",
        "blockedVersions": ["2.2.0", "2.2.1", "@301"],
        "currentVersion": "2.4.2@400"
      },
      "serverForceVersionFailure": false,
      "serverMaintenance": false
    }
    """

final class VersionCheckTests: XCTestCase {
    func runAsyncFetch(url: String, appVersionFetch: AppVersionFetcher, urlFetch: URLFetcher, targetStatus: Status) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Running async version check: \(url)")

        func statusChange(_ status: Status) {
            XCTAssertEqual(status, targetStatus)
            expectation.fulfill()
        }

        _ = VersionCheck(url: url,
                         displayHandler: nil,
                         statusHandler: statusChange,
                         jsonFormatConverter: nil,
                         appVersionFetch: appVersionFetch,
                         urlFetch: urlFetch)

        return expectation

    }

    func testVersionCheck() {
        let expectations = [
            runAsyncFetch(url: "http://one.com", appVersionFetch: TestAppVersion(marketing: "2.0.1", build: "100"), urlFetch: TestURLFetcher(string: testJSON), targetStatus: .versionDisallowed),
            runAsyncFetch(url: "http://two.com", appVersionFetch: TestAppVersion(marketing: "2.1.1", build: "200"), urlFetch: TestURLFetcher(string: testJSON), targetStatus: .versionAllowed),
            runAsyncFetch(url: "http://three.com", appVersionFetch: TestAppVersion(marketing: "2.2.1", build: "400"), urlFetch: TestURLFetcher(string: testJSON), targetStatus: .versionDisallowed)
        ]

        wait(for: expectations, timeout: 5000)
    }

    func testNetworkFetch() {
        let expectations = [
            runAsyncFetch(url: testURL, appVersionFetch: TestAppVersion(marketing: "1.0.1", build: "100"), urlFetch: NetworkURLFetcher(), targetStatus: .versionDisallowed),
            runAsyncFetch(url: testURL, appVersionFetch: TestAppVersion(marketing: "1.1.1", build: "200"), urlFetch: NetworkURLFetcher(), targetStatus: .versionAllowed)
        ]

        wait(for: expectations, timeout: 5000)
    }

    static var allTests = [
        ("testVersionCheck", testVersionCheck),
        ("testNetworkFetch", testNetworkFetch),
    ]
}
