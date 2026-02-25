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
    @State private var selectedCategory: (any TransactionCategoryProtocol)? = nil

    @State private var showingNewTransactionForm: Bool = false

    private let currentYear: Int = Calendar.current.component(.year, from: Date())
    private let months: [String] = DateFormatter().monthSymbols

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
                    SummaryView(selectedCategory: $selectedCategory, transactionsForMonth: transactionsForSelectedDate, totalsByCategory: totalsByCategory)
                        .tabItem {
                            Text("Summary")
                        }
                }
            }
            .padding()

            List(filteredTransactions) { transaction in
                TransactionView(selectedTransaction: $selectedTransaction, swipeActionsEnabled: true, transaction: transaction, displayingAccountId: nil)
            }
            .searchable(text: $searchText)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showingNewTransactionForm.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewTransactionForm) {
            // TODO: pass in the current selected month to default the picker to that
            NewTransactionFormView()
        }
    }

    private var transactionsForSelectedDate: [Transaction] {
        dataManager.transactionsSortedByDate(with: selectedYear, and: selectedMonth)
    }

    private var filteredTransactions: [Transaction] {
        transactionsForSelectedDate
            .filter {
                guard let selectedCategory else { return true }
                return $0.category.id == selectedCategory.id
            }
            .filter {
                searchText.isEmpty || $0.title.localizedStandardContains(searchText)
            }
    }

    private var totalsByCategory: [(any TransactionCategoryProtocol, Decimal)] {
        var totalsById: [String: (any TransactionCategoryProtocol, Decimal)] = [:]

        for transaction in transactionsForSelectedDate {
            switch transaction.kind {
            case .expense(let category):
                let key = category.id
                let currentTotal = totalsById[key]?.1 ?? 0
                totalsById[key] = (category, currentTotal + transaction.amount)
            case .income(let category):
                let key = category.id
                let currentTotal = totalsById[key]?.1 ?? 0
                totalsById[key] = (category, currentTotal + transaction.amount)
            case .transfer(let category, _):
                let key = category.id
                let currentTotal = totalsById[key]?.1 ?? 0
                totalsById[key] = (category, currentTotal + transaction.amount)
            }
        }


        return Array(totalsById.values)
    }

}
