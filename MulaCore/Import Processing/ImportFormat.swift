//
//  ImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

struct ImportFormat {
    let source: ImportSource
    let matches: ([String]) -> Bool
    let rowResult: (CSVTable, CSVRow) -> ImportRowResult

    static func detect(in document: CSVDocument) -> ImportFormatMatch? {
        for (index, row) in document.rows.enumerated() {
            let headers = row.values
            if let format = allFormats.first(where: { $0.matches(headers) }) {
                return ImportFormatMatch(format: format, headerRowIndex: index)
            }
        }

        return nil
    }

    private static let allFormats: [ImportFormat] = [
        .apple,
        .fidelityInvestments,
        .fidelity401k,
        .usBank,
        .wellsFargo
    ]
}

struct ImportFormatMatch {
    let format: ImportFormat
    let headerRowIndex: Int
}

extension ImportFormat {
    static func monthEndDate(from label: String) -> Date? {
        let monthYear = label
            .components(separatedBy: "(")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? label

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "MMM yyyy"

        let calendar = Calendar(identifier: .gregorian)

        guard let monthStart = formatter.date(from: monthYear),
              let monthInterval = calendar.dateInterval(of: .month, for: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) else {
            return nil
        }

        return monthEnd
    }

    static func parseCurrency(_ string: String) -> Decimal? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "(", with: "-")
            .replacingOccurrences(of: ")", with: "")

        return Decimal(string: normalized)
    }
}
