//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI

// TODO: move list of months to maybe be a picker ?? or checkbox filter
// TODO: budgeting mech
// TODO: home page with charts that compares spending / trends in different months, checklist of which categories to view over the year
// TODO: click on categories to toggle them on/off
// TODO: add warning for uploading duplicate expenses ? (popup with list of duplicated expenses and option to accept all, reject all, or click ones to accept)
// TODO: settings page

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: true)]
    ) var expenses: FetchedResults<Expense>
    @State private var selectedMonth: String? = Date().month
    @State private var showingNewExpenseForm: Bool = false
    @State private var showingUploadExpensesForm: Bool = false
    @State private var searchText: String = ""
    @State private var fileContent: String?
    @State private var newExpenses: [Expense] = []
    @State private var selectedExpense: Expense? = nil

    let months: [String] = DateFormatter().monthSymbols

    var body: some View {
        NavigationView {
            List(selection: $selectedMonth) {
                ForEach(months, id: \.self) { month in
                    Text(month)
                }

                Spacer()

                HStack {
                    Text("Settings")

                    Spacer()

                    Image(systemName: "gear")
                }
                .tag("Settings")
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
                    SummaryView(totalMoneyIn: totalMoneyIn, totalMoneyOut: totalMoneyOut, totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Summary")
                        }

                    BudgetView(totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Budget")
                        }
                }
                .padding()

                List(filteredExpenses.filter {
                    searchText.isEmpty || $0.title?.localizedStandardContains(searchText) == true
                }) { expense in
                    ExpenseView(expense: expense, swipeActionsEnabled: true)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExpense = expense
                        }
                        .background(selectedExpense == expense ? .gray.opacity(0.2) : .clear)
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
                        showingNewExpenseForm.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewExpenseForm) {
            ExpenseFormView(showingExpenseForm: $showingNewExpenseForm)
        }
        .sheet(isPresented: $showingUploadExpensesForm) {
            UploadFormView(showingUploadExpensesForm: $showingUploadExpensesForm, newExpenses: $newExpenses)
        }
    }

    private var totalMoneyIn: Double {
        return filteredExpenses.reduce(0, { result, expense in
            return expense.amount > 0 ? result + expense.amount : result
        })
    }

    private var totalMoneyOut: Double {
        return filteredExpenses.reduce(0, { result, expense in
            return expense.amount < 0 ? result + expense.amount : result
        })
    }

    private var totalsByCategory: [Category: Double] {
        var totals: [Category: Double] = [:]
        filteredExpenses.forEach { expense in
            if (expense.amount < 0) {
                totals[expense.category] = abs(expense.amount) + (totals[expense.category] ?? 0)
            }
        }
        return totals
    }

    private var filteredExpenses: [Expense] {
        return expenses.filter { ($0.date ?? Date()).month == selectedMonth }
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
            newExpenses = processCSV(content)
            showingUploadExpensesForm.toggle()
        } else {
            print("file picking error")
        }
    }

    private func processCSV(_ content: String) -> [Expense] {
        let rows = content.components(separatedBy: "\n")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        // ["Transaction Date", "Clearing Date", "Description", "Merchant", "Category", "Type", "Amount (USD)", "Purchased By"]
        var processedExpenses = [Expense]()
        for row in rows.dropFirst() {
            let columns = row.components(separatedBy: ",")

            let expenseDate = dateFormatter.date(from: columns[0]) ?? Date()
            let expenseTitle = columns[3].replacingOccurrences(of: "\"", with: "")
            let expenseAmount = Double(columns[6].replacingOccurrences(of: "\"", with: "")) ?? 0.0

            if let expenseCategory = getCategory(fromString: columns[4].replacingOccurrences(of: "\"", with: "")) {
                processedExpenses.append(ExpenseRepository.shared.createExpense(id: UUID(), title: expenseTitle, date: expenseDate, amount: -expenseAmount, category: expenseCategory))
            }
        }

        return processedExpenses
    }

    private func getCategory(fromString category: String) -> Category? {
        let ignoreCatgories = ["Payment"]
        guard !ignoreCatgories.contains(category) else { return nil }

        let housingCategories = ["Hotels"]
        let foodCategories = ["Restaurants", "Grocery"]
        let shoppingCategories = ["Shopping"]
//        let miscCategories = []
        let transportationCategories = ["Airlines", "Transportation"]
        let entertainmentCategories = ["Entertainment"]

        if (housingCategories.contains(category)) {
            return .housing
        } else if (foodCategories.contains(category)) {
            return .food
        } else if (shoppingCategories.contains(category)) {
            return .shopping
        } else if (transportationCategories.contains(category)) {
            return .transportation
        } else if (entertainmentCategories.contains(category)) {
            return .entertainment
        }

        return .misc
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
