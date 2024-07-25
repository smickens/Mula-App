//
//  Income.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import Foundation

@Observable class Income: Identifiable, CustomStringConvertible, Transaction {
    let id: String
    var title: String
    var date: Date
    var amount: Double

    init(id: String, title: String, date: Date, amount: Double) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = date
        self.amount = amount
    }

    var description: String {
        return "<\(type(of: self))>: title = \(title), date = \(date), amount = \(amount)"
    }

    static func == (lhs: Income, rhs: Income) -> Bool {
        return lhs.id == rhs.id
    }
}
