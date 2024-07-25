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
    @State private var selectedIncome: Income? = nil
//    @State private var searchText: String = ""

    var body: some View {
        VStack {
            HeaderView(title: "Expenses", selectedMonth: $selectedMonth)
                .padding()

            List(dataManger.transactionsForSelectedMonth, id: \.id) { transaction in
                if let expense = transaction as? Expense {
                    ExpenseView(expense: expense)
                        .transactionSwipeActions {
                            selectedExpense = expense
                        } onDelete: {
                            dataManger.deleteExpense(id: expense.id)
                        }
                } else if let income = transaction as? Income {
                    IncomeView(income: income)
                        .transactionSwipeActions {
                            selectedIncome = income
                        } onDelete: {
                            dataManger.deleteIncome(id: income.id)
                        }

                } else {
                    Text("Error displaying transaction id \(transaction.id)")
                }
            }
            .listStyle(.plain)
            .listItemTint(Color(.systemGray6))
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseEditView(expense: expense)
                .presentationDetents([.height(500)])
        }
        .sheet(item: $selectedIncome) { income in
            IncomeEditView(income: income)
                .presentationDetents([.height(500)])
        }
    }

    
}

//#Preview {
//    ExpensesListView(selectedMonth: .constant("May"))
//}
