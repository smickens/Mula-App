//
//  EditExpenseFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//


import SwiftUI

struct EditExpenseFormView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @Bindable var expense: Expense

    @State private var title: String
    @State private var date: Date
    @State private var amount: Double
    @State private var category: Category

    init(expense: Expense) {
        self.expense = expense
        _title = State(initialValue: expense.title)
        _date = State(initialValue: expense.date)
        _amount = State(initialValue: expense.amount)
        _category = State(initialValue: expense.category)
    }

    var body: some View {
        ExpenseFormView(
            title: $title,
            date: $date,
            amount: $amount,
            category: $category,
            formTitle: "Edit Expense"
        ) {
            expense.title = title
            expense.date = date
            expense.amount = amount
            expense.category = category
            dataManager.updateExpense(expense: expense)
            dismiss()
        }
    }
}
