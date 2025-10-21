//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    var expenses: [Expense] = []

    @State private var selectedTab: TabName = .transactions

    var body: some View {
        NavigationView {
            List(selection: $selectedTab) {
                ForEach(TabName.allCases, id: \.self) { tab in
                    Text(tab.rawValue)

//                    Image(systemName: "gear")
                }
            }
            .listStyle(.sidebar)
            // TODO: fix Ambiguous use of 'toolbar(content:)'
//            .toolbar {
//                ToolbarItem {
//                    Button {
//                        toggleSidebar()
//                    } label: {
//                        Image(systemName: "sidebar.leading")
//                    }
//                }
//            }

            switch selectedTab {
            case .transactions:
                TransactionsView()
            case .settings:
                AccountsView()
            }
        }
    }

    var nonIncomeExpenses: [Expense] {
        return expenses.filter { $0.amount < 0 }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
