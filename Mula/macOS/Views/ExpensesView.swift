//
//  ExpensesView.swift
//  Mula
//
//  Created by Shanti Mickens on 6/16/24.
//

import SwiftUI

struct ExpensesView: View {
    @State private var dataManager = DataManager.shared

    @State private var searchText: String = ""
    @State private var fileContent: String = ""

    @State private var selectedYear: String = Date().year
    private let currentYear: Int = Calendar.current.component(.year, from: Date())

    @State private var selectedMonth: String = Date().month
    @State private var selectedExpense: Expense? = nil
    @State private var selectedCategory: Category? = nil
    
    @State private var showingNewExpenseForm: Bool = false
    @State private var showingUploadExpensesForm: Bool = false
    
    let expenses: [Expense]
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
                    SummaryView(selectedCategory: $selectedCategory, expensesForMonth: expensesForMonth, totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Summary")
                        }

                    BudgetView(totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Budget")
                        }

                    HomeView(expenses: expenses)
                        .tabItem {
                            Text("Trends")
                        }
                }
            }
            .padding()

            List(dataManager.expenses(with: selectedYear, and: selectedMonth)) { expense in
                ExpenseView(selectedExpense: $selectedExpense, swipeActionsEnabled: true, expense: expense)
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
            NewExpenseFormView(selectedMonth: selectedMonth)
        }
        .sheet(isPresented: $showingUploadExpensesForm) {
            UploadFormView(fileContent: $fileContent)
        }
    }
    
    private var expensesForMonth: [Expense] {
        return expenses.filter { $0.date.month == selectedMonth }
    }

    private var filteredExpenses: [Expense] {
        let filteredByCategory = expensesForMonth.filter { selectedCategory != nil ? $0.category == selectedCategory : true }
        let filteredBySearch = filteredByCategory.filter { searchText.isEmpty || $0.title.localizedStandardContains(searchText) == true }
        return filteredBySearch
    }
    
    private var totalsByCategory: [Category: Double] {
        var totals: [Category: Double] = [:]
        expensesForMonth.forEach { expense in
            // Multiply expense amount by -1 so that +10 represents $10 spent and -5 means $5 gained
            totals[expense.category] = (expense.amount * -1) + (totals[expense.category] ?? 0)
        }
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
