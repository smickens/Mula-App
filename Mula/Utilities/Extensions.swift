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

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()
}
