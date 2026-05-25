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
    case trends = "Trends"
    case income = "Income"
    case savings = "Savings"
    case accounts = "Accounts"
    case transactions = "Transactions"
    case imports = "Imports"
    case settings = "Settings"
}

struct ContentView: View {
    @State private var selectedTab: TabName = .trends

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
            case .trends:
                TrendsView()
            case .income:
                IncomeView()
            case .savings:
                SavingsView()
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
        case .trends:
            return "chart.bar.xaxis"
        case .income:
            return "chart.bar.fill"
        case .savings:
            return "chart.line.uptrend.xyaxis"
        case .imports:
            return "tray.and.arrow.down"
        case .settings:
            return "gear"
        }
    }
}
