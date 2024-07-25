//
//  TransactionEditView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

import SwiftUI

struct ExpenseEditView: View {
    @Environment(DataManager.self) private var dataManger
    @Bindable var expense: Expense

    var body: some View {
        TransactionFormView(
            id: expense.id,
            title: $expense.title,
            amount: $expense.amount,
            date: $expense.date,
            bucket: $expense.bucket,
            category: $expense.category
        ) {
            dataManger.updateExpense(expense: expense)
        }
    }
}

struct IncomeEditView: View {
    @Environment(DataManager.self) private var dataManger
    @Bindable var income: Income

    var body: some View {
        TransactionFormView(
            id: income.id,
            title: $income.title,
            amount: $income.amount,
            date: $income.date,
            bucket: .constant(Bucket.income),
            category: .constant(Category.misc)
        ) {
            dataManger.updateIncome(income: income)
        }
    }
}
