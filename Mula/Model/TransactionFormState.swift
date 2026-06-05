//
//  TransactionFormState.swift
//  Mula
//
//  Created by Shanti Mickens on 2/22/26.
//

import Foundation
import MulaCore

struct TransactionFormState {
    var id: UUID?
    var title: String = ""
    var date: Date = Date()
    var amountString: String = ""
    var myShareAmountString: String = ""

    var type: TransactionKindType = .expense

    var expenseCategory: ExpenseCategory = .other
    var incomeCategory: IncomeCategory = .other
    var savingCategory: SavingCategory = .contribution
    var transferCategory: TransferCategory = .savings
    
    var sourceAccountId: UUID = Account.default
    var destinationAccountId: UUID = Account.default

    var importBatchId: UUID? = nil

    var category: any TransactionCategoryProtocol {
        switch type {
        case .expense: return expenseCategory
        case .income: return incomeCategory
        case .saving: return savingCategory
        case .transfer: return transferCategory
        }
    }
}

enum TransactionKindType: CaseIterable, Hashable, Identifiable {
    case expense
    case income
    case saving
    case transfer

    var id: Self { self }

    static var formSelectableCases: [TransactionKindType] {
        [.expense, .income, .saving]
    }

    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .saving: return "Saving"
        case .transfer: return "Transfer"
        }
    }

    var showsTitleField: Bool {
        switch self {
        case .expense, .income, .transfer:
            return true
        case .saving:
            return false
        }
    }
}

extension TransactionFormState {

    // Performs validation on form values throws errors if a check fails
    func toTransaction() throws -> Transaction {
        guard let amount = Decimal.formattedDecimal(from: amountString),
              amount != 0 else {
            throw TransactionValidationError.invalidAmount
        }

        let kind: TransactionKind

        switch type {
        case .expense:
            try validateTitle()
            kind = .expense(expenseCategory)

        case .income:
            try validateTitle()
            kind = .income(incomeCategory)

        case .saving:
            kind = .saving(savingCategory)

        case .transfer:
            try validateTitle()
            guard sourceAccountId != destinationAccountId else {
                throw TransactionValidationError.invalidTransfer
            }

            kind = .transfer(transferCategory, destinationAccountId: destinationAccountId)
        }

        let myShareAmount = try myShareAmount(for: kind, amount: amount)

        return Transaction(
            id: id ?? UUID(),
            title: title(for: kind),
            date: date,
            kind: kind,
            amount: amount,
            myShareAmount: myShareAmount,
            sourceAccountId: sourceAccountId,
            importBatchId: importBatchId
        )
    }

    private func validateTitle() throws {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TransactionValidationError.emptyTitle
        }
    }

    private func title(for kind: TransactionKind) -> String {
        switch kind {
        case .saving:
            return title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : title
        case .expense, .income, .transfer:
            return title
        }
    }

    private func myShareAmount(for kind: TransactionKind, amount: Decimal) throws -> Decimal? {
        guard kind.isExpense else { return nil }

        let trimmedMyShareAmount = myShareAmountString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMyShareAmount.isEmpty else { return nil }
        guard let myShareAmount = Decimal.formattedDecimal(from: trimmedMyShareAmount),
              myShareAmount >= 0,
              myShareAmount <= amount else {
            throw TransactionValidationError.invalidMyShareAmount
        }

        return myShareAmount
    }
}

extension TransactionFormState {

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.title = transaction.title
        self.date = transaction.date
        self.amountString = transaction.amount.toDecimalString()
        self.myShareAmountString = transaction.myShareAmount?.toDecimalString() ?? ""
        self.sourceAccountId = transaction.sourceAccountId
        self.importBatchId = transaction.importBatchId

        switch transaction.kind {

        case .expense(let category):
            self.type = .expense
            self.expenseCategory = category

        case .income(let category):
            self.type = .income
            self.incomeCategory = category

        case .saving(let category):
            self.type = .saving
            self.savingCategory = category

        case .transfer(let category, let destinationAccountId):
            self.type = .transfer
            self.transferCategory = category
            self.destinationAccountId = destinationAccountId
        }
    }

}


enum TransactionValidationError: LocalizedError {
    case invalidAmount
    case invalidMyShareAmount
    case emptyTitle
    case invalidTransfer

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount."
        case .invalidMyShareAmount:
            return "My Share must be between $0 and the full amount."
        case .emptyTitle:
            return "Title cannot be empty."
        case .invalidTransfer:
            return "Transfer requires different source and destination accounts."
        }
    }
}
