//
//  ExpensesListView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ExpensesListView: View {
    @Bindable var dataManager: DataManager
    @State private var selectedExpense: Expense? = nil
    @State private var addingNewTransaction: Bool = false
    @State private var newExpense = Expense(id: nil, title: "", date: Date(), amount: 0.0, bucket: .spending, category: .eatingOut)
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Expenses", selectedMonth: $dataManager.selectedMonth)
                .padding()

            HStack {
                SearchBarView(searchText: $searchText)

                Spacer(minLength: 0)

                Button {
                    addingNewTransaction.toggle()
                } label: {
                    Image(systemName: "plus.square.fill")
                        .imageScale(.large)
                        .tint(.indigo)
                }
                .padding(.trailing)
            }
            .padding(.top, -15)

            List(searchResults, id: \.id) { expense in
                ExpenseView(expense: expense)
                    .expenseSwipeActions {
                        selectedExpense = expense
                    } onDelete: {
                        guard let expenseID = expense.id else {
                            print("Error expense does not have a id, cannot complete delete action")
                            return
                        }

                        dataManager.deleteExpense(id: expenseID)
                    }
            }
            .listStyle(.plain)
            .listItemTint(Color(.systemGray6))
        }
        .sheet(isPresented: $addingNewTransaction) {
            ExpenseAddView(expense: newExpense)
                .presentationDetents([.height(500)])
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseEditView(expense: expense)
                .presentationDetents([.height(500)])
        }
    }

    var searchResults: [Expense] {
        let expenses = dataManager.expensesForSelectedMonth

        guard !searchText.isEmpty else {
            return expenses
        }

        return expenses.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
}
