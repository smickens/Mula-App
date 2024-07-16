//
//  Expense.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation

class Expense: Identifiable, CustomStringConvertible {
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.id == rhs.id
    }

    let id: String
    var title: String
    var date: Date
    var amount: Double
    var bucket: Bucket
    var category: Category?

    init(id: String, title: String, date: Date, amount: Double, bucket: Bucket, category: Category?) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = date
        self.amount = amount
        self.bucket = bucket
        self.category = category
    }

    var isIncome: Bool {
        return self.bucket == .income
    }

    var description: String {
        return "<\(type(of: self))>: title = \(title), date = \(date), amount = \(amount), bucket = \(bucket), category = \(category?.name ?? "none")"
    }
}
