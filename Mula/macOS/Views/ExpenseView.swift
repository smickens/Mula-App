//
//  ExpenseView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

#if os(macOS)
    @Binding var selectedExpense: Expense?
    @State private var showingEditExpenseForm = false
    let swipeActionsEnabled: Bool = true
#endif
    let expense: Expense

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(expense.bucket.tint)
                    .frame(width: 35, height: 35)

                Image(systemName: expense.category.iconName)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading) {
                Text(expense.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(formatDate(expense.date))
                    .font(.caption)
            }

            Spacer()

            Text(expense.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(expenseColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(expenseColor.opacity(0.2))
                )
        }
        .padding(5)
#if os(macOS)
        .contentShape(Rectangle())
        .gesture(tapGesture)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedExpense == expense ? .gray.opacity(0.2) : .clear)
        )
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button {
                    selectedExpense = expense

                    showingEditExpenseForm.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.yellow)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button(role: .destructive) {
                    print("delete item: \(expense.id) w/ title \(expense.title)")
                    // TODO: DataManager.delete(expense.id)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
#endif
#if os(iOS)
        .navigationDestination(for: Expense.self) { expense in
            TransactionEditView(transaction: expense)
        }
#elseif os(macOS)
        .sheet(isPresented: $showingEditExpenseForm) {
            EditExpenseFormView(expense: expense)
        }
#endif
    }

#if os(macOS)
    private var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                // first tap
                selectedExpense = expense
            }
            .simultaneously(with: TapGesture(count: 2)
                .onEnded {
                    // double tap
                    if swipeActionsEnabled {
                        showingEditExpenseForm.toggle()
                    }
                }
            )
    }
#endif

    private var expenseColor: Color {
        return expense.amount > 0 ? .green : .red
    }

    private func formatDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        return dateFormatter.string(from: date ?? Date())
    }
}

//#Preview {
//    ExpenseView()
//}
