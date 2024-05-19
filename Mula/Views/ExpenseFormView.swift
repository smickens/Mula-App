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
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0.0
    @State private var category: Category = .misc

    var body: some View {
        ExpenseFormView(title: $title, date: $date, amount: $amount, category: $category)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button{
                        saveExpense()
                    } label: {
                        Text("Save Expense")
                    }
                    .disabled(!isFormValid)
                }
            }
    }

    private var isFormValid: Bool {
        return title.trimmingCharacters(in: .whitespaces).count > 0 && amount > 0
    }

    private func saveExpense() {
        // Handle saving the new expense, for example, you could add it to an array or store it in a database.
        let expenseAmount = category == .income ? amount : -amount
        
        let newExpense = Expense(title: title, date: date, amount: expenseAmount, category: category)
        modelContext.insert(newExpense)

        // Reset the form after saving the expense
        title = ""
        date = Date()
        amount = 0.0
        category = .misc

        dismiss()
    }
}

struct EditExpenseFormView: View {
    @Binding public var showingEditExpenseForm: Bool
    @Bindable var expense: Expense
    
    var body: some View {
        ExpenseFormView(title: $expense.title, date: $expense.date, amount: $expense.amount, category: $expense.category)
    }
}

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var date: Date
    @Binding var amount: Double
    @Binding var category: Category

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
    }

    private var isFormValid: Bool {
        return title.trimmingCharacters(in: .whitespaces).count > 0 && amount > 0
    }
}

//#Preview {
//    ExpenseFormView(showingExpenseForm: .constant(true), expense: <#Expense#>)
//}
