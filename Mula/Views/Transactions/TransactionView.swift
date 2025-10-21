//
//  ExpenseView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct TransactionView: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedTransaction: Transaction?
    @State private var showingEditTransactionForm = false

    let swipeActionsEnabled: Bool
    let transaction: Transaction

    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.tintColor)
                    .frame(width: 35, height: 35)

                Image(systemName: transaction.category.iconName)
                    .foregroundColor(.white)
            }

            // Title + Date
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(formatDate(transaction.date))
                    .font(.caption)
            }

            Spacer()

            // Amount display
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(transactionColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(transactionColor.opacity(0.2))
                )
        }
        .padding(5)
        .contentShape(Rectangle())
        .gesture(tapGesture)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedTransaction?.id == transaction.id ? .gray.opacity(0.2) : .clear)
        )
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button {
                    selectedTransaction = transaction
                    showingEditTransactionForm.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.yellow)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button(role: .destructive) {
                    deleteTransaction()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
        .sheet(isPresented: $showingEditTransactionForm) {
            EditTransactionFormView(transaction: transaction)
        }
    }

    // MARK: - Gestures

    private var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedTransaction = transaction
            }
            .simultaneously(with: TapGesture(count: 2)
                .onEnded {
                    if swipeActionsEnabled {
                        showingEditTransactionForm.toggle()
                    }
                }
            )
    }

    // MARK: - Helpers

    private var transactionColor: Color {
        transaction.amount > 0 ? .green : .red
    }

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
    }

    private func deleteTransaction() {
        print("Deleting transaction: \(transaction.id) \(transaction.title)")
        dataManager.deleteTransaction(transaction)
    }
}
