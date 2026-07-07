//
//  FidelityInvestmentsImportFormat.swift
//  Mula
//
//  Created by Codex on 6/7/26.
//

import Foundation

extension ImportFormat {
    static let fidelityInvestments = ImportFormat(
        source: .fidelityInvestments,
        matches: { headers in
            headers.containsAll([
                "Monthly",
                "Beginning balance",
                "Market change",
                "Dividends",
                "Interest",
                "Deposits",
                "Withdrawals",
                "Net advisory fees",
                "Ending balance"
            ])
        },
        rowResult: { table, row in
            let monthLabel = table.value(in: row, for: "Monthly")

            if monthLabel.isEmpty || monthLabel.hasPrefix("Total") {
                return .stop
            }

            guard let monthEndDate = monthEndDate(from: monthLabel) else {
                return .skip(.invalidDate(monthLabel))
            }

            let beginningBalanceString = table.value(in: row, for: "Beginning balance")
            let endingBalanceString = table.value(in: row, for: "Ending balance")

            guard parseCurrency(beginningBalanceString) != nil else {
                return .skip(.invalidAmount(beginningBalanceString))
            }

            guard let endingBalance = parseCurrency(endingBalanceString) else {
                return .skip(.invalidAmount(endingBalanceString))
            }

            let rowDefinitions: [(header: String, title: String, kind: TransactionKind)] = [
                ("Dividends", "Dividend Income", .income(.dividend)),
                ("Interest", "Interest Income", .income(.interest)),
                ("Deposits", "Investment Deposit", .saving(.contribution)),
                ("Withdrawals", "Investment Withdrawal", .saving(.withdrawal)),
                ("Net advisory fees", "Advisory Fee", .expense(.other))
            ]

            var transactions: [Transaction] = []

            for definition in rowDefinitions {
                let amountString = table.value(in: row, for: definition.header)

                guard let amount = parseCurrency(amountString) else {
                    return .skip(.invalidAmount(amountString))
                }

                guard amount != 0 else { continue }

                transactions.append(
                    Transaction(
                        id: UUID(),
                        title: definition.title,
                        date: monthEndDate,
                        kind: definition.kind,
                        amount: amount.magnitude,
                        sourceAccountId: ImportSource.fidelityInvestments.accountId
                    )
                )
            }

            let statement = AccountStatement(
                accountId: ImportSource.fidelityInvestments.accountId,
                date: monthEndDate,
                balance: endingBalance
            )

            return .parsed(transactions: transactions, accountStatements: [statement])
        }
    )
}
