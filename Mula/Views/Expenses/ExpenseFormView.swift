//
//  ExpenseFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import SwiftUI

struct ExpenseFormView: View {
    @Binding var title: String
    @Binding var date: Date
    @Binding var amount: Double
    @Binding var category: Category

    let formTitle: String
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(formTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .textFieldStyle(.roundedBorder)

                Picker("Category", selection: $category) {
                    ForEach(Category.allCases, id: \.self) { cat in
                        Text(cat.name)
                    }
                }
                .pickerStyle(.menu)

                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
            }

            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(width: 360)
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && amount != 0
    }
}
