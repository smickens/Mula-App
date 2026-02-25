//
//  TransactionAdditions.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/26.
//

extension Array where Element == Transaction {

    func totalSpending(for accountId: UUID) -> Decimal {
        self.flatMap { $0.entries }
            .filter { $0.accountId == accountId && $0.amount < 0 }
            .reduce(0, +)
    }

    func totalIncome(for accountId: UUID) -> Decimal {
        self.flatMap { $0.entries }
            .filter { $0.accountId == accountId && $0.amount > 0 }
            .reduce(0, +)
    }

    func categoryTotals(for accountId: UUID) -> [String: Decimal] {
        var totals: [String: Decimal] = [:]
        for transaction in self {
            for entry in transaction.entries where entry.accountId == accountId {
                guard let category = entry.category else { continue }
                totals[category.id, default: 0] += entry.amount
            }
        }
        return totals
    }
}
