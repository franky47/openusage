import XCTest
@testable import OpenUsage

/// Anthropic renamed Max 5x to Max and Max 20x to Ultra on Oct 30, 2026 (upstream #1497).
final class ClaudePlanTests: XCTestCase {
    private func plan(_ subscriptionType: String, _ rateLimitTier: String?) -> String? {
        ClaudeUsageMapper.formatPlan(subscriptionType: subscriptionType, rateLimitTier: rateLimitTier)
    }

    func testMaxTiersReadUnderAnthropicsNewPlanNames() {
        XCTAssertEqual(plan("max", "default_claude_max_5x"), "Max")
        XCTAssertEqual(plan("max", "default_claude_max_20x"), "Ultra")
        XCTAssertEqual(plan("max", nil), "Max")
    }

    func testAnUltraTierOrSubscriptionReadsUltra() {
        XCTAssertEqual(plan("max", "default_claude_ultra"), "Ultra")
        XCTAssertEqual(plan("ultra", "default_claude_ultra"), "Ultra")
        XCTAssertEqual(plan("ultra", "default_claude_max_20x"), "Ultra")
    }

    func testOtherPlansKeepTheirNames() {
        XCTAssertEqual(plan("pro", "default_claude_ai"), "Pro")
        XCTAssertEqual(plan("team", "default_claude_max_5x"), "Team 5x")
        XCTAssertEqual(plan("enterprise", nil), "Enterprise")
    }
}
