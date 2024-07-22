//
//  TransactionEditView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct TransactionEditView: View {
    @Environment(\.dismiss) private var dismiss
    var transaction: Transaction

    @State private var editedTitle: String
    @State private var editedAmount: Double
    @State private var editedDate: Date
    @State private var editedBucket: Bucket? = nil
    @State private var editedCategory: Category? = nil

    init(transaction: Transaction) {
        self.transaction = transaction
        self.editedTitle = transaction.title
        self.editedAmount = transaction.amount
        self.editedDate = transaction.date
        if let expense = transaction as? Expense {
            self._editedBucket = State(initialValue: expense.bucket)
            self._editedCategory = State(initialValue: expense.category)
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.gray)
//                        .fontWeight(.semibold)
//                        .imageScale(.medium)
//                        .padding(3)
//                        .background(
//                            Circle()
//                                .foregroundColor(Color(.systemGray6))
//                        )
//                }
            }
            .padding(.top)

            RowView(iconName: "doc.text", title: "Title:", color: .purple) {
                TextField("Enter title", text: $editedTitle)
                    .multilineTextAlignment(.trailing)
            }

            RowView(iconName: "dollarsign.circle", title: "Amount:", color: .green) {
                TextField("Enter amount", value: $editedAmount, format: .currency(code: "USD"))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }

            RowView(iconName: "calendar", title: "Date:", color: .blue) {
                DatePicker("Select Date", selection: $editedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsVisibility(.hidden)
            }

            if let editedBucket {
                RowView(iconName: "tray", title: "Bucket:", color: .gray) {
                    Picker("", selection: $editedBucket) {
                        ForEach(Bucket.allCases) { bucket in
                            Text(bucket.name)
                                .tag(bucket)
                        }
                    }
                }
            }

            if let editedCategory {
                RowView(iconName: "tag", title: "Category:", color: .orange) {
                    Picker("", selection: $editedCategory) {
                        ForEach(Category.allCases) { category in
                            Text(category.name)
                                .tag(category)
                        }
                    }
                }
            }

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.2))
                .cornerRadius(backgroundCornerRadius)

                Button {
                    print("save changes for transaction id: \(transaction.id)")
                    print(editedTitle)
                    dismiss()
                } label: {
                    Text("Save")
                        .foregroundColor(.blue)
                }
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.2))
                .cornerRadius(backgroundCornerRadius)
            }

            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Details")
    }
}

//#Preview {
//    NavigationView {
//        TransactionEditView(transaction: Expense(id: "some_id", title: "Popeyes", date: Date(), amount: 15.62, bucket: .spending, category: .eatingOut))
//    }
//}
