//
//  TestData.swift
//  Mula
//
//  Created by Shanti Mickens on 4/5/26.
//

import Foundation

struct TestData {
    private enum ID {
        static let checking = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
        static let savings = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
        static let retirement = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
        static let creditCard = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
        static let investment = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!

        static let olderImport = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!
        static let recentImport = UUID(uuidString: "20000000-0000-0000-0000-000000000002")!
    }

    static let accounts: [Account] = [
        Account(id: ID.checking, name: "CapEd Checking", type: .checking),
        Account(id: ID.savings, name: "CapEd Savings", type: .saving),
        Account(id: ID.retirement, name: "Charles Schwab 401(k)", type: .retirement),
        Account(id: ID.creditCard, name: "Amex Gold Card", type: .creditCard),
        Account(id: ID.investment, name: "Robinhood Brokerage", type: .investment)
    ]

    static let importBatches: [ImportBatch] = [
        ImportBatch(id: ID.olderImport, date: date(daysAgo: 75), name: "CapEd Statement"),
        ImportBatch(id: ID.recentImport, date: date(daysAgo: 32), name: "Amex Statement")
    ]

    static let transactions: [Transaction] = [
        transaction(1, title: "Paycheck", date: date(daysAgo: 3), kind: .income(.job), amount: amount("3200.00"), sourceAccountId: ID.checking),
        transaction(2, title: "CapEd Mortgage", date: date(daysAgo: 6), kind: .expense(.housing), amount: amount("1550.00"), sourceAccountId: ID.checking),
        transaction(3, title: "Albertsons", date: date(daysAgo: 9), kind: .expense(.groceries), amount: amount("86.42"), sourceAccountId: ID.creditCard, importBatchId: ID.recentImport),
        transaction(4, title: "Target", date: date(daysAgo: 12), kind: .expense(.shopping), amount: amount("129.17"), sourceAccountId: ID.creditCard, importBatchId: ID.recentImport),
        transaction(5, title: "Chipotle", date: date(daysAgo: 15), kind: .expense(.eatingOut), amount: amount("14.36"), sourceAccountId: ID.creditCard, importBatchId: ID.recentImport),
        transaction(6, title: "Chevron", date: date(daysAgo: 19), kind: .expense(.car), amount: amount("48.09"), sourceAccountId: ID.creditCard, importBatchId: ID.recentImport),
        transaction(7, title: "Movie Night", date: date(daysAgo: 22), kind: .expense(.entertainment), amount: amount("32.50"), sourceAccountId: ID.creditCard, importBatchId: ID.recentImport),
        transaction(8, title: "Savings Transfer", date: date(daysAgo: 26), kind: .transfer(.savings, destinationAccountId: ID.savings), amount: amount("400.00"), sourceAccountId: ID.checking),
        transaction(9, title: "Credit Card Payment", date: date(daysAgo: 29), kind: .transfer(.creditCardPayment, destinationAccountId: ID.creditCard), amount: amount("650.00"), sourceAccountId: ID.checking),
        transaction(10, title: "Dividend", date: date(daysAgo: 33), kind: .income(.dividend), amount: amount("27.81"), sourceAccountId: ID.investment),

        transaction(11, title: "Paycheck", date: date(daysAgo: 38), kind: .income(.job), amount: amount("3200.00"), sourceAccountId: ID.checking),
        transaction(12, title: "CapEd Mortgage", date: date(daysAgo: 42), kind: .expense(.housing), amount: amount("1550.00"), sourceAccountId: ID.checking),
        transaction(13, title: "WinCo Foods", date: date(daysAgo: 46), kind: .expense(.groceries), amount: amount("74.93"), sourceAccountId: ID.checking, importBatchId: ID.olderImport),
        transaction(14, title: "Local Coffee", date: date(daysAgo: 50), kind: .expense(.eatingOut), amount: amount("6.75"), sourceAccountId: ID.checking, importBatchId: ID.olderImport),
        transaction(15, title: "Oil Change", date: date(daysAgo: 55), kind: .expense(.car), amount: amount("89.99"), sourceAccountId: ID.checking, importBatchId: ID.olderImport),
        transaction(16, title: "Netflix", date: date(daysAgo: 60), kind: .expense(.entertainment), amount: amount("22.99"), sourceAccountId: ID.creditCard, importBatchId: ID.olderImport),
        transaction(17, title: "Bus Pass", date: date(daysAgo: 64), kind: .expense(.transit), amount: amount("42.00"), sourceAccountId: ID.checking, importBatchId: ID.olderImport),
        transaction(18, title: "Tax Refund", date: date(daysAgo: 68), kind: .income(.refund), amount: amount("486.22"), sourceAccountId: ID.checking),
        transaction(19, title: "Retirement Contribution", date: date(daysAgo: 73), kind: .transfer(.retirement, destinationAccountId: ID.retirement), amount: amount("300.00"), sourceAccountId: ID.checking),
        transaction(20, title: "Brokerage Transfer", date: date(daysAgo: 80), kind: .transfer(.investment, destinationAccountId: ID.investment), amount: amount("250.00"), sourceAccountId: ID.checking)
    ]

    private static func date(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }

    private static func amount(_ value: String) -> Decimal {
        Decimal(string: value) ?? 0
    }

    private static func transaction(
        _ id: Int,
        title: String,
        date: Date,
        kind: TransactionKind,
        amount: Decimal,
        sourceAccountId: UUID,
        importBatchId: UUID? = nil
    ) -> Transaction {
        Transaction(
            id: transactionID(id),
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            sourceAccountId: sourceAccountId,
            importBatchId: importBatchId
        )
    }

    private static func transactionID(_ id: Int) -> UUID {
        UUID(uuidString: String(format: "30000000-0000-0000-0000-%012d", id))!
    }
}
