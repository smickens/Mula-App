//
//  Extensions.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import Foundation

extension Date {
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }

    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func removingQuotes() -> String {
        self.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
    }
}

extension Decimal {
    func toCurrency() -> String {
        Self.currencyFormatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }

    func toDecimalString() -> String {
        Self.decimalFormatter.string(from: self as NSDecimalNumber) ?? ""
    }

    static func formattedDecimal(from string: String) -> Decimal? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return nil }

        return Self.decimalParser.number(from: trimmed)?.decimalValue
    }

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let decimalParser: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.isLenient = true
        formatter.generatesDecimalNumbers = true
        return formatter
    }()
}
