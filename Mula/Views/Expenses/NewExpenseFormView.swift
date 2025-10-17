//
//  NewExpenseFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//


import SwiftUI

struct NewExpenseFormView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0.0
    @State private var category: Category = .misc

    let selectedMonth: String

    var body: some View {
        ExpenseFormView(
            title: $title,
            date: $date,
            amount: $amount,
            category: $category,
            formTitle: "New Expense"
        ) {
            let success = dataManager.addNewExpense(
                title: title,
                date: date,
                amount: amount,
                bucket: .fixed, // Placeholder for bucket logic
                category: category
            )
            print("Adding new expense: \(success ? "success" : "failed")")
            dismiss()
        }
        .onAppear {
            date = firstDayOfMonth(month: selectedMonth)
        }
    }

    private func firstDayOfMonth(month: String) -> Date {
        guard Date().month != selectedMonth else { return Date() }

        let calendar = Calendar.current
        var components = DateComponents()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"

        if let monthDate = formatter.date(from: month) {
            components.year = calendar.component(.year, from: Date())
            components.month = calendar.component(.month, from: monthDate)
            components.day = 1
        }

        return calendar.date(from: components) ?? Date()
    }
}
