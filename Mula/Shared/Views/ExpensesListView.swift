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

    @State private var selected: Transaction? = nil
    @State private var showingTransactionDetailView: Bool = false
    @State private var searchText: String = ""
    @State private var transactions: [Transaction] = []

    var body: some View {
        VStack {
            HeaderView(title: "Expenses", selectedMonth: $selectedMonth)
                .padding()

            List(transactions, id: \.id) { transaction in
                TransactionView(transaction: transaction)
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            selected = transaction
                            showingTransactionDetailView.toggle()
//                            navigationPath.append(expense)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            print("delete item: \(transaction.id) w/ title \(transaction.title)")
                            // TODO: DataManager.delete(expense.id)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
            }
            .listStyle(.plain)
            .listItemTint(Color(.systemGray6))
            .sheet(isPresented: $showingTransactionDetailView) {
                if let selected {
                    TransactionEditView(transaction: selected)
                        .presentationDetents([.height(500)]) // Half-sheet height
                }
            }
        }
        // TODO: might move up to the contentview layer
        .onAppear {
            transactions = DataManager.shared.expenses(for: selectedMonth) + DataManager.shared.incomes(for: selectedMonth)
        }
        .onChange(of: selectedMonth) { _, newValue in
            transactions = DataManager.shared.expenses(for: newValue) + DataManager.shared.incomes(for: newValue)
        }
    }
}

//#Preview {
//    ExpensesListView(selectedMonth: .constant("May"))
//}
