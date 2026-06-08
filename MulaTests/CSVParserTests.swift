//
//  CSVParserTests.swift
//  MulaTests
//
//  Created by Shanti Mickens on 6/4/26.
//

@testable import MulaCore
import Testing

struct CSVParserTests {

    @Test func parseReturnsHeadersAndDataRows() throws {
        let content = csvContent(
            headers: ["Date", "Name", "Amount"],
            rows: [
                ["2026-06-01", "Coffee", "4.50"],
                ["2026-06-02", "Groceries", "12.34"]
            ]
        )

        let document = CSVParser.parse(content)
        let table = try #require(document.table(headerRowIndex: 0))

        #expect(table.headers == ["Date", "Name", "Amount"])
        #expect(table.dataRows.count == 2)
        #expect(table.dataRows[0].rowNumber == 2)
        #expect(table.dataRows[0].values == ["2026-06-01", "Coffee", "4.50"])
        #expect(table.dataRows[1].rowNumber == 3)
        #expect(table.dataRows[1].values == ["2026-06-02", "Groceries", "12.34"])
    }

    @Test func parseSkipsBlankLinesAndPreservesOriginalRowNumbers() throws {
        let content = """
        Date,Name,Amount

        2026-06-01,Coffee,4.50

        2026-06-02,Groceries,12.34
        """

        let document = CSVParser.parse(content)
        let table = try #require(document.table(headerRowIndex: 0))

        #expect(table.dataRows.count == 2)
        #expect(table.dataRows[0].rowNumber == 3)
        #expect(table.dataRows[1].rowNumber == 5)
    }

    @Test func valueForHeaderIsCaseInsensitive() throws {
        let content = csvContent(
            headers: ["Date", "Name", "Amount"],
            rows: [["2026-06-01", "Coffee", "4.50"]]
        )

        let document = CSVParser.parse(content)
        let table = try #require(document.table(headerRowIndex: 0))
        let row = table.dataRows[0]

        #expect(table.value(in: row, for: "date") == "2026-06-01")
        #expect(table.value(in: row, for: "NAME") == "Coffee")
        #expect(table.value(in: row, for: "amount") == "4.50")
    }

    @Test func parseRemovesByteOrderMarkFromHeader() throws {
        let content = """
        \u{FEFF}Date,Name,Amount
        2026-06-01,Coffee,4.50
        """

        let document = CSVParser.parse(content)
        let table = try #require(document.table(headerRowIndex: 0))

        #expect(table.headers == ["Date", "Name", "Amount"])
        #expect(table.value(in: table.dataRows[0], for: "Date") == "2026-06-01")
    }

    @Test func parseSupportsQuotedFieldsContainingCommas() throws {
        let content = csvContent(
            headers: ["Date", "Name", "Amount"],
            rows: [["2026-06-01", "\"Coffee, Bakery\"", "4.50"]]
        )

        let document = CSVParser.parse(content)
        let table = try #require(document.table(headerRowIndex: 0))

        #expect(table.dataRows.count == 1)
        #expect(table.dataRows[0].values == ["2026-06-01", "Coffee, Bakery", "4.50"])
    }

    @Test func parseReturnsEmptyDocumentForEmptyContent() {
        let document = CSVParser.parse("")

        #expect(document.rows.isEmpty)
        #expect(document.table(headerRowIndex: 0) == nil)
    }
}
