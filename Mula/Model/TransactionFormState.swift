//
//  TransactionFormState.swift
//  Mula
//
//  Created by Shanti Mickens on 2/22/26.
//

import Foundation

struct TransactionFormState {
    var id: UUID?
    var title: String = ""
    var date: Date = Date()
    var amountString: String = ""

    var type: TransactionKindType = .expense

    var expenseCategory: ExpenseCategory = .other
    var incomeCategory: IncomeCategory = .other
    var transferCategory: TransferCategory = .savings
    
    var sourceAccountId: UUID = Account.default
    var destinationAccountId: UUID = Account.default

    var category: any TransactionCategoryProtocol {
        switch type {
        case .expense: return expenseCategory
        case .income: return incomeCategory
        case .transfer: return transferCategory
        }
    }
}

enum TransactionKindType: CaseIterable, Hashable, Identifiable {
    case expense
    case income
    case transfer

    var id: Self { self }

    var displayName: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .transfer: return "Transfer"
        }
    }
}

extension TransactionFormState {

    // Performs validation on form values throws errors if a check fails
    func toTransaction() throws -> Transaction {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TransactionValidationError.emptyTitle
        }

        guard let amount = Decimal(string: amountString),
              amount != 0 else {
            throw TransactionValidationError.invalidAmount
        }

        let kind: TransactionKind

        switch type {
        case .expense:
            kind = .expense(expenseCategory)

        case .income:
            kind = .income(incomeCategory)

        case .transfer:
            guard sourceAccountId != destinationAccountId else {
                throw TransactionValidationError.invalidTransfer
            }

            kind = .transfer(transferCategory, destinationAccountId: destinationAccountId)
        }

        return Transaction(
            id: id ?? UUID(),
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            sourceAccountId: sourceAccountId
        )
    }
}

extension TransactionFormState {

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.title = transaction.title
        self.date = transaction.date
        self.amountString = Self.decimalToString(transaction.amount)
        self.sourceAccountId = transaction.sourceAccountId

        switch transaction.kind {

        case .expense(let category):
            self.type = .expense
            self.expenseCategory = category

        case .income(let category):
            self.type = .income
            self.incomeCategory = category

        case .transfer(let category, let destinationAccountId):
            self.type = .transfer
            self.transferCategory = category
            self.destinationAccountId = destinationAccountId
        }
    }

    static func decimalToString(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: decimal as NSDecimalNumber) ?? ""
    }
}


enum TransactionValidationError: LocalizedError {
    case invalidAmount
    case emptyTitle
    case invalidTransfer

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Please enter a valid amount."
        case .emptyTitle:
            return "Title cannot be empty."
        case .invalidTransfer:
            return "Transfer requires different source and destination accounts."
        }
    }
}

