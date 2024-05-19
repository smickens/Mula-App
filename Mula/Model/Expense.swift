//
//  Expense.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation
import SwiftData

@Model
class Expense {
    var title: String
    var date: Date
    var amount: Double
    var category: Category
    
    init(title: String, date: Date, amount: Double, category: Category) {
        self.title = title
        self.date = date
        self.amount = amount
        self.category = category
    }
}
