//
//  SettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 8/3/24.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var dataManager: DataManager

    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("Budgets")
                    .font(.headline)

                ForEach(Bucket.allCases, id: \.id) { bucket in
                    if bucket != .income {
                        RowView(iconName: bucket.icon, title: "\(bucket.name):", color: bucket.tint) {
                            TextField("Enter amount", value: $dataManager.budget[bucket], format: .currency(code: "USD"))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .frame(width: 130)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .onSubmit {
                                    guard let amount = dataManager.budget[bucket] else { return }
                                    dataManager.updateBudget(for: bucket, to: amount)
                                }
                        }
                    }
                }
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("Import Data")
                    .font(.headline)
                
                Button {
                    print("upload expenses")
                } label: {
                    Text("Upload Expenses (.csv)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(8.0)
            }

            Spacer()
        }
        .padding()
    }
}

//#Preview {
//    SettingsView(dataManager: DataManager.shared)
//}
