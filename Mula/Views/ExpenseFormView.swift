//
//  ExpenseFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

// TODO: have date start at 1st of month selected or current date if in the selected month

struct NewExpenseFormView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0.0
    @State private var category: Category = .misc

    var body: some View {
        ExpenseFormView(title: $title, date: $date, amount: $amount, category: $category, save: save)
    }

    private func save() {
        // Handle saving the new expense, for example, you could add it to an array or store it in a database.
        let expenseAmount = category == .income ? amount : -amount
        let newExpense = Expense(title: title, date: date, amount: expenseAmount, category: category)
        modelContext.insert(newExpense)
    }
}

struct EditExpenseFormView: View {
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
        ExpenseFormView(title: $title, date: $date, amount: $amount, category: $category, save: save)
    }
    
    func save() {
        expense.title = title
        expense.date = date
        expense.amount = amount
        expense.category = category
    }
}

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var date: Date
    @Binding var amount: Double
    @Binding var category: Category
    
    let save: (() -> Void)

    var body: some View {
        VStack {
            Text("Details")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            Form {
                TextField("Title", text: $title, prompt: Text("Groceries"))

                TextField("Amount", value: $amount, format: .currency(code: "USD"))

                Picker("Category", selection: $category) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.name)
                    }
                }

                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)

            Spacer()
        }
        .frame(width: 320, height: 220)
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button{
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.red)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button{
                    save()
                    dismiss()
                } label: {
                    Text("Save")
                }
                .disabled(!isFormValid)
            }
        }
    }

    private var isFormValid: Bool {
        return title.trimmingCharacters(in: .whitespaces).count > 0 && amount != 0
    }
}
