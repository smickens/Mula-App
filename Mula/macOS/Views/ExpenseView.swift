//
//  ExpenseView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct ExpenseView: View {
    @Binding var selectedExpense: Expense?
    @State private var showingEditExpenseForm = false
    let swipeActionsEnabled: Bool
    let expense: Expense

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(expense.category.tintColor)
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
        .sheet(isPresented: $showingEditExpenseForm) {
            EditExpenseFormView(expense: expense)
        }
    }

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

    private var expenseColor: Color {
        return expense.amount > 0 ? .green : .red
    }

    private func formatDate(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date ?? Date())
    }
}

//#Preview {
//    ExpenseView()
//}
