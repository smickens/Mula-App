//
//  UploadFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/24.
//

import SwiftUI

struct UploadFormView: View {
    @Binding var showingUploadExpensesForm: Bool
    @Binding var newExpenses: [Expense]
    @State private var selectedExpense: Expense?

    @State private var editedTitle: String = ""
    @State private var editedAmount: Double = 0.0
    @State private var editedCategory: Category = .misc
    @State private var editedDate: Date = Date()

    var body: some View {
        VStack {
            Text("Confirm Expenses")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                List(newExpenses, selection: $selectedExpense) { expense in
                    ExpenseView(expense: expense, swipeActionsEnabled: false)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                newExpenses.removeAll { $0.id == expense.id }
                                ExpenseRepository.shared.deleteExpense(expense: expense)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(selectedExpense == expense ? Color.gray.opacity(0.2) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedExpense = expense
                            }
                        }
                }
                .frame(width: 340)

                VStack {
                    Form {
                        TextField("Title", text: $editedTitle, prompt: Text("Groceries"))
                            .onChange(of: editedTitle) { _, newValue in
                                selectedExpense?.title = editedTitle
                            }

                        TextField("Amount", value: $editedAmount, format: .currency(code: "USD"))
                            .onChange(of: editedAmount) { _, newValue in
                                selectedExpense?.amount = editedAmount
                            }

                        Picker("Category", selection: $editedCategory) {
                            ForEach(Category.allCases, id: \.self) { category in
                                Text(category.name)
                            }
                        }
                        .onChange(of: editedCategory) { _, newValue in
                            selectedExpense?.category = editedCategory
                        }

                        DatePicker("Date", selection: $editedDate, in: ...Date(), displayedComponents: .date)
                            .onChange(of: editedDate) { _, newValue in
                                selectedExpense?.date = editedDate
                            }
                    }
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .frame(width: 600, height: 340)
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button{
                    clearAllNewExpenses()
                    showingUploadExpensesForm.toggle()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.red)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button{
                    saveNewExpenses()
                } label: {
                    Text("Save New Expenses")
                }
            }
        }
        .onAppear {
            selectedExpense = newExpenses.first
        }
        .onChange(of: selectedExpense) { _, newValue in
            guard let newValue else { return }
            editedTitle = newValue.title ?? ""
            editedAmount = newValue.amount
            editedCategory = newValue.category
            editedDate = newValue.date ?? Date()
        }
    }

    private func saveNewExpenses() {
        ExpenseRepository.shared.saveContext()

        showingUploadExpensesForm = false
    }

    private func clearAllNewExpenses() {
        for expense in newExpenses {
            ExpenseRepository.shared.deleteExpense(expense: expense)
        }
    }
}

//#Preview {
//    UploadFormView()
//}
