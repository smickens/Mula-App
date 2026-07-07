//
//  AppleImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

extension ImportFormat {
    static let apple = ImportFormat(
        source: .apple,
        matches: { headers in
            headers.containsAll(["Transaction Date", "Merchant", "Category", "Amount (USD)"])
        },
        rowResult: { table, row in
            let dateString = table.value(in: row, for: "Transaction Date")
            let merchant = table.value(in: row, for: "Merchant")
            let category = table.value(in: row, for: "Category")
            let amountString = table.value(in: row, for: "Amount (USD)")

            guard !merchant.isEmpty else {
                return .skip(.missingRequiredValue("Merchant"))
            }

            guard category != "Payment" else {
                return .skip(.ignoredTransaction("Credit card payment"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let baseKind = AmountSignConvention.positiveIsExpense.defaultKind(
                for: signedAmount,
                expenseKind: TransactionKind.expenseCategoryFromCreditCard(category)
            )
            let transaction = ImportedTransactionCandidate(
                title: merchant,
                date: date,
                signedAmount: signedAmount,
                kind: baseKind,
                sourceAccountId: ImportSource.apple.accountId
            )
            .applyingGlobalRules()
            .applyingBankRules(BankImportRules.apple)
            .transaction

            return .parsed(transactions: [transaction], accountStatements: [])
        }
    )
}
