//
//  ExpenseView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

//import SwiftUI
//
//struct ExpenseView: View {
//    @Bindable var expense: Expense
//
//    var body: some View {
//        HStack {
//            ZStack {
//                Circle()
//                    .fill(expense.category.tintColor)
//                    .frame(width: 35, height: 35)
//
//                Image(systemName: expense.category.iconName)
//                    .foregroundColor(.white)
//            }
//
//            VStack(alignment: .leading, spacing: 5) {
//                Text(expense.title)
//                    .font(.headline)
//                    .lineLimit(1)
//
//                HStack(spacing: 5) {
//                    Text(expense.bucket.name)
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundStyle(Color(.systemGray))
//                        .padding(.vertical, 2)
//                        .padding(.horizontal, 4)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(3.0)
//                        .padding(0)
//
//                    Text(formatDate(expense.date))
//                        .font(.caption)
//                }
//            }
//
//            Spacer()
//
//            ExpenseAmountView(amount: expense.amount)
//        }
//    }
//
//    private func formatDate(_ date: Date?) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMM d"
//        return dateFormatter.string(from: date ?? Date())
//    }
//}
