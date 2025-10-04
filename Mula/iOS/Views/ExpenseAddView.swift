//
//  TransactionAddView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

//import SwiftUI
//
//struct ExpenseAddView: View {
//    @Environment(DataManager.self) private var dataManager
//    @Bindable var expense: Expense
//
//    var body: some View {
//        ExpenseFormView(
//            id: nil,
//            title: $expense.title,
//            amount: $expense.amount,
//            date: $expense.date,
//            bucket: $expense.bucket,
//            category: $expense.category
//        ) {
//            if let expenseCopy = expense.copy() as? Expense {
//                dataManager.addExpense(expense: expenseCopy)
//                clearExpenseValues()
//            } else {
//                print("Error copying expense")
//            }
//        }
//    }
//
//    private func clearExpenseValues() {
//        expense.id = nil
//        expense.title = ""
//        expense.amount = 0
//        expense.date = Date()
//        expense.bucket = .spending
//        expense.category = .eatingOut
//    }
//}
