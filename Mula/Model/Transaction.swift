//
//  Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import Foundation
import SwiftUI

// TODO: may add some kind of willBePaidBack / willBeReimbursed
// often i may order something knowing someone is going to pay me back fully for it, or even partially
// it'd be good to capture that and allow the TrendsView to take that into account
// then maybe trends can have a toggle for "My Spending" vs. "All Spending" (Profit vs. Revenue in reverse)

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID

    // TODO: later try to change to let
    var title: String
    var date: Date
    var kind: TransactionKind
    var amount: Decimal
    var sourceAccountId: UUID
    var importBatchId: UUID?

    var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? kind.defaultTitle : trimmedTitle
    }

    func amountSigned(displayingAccountId: UUID? = nil) -> Decimal {
        switch kind {
        case .expense:
            return -amount
        case .income:
            return amount
        case .transfer:
            guard let displayingAccountId else { return amount }
            let isTransferOut = displayingAccountId == sourceAccountId
            return isTransferOut ? -amount : amount
        }
    }

    func amountColor(displayingAccountId: UUID? = nil) -> Color {
        switch kind {
        case .expense:
            return .red
        case .income:
            return .green
        case .transfer(_, let destinationAccountId):
            guard let displayingAccountId else { return .gray }
            let isTransferOut = displayingAccountId == sourceAccountId
            let isTransferIn = displayingAccountId == destinationAccountId
            return isTransferOut ? .red : (isTransferIn ? .green : .gray)
        }
    }
}

enum TransactionKind: Codable, Hashable {
    case expense(ExpenseCategory)
    case income(IncomeCategory)
    case transfer(_ category: TransferCategory, destinationAccountId: UUID = Account.default)

    struct ExpenseDetails {
        let category: ExpenseCategory
    }
    struct IncomeDetails {
        let category: ExpenseCategory
    }
    struct TransferDetails {
        let category: TransferCategory
        let destinationAccountId: UUID = Account.default
    }

    // TODO: rename categoryDisplayName or don't have the convenience accessor here ?
    var displayName: String {
        switch self {
        case .expense(let category): return category.displayName
        case .income(let category): return category.displayName
        case .transfer(let category, _): return category.displayName
        }
    }

    var isExpense: Bool {
        if case .expense = self { return true }
        return false
    }

    var isIncome: Bool {
        if case .income = self { return true }
        return false
    }
}

extension Transaction {

    /// Computed property to get/set the category for the current transaction kind
    var category: any TransactionCategoryProtocol {
        get {
            switch kind {
            case .expense(let c): return c
            case .income(let c): return c
            case .transfer(let c, _): return c
            }
        }
    }
}
