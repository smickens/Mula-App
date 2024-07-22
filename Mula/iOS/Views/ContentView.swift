//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManger: DataManager
    @State private var selectedMonth = Date().month
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                HomeView(selectedMonth: $selectedMonth)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }

                ExpensesListView(navigationPath: $path, selectedMonth: $selectedMonth)
                    .tabItem {
                        Label("Expenses", systemImage: "tag")
                    }

                Text("settings")
                    .navigationTitle("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .navigationDestination(for: Expense.self) { expense in
                TransactionEditView(transaction: expense)
            }
        }
        .onChange(of: selectedMonth) { _, newValue in
            dataManger.refreshData(for: newValue)
        }
    }
}

#Preview {
    ContentView()
}
