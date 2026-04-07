//
//  TransactionView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct TransactionView: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedTransactionID: UUID?
    @State private var showingEditTransactionForm = false

    let swipeActionsEnabled: Bool
    let transaction: Transaction
    let displayingAccountId: UUID?

    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.baseColor)
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
            Text(amountSigned, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(amountColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(amountColor.opacity(0.2))
                )
        }
        .padding(5)
        .contentShape(Rectangle())
        .gesture(tapGesture)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button {
                    selectedTransactionID = transaction.id
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

    private var amountSigned: Decimal {
        transaction.amountSigned(displayingAccountId: displayingAccountId)
    }

    private var amountColor: Color {
        transaction.amountColor(displayingAccountId: displayingAccountId)
    }

    // MARK: - Gestures

    private var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedTransactionID = transaction.id
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
