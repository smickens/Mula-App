//
//  ExpensesListView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ExpensesListView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var selectedMonth: String

    @State private var searchText: String = ""
    @State private var expenses: [Expense] = []

    var body: some View {
        VStack {
            HeaderView(title: "Expenses", selectedMonth: $selectedMonth)
                .padding()

            List(expenses) { expense in
                TransactionView(expense: expense)
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            navigationPath.append(expense)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.yellow)
                    }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            print("delete item: \(expense.id) w/ title \(expense.title)")
                            // TODO: DataManager.delete(expense.id)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
            }
            .listStyle(.plain)
            .listItemTint(Color(.systemGray6))
        }
        // TODO: might move up to the contentview layer
        .onAppear {
            expenses = DataManager.shared.expenses(for: selectedMonth)
        }
        .onChange(of: selectedMonth) { _, newValue in
            expenses = DataManager.shared.expenses(for: newValue)
        }
    }
}

//#Preview {
//    ExpensesListView(selectedMonth: .constant("May"))
//}
