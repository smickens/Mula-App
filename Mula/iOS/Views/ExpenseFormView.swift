//
//  TransactionEditView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss

    let transactionID: String?
    @Binding private var title: String
    @Binding private var amount: Double
    @Binding private var date: Date
    @Binding private var bucket: Bucket
    @Binding private var category: Category
    let saveAction: () -> Void

    init(id: String?, title: Binding<String>, amount: Binding<Double>, date: Binding<Date>, bucket: Binding<Bucket>, category: Binding<Category>, saveAction: @escaping () -> Void) {
        self.transactionID = id
        self._title = title
        self._amount = amount
        self._date = date
        self._bucket = bucket
        self._category = category
        self.saveAction = saveAction
    }

    var body: some View {
        VStack {
            HStack {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.bold)
//                    .frame(maxWidth: .infinity, alignment: .leading)

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
                TextField("Enter title", text: $title)
                    .multilineTextAlignment(.trailing)
            }

            RowView(iconName: "dollarsign.circle", title: "Amount:", color: .green) {
                TextField("Enter amount", value: $amount, format: .currency(code: "USD"))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }

            RowView(iconName: "calendar", title: "Date:", color: .blue) {
                DatePicker("Select Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsVisibility(.hidden)
            }

            RowView(iconName: "tray", title: "Bucket:", color: .gray) {
                Picker("", selection: $bucket) {
                    ForEach(Bucket.allCases) { bucket in
                        Text(bucket.name)
                            .tag(bucket)
                    }
                }
            }

            RowView(iconName: "tag", title: "Category:", color: .orange) {
                Picker("", selection: $category) {
                    ForEach(Category.allCases) { category in
                        Text(category.name)
                            .tag(category)
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
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.red.opacity(0.2))
                .cornerRadius(backgroundCornerRadius)

                Button {
                    saveAction()
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
