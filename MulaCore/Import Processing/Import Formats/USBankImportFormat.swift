//
//  USBankImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

extension ImportFormat {
    static let usBank = ImportFormat(
        source: .usBank,
        matches: { headers in
            headers.containsAll(["Date", "Transaction", "Name", "Memo", "Amount"])
        },
        rowResult: { table, row in
            let dateString = table.value(in: row, for: "Date")
            let title = table.value(in: row, for: "Name")
            let amountString = table.value(in: row, for: "Amount")

            guard !title.isEmpty else {
                return .skip(.missingRequiredValue("Name"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "yyyy-MM-dd") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let candidate = ImportedTransactionCandidate(
                title: title,
                date: date,
                signedAmount: signedAmount,
                kind: AmountSignConvention.negativeIsExpense.defaultKind(for: signedAmount, expenseKind: .expense(.other)),
                sourceAccountId: ImportSource.usBank.accountId
            )
            .applyingGlobalRules()

            if BankImportRules.usBankIgnoredTitles.contains(candidate.title) {
                return .skip(.ignoredTransaction(candidate.title))
            }

            return .parsed(
                transactions: [candidate.applyingBankRules(BankImportRules.usBank).transaction],
                accountStatements: []
            )
        }
    )
}
