//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

enum TabName: String, CaseIterable {
    case transactions = "Transactions"
    case settings = "Settings"
}

struct ContentView: View {
    var expenses: [Expense] = []

    @State private var selectedTab: TabName = .transactions

    var body: some View {
        NavigationView {
            List(selection: $selectedTab) {
                ForEach(TabName.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
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
            case .transactions:
                TransactionsView()
            case .settings:
                AccountsView()
            }
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
