//
//  Expense.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation

@Observable class Expense: Identifiable, CustomStringConvertible, Equatable, NSCopying {
    var id: String?
    var title: String
    var date: Date
    var amount: Double
    var bucket: Bucket
    var category: Category

    init(id: String?, title: String, date: Date, amount: Double, bucket: Bucket, category: Category) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = date
        self.amount = amount
        self.bucket = bucket
        self.category = category
    }

    var description: String {
        return "<\(type(of: self))>: title = \(title), date = \(date), amount = \(amount), bucket = \(bucket), category = \(category)"
    }

    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.id == rhs.id
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Expense(id: id, title: title, date: date, amount: amount, bucket: bucket, category: category)
        return copy
    }
}
