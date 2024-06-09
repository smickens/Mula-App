//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import SwiftData

// TODO: fix spending overview section numbers
// TODO: fix budget page numbers
// TODO: add a popup for "file picking error", include reminder that file type must be .csv
// TODO: add sub-category to break up food -> eating out vs groceries
// TODO: move list of months to maybe be a picker ?? or checkbox filter
// TODO: add warning for uploading duplicate expenses ? (popup with list of duplicated expenses and option to accept all, reject all, or click ones to accept)
// TODO: charts/trends page showing total money spent with stacked bar chart breaking down categories
// could either have checkboxes for choosing what to include on this chart and/or ability to swipe between to pages already broken down by category
// TODO: change category totals to an array so it can be sorted by value to allow for consistency

struct ContentView: View {
    @Query(sort: \Expense.date, order: .forward) var expenses: [Expense]
    
    @State private var selectedMonth: String = Date().month
    @State private var selectedExpense: Expense? = nil
    @State private var selectedCategory: Category? = nil
    
    @State private var searchText: String = ""
    @State private var fileContent: String = ""
    
    @State private var showingNewExpenseForm: Bool = false
    @State private var showingUploadExpensesForm: Bool = false
    @State private var showingSettings: Bool = false

    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        NavigationView {
            List(selection: $selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text(month)
                }
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.leading")
                    }
                }
            }

            HStack(spacing: 0) {
                TabView {
                    SummaryView(selectedCategory: $selectedCategory, expensesForMonth: expensesForMonth, totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Summary")
                        }

                    BudgetView(totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Budget")
                        }
                }
                .padding()

                List(filteredExpenses) { expense in
                    ExpenseView(selectedExpense: $selectedExpense, expense: expense, swipeActionsEnabled: true)
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

                ToolbarItem {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewExpenseForm) {
            NewExpenseFormView(selectedMonth: selectedMonth)
        }
        .sheet(isPresented: $showingUploadExpensesForm) {
            UploadFormView(fileContent: $fileContent)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
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
        openPanel.allowedContentTypes = [.data]
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

    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}



#Preview {
    ContentView()
}
