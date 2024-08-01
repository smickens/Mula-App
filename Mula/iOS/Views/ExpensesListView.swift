//
//  ExpensesListView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ExpensesListView: View {
    @Environment(DataManager.self) private var dataManger
    @Binding var selectedMonth: String

    @State private var selectedExpense: Expense? = nil
    @State private var addingNewTransaction: Bool = false
    @State private var newExpense = Expense(id: nil, title: "", date: Date(), amount: 0.0, bucket: .spending, category: .eatingOut)
//    @State private var searchText: String = ""

    var body: some View {
        VStack {
            HStack {
                HeaderView(title: "Expenses", selectedMonth: $selectedMonth)
                    .padding()

                Spacer(minLength: 0)

                Button {
                    addingNewTransaction.toggle()
                } label: {
                    Text("Add")
                }
                .padding(.trailing)
            }

            List(dataManger.expensesForSelectedMonth, id: \.id) { expense in
                ExpenseView(expense: expense)
                    .expenseSwipeActions {
                        selectedExpense = expense
                    } onDelete: {
                        guard let expenseID = expense.id else {
                            print("Error expense does not have a id, cannot complete delete action")
                            return
                        }

                        dataManger.deleteExpense(id: expenseID)
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

    
}
