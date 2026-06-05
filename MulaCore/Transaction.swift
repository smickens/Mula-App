//
//  Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import Foundation
import SwiftUI

public struct Transaction: Identifiable, Codable, Hashable {
    public let id: UUID
    public let title: String
    public let date: Date
    public let kind: TransactionKind
    public let amount: Decimal
    public let myShareAmount: Decimal?
    public let sourceAccountId: UUID
    public let importBatchId: UUID?

    public init(
        id: UUID,
        title: String,
        date: Date,
        kind: TransactionKind,
        amount: Decimal,
        myShareAmount: Decimal? = nil,
        sourceAccountId: UUID,
        importBatchId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.kind = kind
        self.amount = amount
        self.myShareAmount = myShareAmount
        self.sourceAccountId = sourceAccountId
        self.importBatchId = importBatchId
    }

    public var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? kind.defaultTitle : trimmedTitle
    }

    public func amountSigned(displayingAccountId: UUID? = nil) -> Decimal {
        switch kind {
        case .expense:
            return -amount
        case .income:
            return amount
        case .saving(.contribution):
            return amount
        case .saving(.withdrawal):
            return amount
        case .transfer:
            guard let displayingAccountId else { return amount }
            let isTransferOut = displayingAccountId == sourceAccountId
            return isTransferOut ? -amount : amount
        }
    }

    public func amountColor(displayingAccountId: UUID? = nil) -> Color {
        switch kind {
        case .expense:
            return .red
        case .income:
            return .green
        case .saving(.contribution):
            return .gray
        case .saving(.withdrawal):
            return .purple
        case .transfer(_, let destinationAccountId):
            guard let displayingAccountId else { return .gray }
            let isTransferOut = displayingAccountId == sourceAccountId
            let isTransferIn = displayingAccountId == destinationAccountId
            return isTransferOut ? .red : (isTransferIn ? .green : .gray)
        }
    }

    public var mySpendingAmount: Decimal {
        guard kind.isSpendingAnalyticsEligible else { return amount }
        return myShareAmount ?? amount
    }

    public var hasCustomMyShare: Bool {
        guard kind.isSpendingAnalyticsEligible,
              let myShareAmount else {
            return false
        }

        return myShareAmount != amount
    }

    public func withImportBatchId(_ importBatchId: UUID) -> Transaction {
        Transaction(
            id: id,
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            myShareAmount: myShareAmount,
            sourceAccountId: sourceAccountId,
            importBatchId: importBatchId
        )
    }
}

public enum TransactionKind: Codable, Hashable {
    case expense(ExpenseCategory)
    case income(IncomeCategory)
    case saving(SavingCategory)
    case transfer(_ category: TransferCategory, destinationAccountId: UUID = Account.default)

    public var defaultTitle: String {
        switch self {
        case .expense(let category): return "\(category.displayName) Expense"
        case .income(let category): return category.displayName
        case .saving(.contribution): return "Add to Saving"
        case .saving(.withdrawal): return "Take Out of Saving"
        case .transfer(let category, _): return category.displayName
        }
    }

    public var isExpense: Bool {
        if case .expense = self { return true }
        return false
    }

    public var isIncome: Bool {
        if case .income = self { return true }
        return false
    }

    public var isSaving: Bool {
        if case .saving = self { return true }
        return false
    }

    public var isSavingContribution: Bool {
        if case .saving(.contribution) = self { return true }
        return false
    }

    public var isSavingWithdrawal: Bool {
        if case .saving(.withdrawal) = self { return true }
        return false
    }

    public var isSpendingAnalyticsEligible: Bool {
        isExpense
    }
}

extension Transaction {

    /// Computed property to get/set the category for the current transaction kind
    public var category: any TransactionCategoryProtocol {
        get {
            switch kind {
            case .expense(let c): return c
            case .income(let c): return c
            case .saving(let c): return c
            case .transfer(let c, _): return c
            }
        }
    }
}
