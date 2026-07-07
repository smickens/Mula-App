//
//  WellsFargoImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

extension ImportFormat {
    static let wellsFargo = ImportFormat(
        source: .wellsFargo,
        matches: { headers in
            headers.containsAll(["DATE", "DESCRIPTION", "AMOUNT"])
        },
        rowResult: { table, row in
            let dateString = table.value(in: row, for: "DATE")
            let title = table.value(in: row, for: "DESCRIPTION")
            let amountString = table.value(in: row, for: "AMOUNT")

            guard !title.isEmpty else {
                return .skip(.missingRequiredValue("DESCRIPTION"))
            }

            guard title != "ONLINE ACH PAYMENT THANK YOU",
                  title != "ONLINE PAYMENT THANK YOU" else {
                return .skip(.ignoredTransaction("Credit card payment"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let transaction = ImportedTransactionCandidate(
                title: title,
                date: date,
                signedAmount: signedAmount,
                kind: AmountSignConvention.negativeIsExpense.defaultKind(for: signedAmount, expenseKind: .expense(.eatingOut)),
                sourceAccountId: ImportSource.wellsFargo.accountId
            )
            .applyingGlobalRules()
            .applyingBankRules(BankImportRules.wellsFargo)
            .transaction

            return .parsed(transactions: [transaction], accountStatements: [])
        }
    )
}
