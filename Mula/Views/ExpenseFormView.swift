//
//  ExpenseFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

// TODO: have date start at 1st of month selected or current date if in the selected month

struct ExpenseFormView: View {
    @Binding public var showingExpenseForm: Bool
    @State private var id: UUID = UUID()
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0.0
    @State private var category: Category = .misc
    @State private var isIncome: Bool = false
    var isEdit: Bool

    init(showingExpenseForm: Binding<Bool>, expense: Expense? = nil) {
        _showingExpenseForm = showingExpenseForm
        if let expense {
            _id = State(initialValue: expense.id ?? UUID())
            _title = State(initialValue: expense.title ?? "")
            _date = State(initialValue: expense.date ?? Date())
            _amount = State(initialValue: abs(expense.amount))
            _category = State(initialValue: expense.category)
            _isIncome = State(initialValue: expense.amount > 0)
        }
        isEdit = expense != nil
    }

    var body: some View {
        VStack {
            Text("Details")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            Form {
                TextField("Title", text: $title, prompt: Text("Groceries"))

                HStack {
                    TextField("Amount", value: $amount, format: .currency(code: "USD"))

                    Toggle("Is Income?", isOn: $isIncome)
                        .toggleStyle(.checkbox)
                }

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
                    showingExpenseForm.toggle()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.red)
            }

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
        if isEdit {
            ExpenseRepository.shared.updateExpense(id: id, newTitle: title, newDate: date, newAmount: isIncome ? amount : -amount, newCategory: category)
        } else {
            ExpenseRepository.shared.saveNewExpense(id: id, title: title, date: date, amount: isIncome ? amount : -amount, category: category)
        }

        // Reset the form after saving the expense
        title = ""
        date = Date()
        amount = 0.0
        category = .misc

        showingExpenseForm = false
    }
}

//#Preview {
//    ExpenseFormView(showingExpenseForm: .constant(true), expense: <#Expense#>)
//}
