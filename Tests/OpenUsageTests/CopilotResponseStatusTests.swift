import XCTest
@testable import OpenUsage

/// GitHub sends some rate limits as 403, so only a plain 403 means the token is bad (upstream #1529).
final class CopilotResponseStatusTests: XCTestCase {
    private func failure(_ status: Int, _ headers: [String: String] = [:]) -> Error? {
        CopilotUsageMapper.failure(for: HTTPResponse(statusCode: status, headers: headers, body: Data()))
    }

    func testASuccessIsNoFailure() {
        XCTAssertNil(failure(200))
    }

    func testA401OrAPlain403IsAnInvalidToken() {
        XCTAssertEqual(failure(401) as? CopilotAuthError, .tokenInvalid)
        XCTAssertEqual(failure(403) as? CopilotAuthError, .tokenInvalid)
    }

    func testGitHubRateLimitsReadAsRateLimits() {
        XCTAssertEqual(failure(403, ["x-ratelimit-remaining": "0"]) as? CopilotUsageError, .rateLimited)
        XCTAssertEqual(failure(403, ["retry-after": "60"]) as? CopilotUsageError, .rateLimited)
        XCTAssertEqual(failure(429) as? CopilotUsageError, .rateLimited)
    }

    func testOtherStatusesAreFailedRequests() {
        XCTAssertEqual(failure(500) as? CopilotUsageError, .requestFailed(500))
    }
}
