//
//  Fidelity401kImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

extension ImportFormat {
    static let fidelity401k = ImportFormat(
        source: .fidelity401k,
        matches: { headers in
            headers.containsAll(["Run Date", "Action", "Description", "Amount ($)"])
        },
        rowResult: { table, row in
            let action = table.value(in: row, for: "Action")

            guard action.caseInsensitiveCompare("Contributions") == .orderedSame else {
                return .skip(.ignoredTransaction(action))
            }

            let dateString = table.value(in: row, for: "Run Date")
            let description = table.value(in: row, for: "Description")
            let amountString = table.value(in: row, for: "Amount ($)")

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let descriptionText = description.isEmpty ? "(No Desc)" : description

            let transaction = ImportedTransactionCandidate(
                title: "Contributions - \(descriptionText)",
                date: date,
                signedAmount: signedAmount,
                kind: .saving(.contribution),
                sourceAccountId: ImportSource.fidelity401k.accountId
            )
            .transaction

            return .parsed(transactions: [transaction], accountStatements: [])
        }
    )
}
