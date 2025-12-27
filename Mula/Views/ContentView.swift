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
    case accounts = "Accounts"
    case transactions = "Transactions"
    case imports = "Imports"
    case settings = "Settings"
}

struct ContentView: View {
    var expenses: [Expense] = []

    @State private var selectedTab: TabName = .transactions

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(TabName.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: iconForTab(tab))
                        .tag(tab)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
            .listStyle(.sidebar)
        } detail: {
            switch selectedTab {
            case .accounts:
                AccountsView()
            case .transactions:
                TransactionsView()
            case .imports:
                ImportsView()
            case .settings:
                SettingsView()
            }
        }
    }

    private func iconForTab(_ tab: TabName) -> String {
        switch tab {
        case .accounts:
            return "person.crop.circle"
        case .transactions:
            return "list.bullet.rectangle"
        case .imports:
            return "tray.and.arrow.down"
        case .settings:
            return "gear"
        }
    }
}
