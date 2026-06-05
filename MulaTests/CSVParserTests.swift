//
//  CSVParserTests.swift
//  MulaTests
//
//  Created by Shanti Mickens on 6/4/26.
//

@testable import MulaCore
import Testing

struct CSVParserTests {

    @Test func parseReturnsHeadersAndDataRows() {
        let content = """
        Date,Name,Amount
        2026-06-01,Coffee,4.50
        2026-06-02,Groceries,12.34
        """

        let table = CSVParser.parse(content)

        #expect(table.headers == ["Date", "Name", "Amount"])
        #expect(table.dataRows.count == 2)
        #expect(table.dataRows[0].rowNumber == 2)
        #expect(table.dataRows[0].values == ["2026-06-01", "Coffee", "4.50"])
        #expect(table.dataRows[1].rowNumber == 3)
        #expect(table.dataRows[1].values == ["2026-06-02", "Groceries", "12.34"])
    }

    @Test func parseSkipsBlankLinesAndPreservesOriginalRowNumbers() {
        let content = """
        Date,Name,Amount

        2026-06-01,Coffee,4.50

        2026-06-02,Groceries,12.34
        """

        let table = CSVParser.parse(content)

        #expect(table.dataRows.count == 2)
        #expect(table.dataRows[0].rowNumber == 3)
        #expect(table.dataRows[1].rowNumber == 5)
    }

    @Test func valueForHeaderIsCaseInsensitive() {
        let content = """
        Date,Name,Amount
        2026-06-01,Coffee,4.50
        """

        let row = CSVParser.parse(content).dataRows[0]

        #expect(row.value(for: "date") == "2026-06-01")
        #expect(row.value(for: "NAME") == "Coffee")
        #expect(row.value(for: "amount") == "4.50")
    }

    @Test func parseRemovesByteOrderMarkFromHeader() {
        let content = """
        \u{FEFF}Date,Name,Amount
        2026-06-01,Coffee,4.50
        """

        let table = CSVParser.parse(content)

        #expect(table.headers == ["Date", "Name", "Amount"])
        #expect(table.dataRows[0].value(for: "Date") == "2026-06-01")
    }

    @Test func parseSupportsQuotedFieldsContainingCommas() {
        let content = """
        Date,Name,Amount
        2026-06-01,"Coffee, Bakery",4.50
        """

        let table = CSVParser.parse(content)

        #expect(table.dataRows.count == 1)
        #expect(table.dataRows[0].values == ["2026-06-01", "Coffee, Bakery", "4.50"])
    }

    @Test func parseReturnsEmptyTableForEmptyContent() {
        let table = CSVParser.parse("")

        #expect(table.headers == [])
        #expect(table.dataRows.count == 0)
    }
}
