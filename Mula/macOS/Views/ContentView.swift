//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

struct ContentView: View {
//    @Query(sort: \Expense.date, order: .forward) var expenses: [Expense]
    var expenses: [Expense] = []

    @State private var selectedTab: TabName = .home

    var body: some View {
        NavigationView {
            List(selection: $selectedTab) {
                ForEach(TabName.allCases, id: \.self) { tab in
                    Text(tab.rawValue)

//                    Image(systemName: "gear")
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

            switch selectedTab {
            case .home:
                HomeView(expenses: expenses)
            case .expenses:
                ExpensesView(expenses: expenses)
            case .trends:
                Text("Trends")
                    .toolbar {
                        ToolbarItem {
                            Button {
                                DataManager.shared.addFakeExpense()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }

                        ToolbarItem {
                            Button {
                                DataManager.shared.readFakeExpenses()
                            } label: {
                                Image(systemName: "star")
                            }
                        }

//                        ToolbarItem {
//                            Button {
//                                DataManager.shared.uploadExpenses(expenses: expenses)
//                            } label: {
//                                Image(systemName: "minus")
//                            }
//                        }
                    }
            case .settings:
                SettingsView()
            }
        }
    }

    var nonIncomeExpenses: [Expense] {
        return expenses.filter { !$0.isIncome }
    }

    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}
