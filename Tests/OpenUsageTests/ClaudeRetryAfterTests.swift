import XCTest
@testable import OpenUsage

/// A huge Retry-After once overflowed the countdown back to an Int, so waits cap at an hour
/// (upstream #1505).
final class ClaudeRetryAfterTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func retryAfter(_ value: String) -> Int? {
        ClaudeUsageMapper.parseRetryAfterSeconds(HTTPResponse(statusCode: 429, headers: ["retry-after": value], body: Data()), now: now)
    }

    func testAShortWaitIsKept() {
        XCTAssertEqual(retryAfter("120"), 120)
    }

    func testAWaitLongerThanAnHourCapsAtAnHour() {
        XCTAssertEqual(retryAfter("9223372036854775807"), 3600)
        XCTAssertEqual(retryAfter("Fri, 31 Dec 9999 23:59:59 GMT"), 3600)
    }
}
