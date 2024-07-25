//
//  TransactionAddView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

import SwiftUI

struct TransactionAddView: View {
    @Environment(DataManager.self) private var dataManager
    @Bindable var expense: Expense

    var body: some View {
        TransactionFormView(
            id: nil,
            title: $expense.title,
            amount: $expense.amount,
            date: $expense.date,
            bucket: $expense.bucket,
            category: $expense.category
        ) {
            if expense.bucket != .income {
                dataManager.addExpense(expense: expense)
            } else {
                let income = Income(id: expense.id, title: expense.title, date: expense.date, amount: expense.amount)
                dataManager.addIncome(income: income)
            }
        }
    }
}
