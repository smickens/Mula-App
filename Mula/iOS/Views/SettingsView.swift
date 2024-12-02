//
//  SettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 8/3/24.
//

import FirebaseAuth
import SwiftUI

struct SettingsView: View {
    @Bindable var dataManager: DataManager
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()
            }

            SettingsSectionView(title: "Budgets") {
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

            SettingsSectionView(title: "Import Data") {
                NavigationLink(destination: ExpensesImportView(dataManager: dataManager)) {
                    Text("Upload Expenses (.csv)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(8.0)
                }
            }

            SettingsSectionView(title: "Account") {
                createLargeButton(title: "Sign Out", action: authViewModel.signOut)
            }

            Spacer()
        }
        .padding()
    }

    func createLargeButton(title: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundColor(.white)
        .background(.blue)
        .cornerRadius(8.0)
    }
}

fileprivate struct SettingsSectionView<Content: View>: View {
    let title: String
    let value: (() -> Content)

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            value()
        }
    }
}

struct ExpensesImportView: View {
    @Bindable var dataManager: DataManager
    @State private var expenses: [Expense] = []
    @State private var selectedExpense: Expense? = nil
    @State private var isImportingFile = true

    @State private var expensesSaved = false

    var body: some View {
        ExpensesListView(expenses: expenses, expenseToEdit: $selectedExpense, deleteAction: deleteExpense)

        createLargeButton(title: "Save Expenses") {
            print("save expenses \(expenses)")
            dataManager.addExpenses(expenses)

            expensesSaved = true
        }
        .navigationTitle("Import Expenses")
        .fileImporter(
            isPresented: $isImportingFile,
            allowedContentTypes: [.commaSeparatedText],
            onCompletion: handleImportFile
        )
        .sheet(item: $selectedExpense) { expense in
            ExpenseEditView(expense: expense)
                .presentationDetents([.height(500)])
        }
    }

    func handleImportFile(_ result: Result<URL, any Error>) {
        switch result {
        case .success(let fileURL):
            // Start accessing the security-scoped resource (like iCloud files)
            guard fileURL.startAccessingSecurityScopedResource() else {
                print("Failed to access secure files")
                return
            }

            // Always stop accessing the resource when done
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }

            if let data = try? Data(contentsOf: fileURL),
               let content = String(data: data, encoding: .utf8) {
                expenses = dataManager.processFileContentIntoExpenses(content)
                isImportingFile = false
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    func deleteExpense(_ expense: Expense) {
        guard let expenseIndex = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses.remove(at: expenseIndex)
    }

    func createLargeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .foregroundColor(.white)
        .background(.blue)
        .cornerRadius(8.0)
        .disabled(expensesSaved)
    }
}
