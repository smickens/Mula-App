//
//  CSVParser.swift
//  MulaCore
//
//  Created by Shanti Mickens on 5/9/26.
//

import Foundation

public struct CSVParser {
    public static func parse(_ content: String) -> CSVDocument {
        let rows = content
            .components(separatedBy: .newlines)
            .enumerated()
            .compactMap { index, line -> CSVRow? in
                let parsedValues = parseLine(line)
                let values = normalizedValues(parsedValues, rowIndex: index)
                let isEmpty = values.allSatisfy {
                    $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }

                guard !isEmpty else { return nil }

                return CSVRow(rowNumber: index + 1, values: values)
            }

        return CSVDocument(rows: rows)
    }

    private static func parseLine(_ line: String) -> [String] {
        var values: [String] = []
        var currentValue = ""
        var insideQuotes = false

        for character in line {
            if character == "\"" {
                insideQuotes.toggle()
            } else if character == "," && !insideQuotes {
                values.append(currentValue.trimmingCharacters(in: .whitespaces).removingQuotes())
                currentValue = ""
            } else {
                currentValue.append(character)
            }
        }

        values.append(currentValue.trimmingCharacters(in: .whitespaces).removingQuotes())
        return values
    }

    private static func normalizedValues(_ values: [String], rowIndex: Int) -> [String] {
        guard rowIndex == 0, let firstValue = values.first else {
            return values
        }

        var normalizedValues = values
        normalizedValues[0] = firstValue.removingByteOrderMark()
        return normalizedValues
    }

    public init() {}
}

public struct CSVDocument {
    public let rows: [CSVRow]

    public init(rows: [CSVRow]) {
        self.rows = rows
    }

    public func table(headerRowIndex: Int) -> CSVTable? {
        guard rows.indices.contains(headerRowIndex) else {
            return nil
        }

        return CSVTable(
            header: rows[headerRowIndex],
            dataRows: Array(rows.dropFirst(headerRowIndex + 1))
        )
    }
}

public struct CSVTable {
    public let header: CSVRow
    public let dataRows: [CSVRow]

    private let headerIndexByName: [String: Int]

    public init(header: CSVRow, dataRows: [CSVRow]) {
        self.header = header
        self.dataRows = dataRows
        self.headerIndexByName = Dictionary(
            uniqueKeysWithValues: header.values.enumerated().map { index, headerName in
                (headerName.lowercased(), index)
            }
        )
    }

    public var headers: [String] {
        header.values
    }

    public func value(in row: CSVRow, for headerName: String) -> String {
        guard let index = headerIndexByName[headerName.lowercased()],
              row.values.indices.contains(index) else {
            return ""
        }

        return row.values[index]
    }
}

public struct CSVRow {
    public let rowNumber: Int
    public let values: [String]

    public init(rowNumber: Int, values: [String]) {
        self.rowNumber = rowNumber
        self.values = values
    }
}
