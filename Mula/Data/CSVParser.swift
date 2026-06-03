//
//  CSVParser.swift
//  Mula
//
//  Created by Shanti Mickens on 5/9/26.
//

import Foundation

struct CSVParser {
    static func parse(_ content: String) -> CSVTable {
        let parsedRows = content
            .components(separatedBy: .newlines)
            .enumerated()
            .compactMap { index, line -> CSVRow? in
                let values = parseLine(line)
                let isEmpty = values.allSatisfy {
                    $0.removingByteOrderMark()
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                }

                guard !isEmpty else { return nil }

                return CSVRow(rowNumber: index + 1, headers: [], values: values)
            }

        guard let headerRow = parsedRows.first else {
            return CSVTable(headers: [], dataRows: [])
        }

        let headers = headerRow.values.map { $0.removingByteOrderMark() }
        let dataRows = parsedRows.dropFirst().map {
            CSVRow(rowNumber: $0.rowNumber, headers: headers, values: $0.values)
        }

        return CSVTable(headers: headers, dataRows: Array(dataRows))
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
}

struct CSVTable {
    let headers: [String]
    let dataRows: [CSVRow]
}

struct CSVRow {
    let rowNumber: Int
    let headers: [String]
    let values: [String]

    func value(for header: String) -> String {
        guard let index = headers.firstIndex(where: { $0.caseInsensitiveCompare(header) == .orderedSame }),
              values.indices.contains(index) else {
            return ""
        }

        return values[index]
    }

}
