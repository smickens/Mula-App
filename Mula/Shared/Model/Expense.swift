//
//  Expense.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation
import SwiftData

@Model
class Expense: CustomStringConvertible {
    var title: String
    var date: Date
    var amount: Double
    var category: Category
    
    init(title: String, date: Date, amount: Double, category: Category) {
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.date = date
        self.amount = amount
        self.category = category
    }

    var isIncome: Bool {
        return self.amount > 0
    }

    var description: String {
        return "<\(type(of: self))>: title = \(title), date = \(date), amount = \(amount), category = \(category)"
    }
}
