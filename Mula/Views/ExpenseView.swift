//
//  ExpenseView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var showingEditExpenseForm = false
    let expense: Expense
    let swipeActionsEnabled: Bool

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(expense.category.tintColor)
                    .frame(width: 35, height: 35)

                expense.category.icon
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
                .font(.title3)
                .foregroundStyle(expenseColor)
                .fontWeight(.medium)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(expenseColor.opacity(0.2))
                )
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button {
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
                    modelContext.delete(expense)
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
        .sheet(isPresented: $showingEditExpenseForm) {
            EditExpenseFormView(expense: expense)
        }
    }

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
//    ExpenseView(expense: Expense(name: "Rent", date: Date(), amount: 57.81, category: .housing))
//}
