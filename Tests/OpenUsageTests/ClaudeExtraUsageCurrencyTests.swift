import XCTest
@testable import OpenUsage

/// Claude bills Extra Usage in the account's own currency, with `decimal_places` minor units
/// (upstream 8a883219).
final class ClaudeExtraUsageCurrencyTests: XCTestCase {
    private func extraLine(_ extra: String) throws -> MetricLine? {
        let response = HTTPResponse(statusCode: 200, headers: [:], body: Data(#"{"extra_usage":\#(extra)}"#.utf8))
        return try ClaudeUsageMapper.mapUsageResponse(response, credentials: ClaudeOAuth()).lines.first
    }

    func testACappedEuroSpendReadsInEuros() throws {
        let line = try extraLine(#"{"is_enabled":true,"used_credits":1234,"monthly_limit":5000,"currency":"EUR","decimal_places":2}"#)
        XCTAssertEqual(line, .progress(label: "Extra usage spent", used: 12.34, limit: 50, format: .currency(code: "EUR")))
    }

    func testAnUncappedYenSpendHasNoMinorUnits() throws {
        let line = try extraLine(#"{"is_enabled":true,"used_credits":1500,"monthly_limit":null,"currency":"JPY","decimal_places":0}"#)
        XCTAssertEqual(line, .values(label: "Extra usage spent", values: [MetricValue(number: 1500, kind: .dollars, currencyCode: "JPY")]))
    }

    func testAUSDOrUnnamedCurrencyKeepsPlainDollars() throws {
        let line = try extraLine(#"{"is_enabled":true,"used_credits":1234,"monthly_limit":5000}"#)
        XCTAssertEqual(line, .progress(label: "Extra usage spent", used: 12.34, limit: 50, format: .dollars))
        let usd = try extraLine(#"{"is_enabled":true,"used_credits":1234,"monthly_limit":5000,"currency":"USD","decimal_places":2}"#)
        XCTAssertEqual(usd, line)
    }

    func testFormatterUsesTheCurrencySymbol() {
        XCTAssertEqual(MetricFormatter.number(12.34, kind: .dollars, style: .row, currencyCode: "EUR"), "€12.34")
        XCTAssertEqual(MetricFormatter.number(12.34, kind: .dollars, style: .tray, currencyCode: "EUR"), "€12")
        XCTAssertEqual(MetricFormatter.number(1500, kind: .dollars, style: .row, currencyCode: "JPY"), "¥1.5K")
        XCTAssertEqual(MetricFormatter.number(1500, kind: .dollars, style: .full, currencyCode: "JPY"), "¥1,500")
        XCTAssertEqual(MetricFormatter.number(12.34, kind: .dollars, style: .row), "$12.34")
    }

    func testACurrencyMeterRendersItsSymbolEverywhere() {
        let data = WidgetData(
            title: "Extra Usage", icon: .providerMark("claude"), kind: .dollars, currencyCode: "EUR",
            used: 12.34, limit: 50
        )
        XCTAssertEqual(data.boundedHeadline, "€12.34 used")
        XCTAssertEqual(data.menuBarValue, "€12")
        XCTAssertEqual(data.boundedSubtitle, "€50 limit")
    }

    func testACurrencyFormatSurvivesTheSnapshotCache() throws {
        let format = ProgressFormat.currency(code: "EUR")
        let decoded = try JSONDecoder().decode(ProgressFormat.self, from: JSONEncoder().encode(format))
        XCTAssertEqual(decoded, format)
    }
}
