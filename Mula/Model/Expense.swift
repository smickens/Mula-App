//
//  Expense.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation

struct AccountStatement {
    let id: UUID
    let date: String
    let balance: Double
}

struct ImportBatch {
    let id: UUID
    let date: Date
    let name: String?
}

struct Transaction {
    let id: UUID

    let accountId: UUID?
    let importBatchId: UUID?

    let title: String
    let date: Date
    let amount: Double

    let category: TransactionCategory
}

enum TransactionCategory: String, CaseIterable {
    case housing = "Housing" // rent, utils, internet, etc.

    case eatingOut = "Eating Out"
    case groceries = "Groceries"

    case shopping = "Shopping"

    case car = "Lil Red" // gas, maintenance (servicing, tire, etc.)
    case transit = "Transit" // flights, bus, caltrain, ubers

    case entertainment = "Entertainment"

    case income = "Income"
    case transfer = "Transfer"
    case refund = "Refund"
    case dividend = "Dividend"
    case interest = "Interest"

    case other = "Other"
}




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
