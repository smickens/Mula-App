//
//  TransactionsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//


import SwiftUI

struct TransactionsView: View {
    @Environment(DataManager.self) private var dataManager

    @State private var searchText: String = ""
    @State private var selectedYear: String = Date().year
    @State private var selectedMonth: String = Date().month
    @State private var selectedTransaction: Transaction? = nil
    @State private var selectedCategory: Category? = nil
    @State private var showingNewExpenseForm: Bool = false
    @State private var showingUploadExpensesForm: Bool = false
    @State private var fileContent: String = ""

    private let currentYear: Int = Calendar.current.component(.year, from: Date())
    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                HStack {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2024...currentYear, id: \.self) { year in
                            Text(String(year))
                                .tag(String(year))
                        }
                    }

                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text(month)
                        }
                    }
                }

                TabView {
                    SummaryView(selectedCategory: $selectedCategory, expensesForMonth: [], totalsByCategory: [:])
                        .tabItem {
                            Text("Summary")
                        }
                }
            }
            .padding()

            List(filteredTransactions) { transaction in
                TransactionView(selectedTransaction: $selectedTransaction, swipeActionsEnabled: true, transaction: transaction)
            }
            .searchable(text: $searchText)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    importCSV()
                } label: {
                    Image(systemName: "arrow.up")
                }
            }

            ToolbarItem {
                Button {
                    showingNewExpenseForm.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewExpenseForm) {
            // TODO: pass in the current selected month to default the picker to that
            NewTransactionFormView()
        }
        .sheet(isPresented: $showingUploadExpensesForm) {
            UploadFormView(fileContent: $fileContent)
        }
    }

    private var filteredTransactions: [Transaction] {
        dataManager
            .transactionsSortedByDate(with: selectedYear, and: selectedMonth)
//            .filter { selectedCategory != nil ? $0.category == selectedCategory : true }
            .filter { searchText.isEmpty || $0.title.localizedStandardContains(searchText) }
    }

    private var totalsByCategory: [TransactionCategory: Double] {
        var totals: [TransactionCategory: Double] = [:]
//        filteredTransactions.forEach { expense in
//            // Multiply expense amount by -1 so that +10 represents $10 spent and -5 means $5 gained
//            totals[expense.category] = (expense.amount * -1) + (totals[expense.category] ?? 0)
//        }
        return totals
    }

    private func importCSV() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.commaSeparatedText]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false

        if openPanel.runModal() == .OK,
           let fileURL = openPanel.url,
           let data = try? Data(contentsOf: fileURL),
           let content = String(data: data, encoding: .utf8) {
            fileContent = content
            showingUploadExpensesForm.toggle()
        } else {
            print("file picking error")
        }
    }
}
