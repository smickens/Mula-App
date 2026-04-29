//
//  TestData.swift
//  Mula
//
//  Created by Shanti Mickens on 4/5/26.
//

import Foundation

struct TestData {
    

    static let accounts: [Account] = [
        Account(id: UUID(), name: "CapEd Checking", type: .checking),
        Account(name: "CapEd Savings", type: .saving),
        Account(name: "Charles Schwab 401(k)", type: .retirement),
        Account(name: "Amex Gold Card", type: .creditCard)
    ]

    static let transactions: [Transaction] = [
        Transaction(id: UUID(), title: "Walmart", date: Date(), kind: .expense(.groceries), amount: 45.21, sourceAccountId: UUID()),
        Transaction(id: UUID(), title: "McDonald's", date: Date(), kind: .expense(.groceries), amount: 8.15, sourceAccountId: UUID())
    ]

    static let importBatches: [ImportBatch] = [
        ImportBatch(id: UUID(), date: Date(), name: "CapEd Statement March 2026")
    ]
}
