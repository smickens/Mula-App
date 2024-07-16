//
//  ExpensesListView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ExpensesListView: View {
    @State private var searchText: String = ""
    @State private var selectedMonth: String = Date().month
    @State private var expenses: [Expense] = []

    var body: some View {
        VStack {
            HeaderView(title: "Expenses", selectedMonth: $selectedMonth)

            List(expenses) { expense in
                ExpenseView(expense: expense, swipeActionsEnabled: true)
            }
            .searchable(text: $searchText)
        }
        .onChange(of: selectedMonth) { _, newValue in
            expenses = DataManager.shared.expenses(for: newValue)
        }
    }
}

#Preview {
    ExpensesListView()
}
