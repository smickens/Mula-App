//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dataManager = DataManager.shared
    @State private var selectedMonth = Date().month

    var body: some View {
        NavigationStack {
            TabView {
                HomeView(selectedMonth: $dataManager.selectedMonth)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }

                ExpensesListView(selectedMonth: $dataManager.selectedMonth)
                    .tabItem {
                        Label("Expenses", systemImage: "tag")
                    }

                Text("settings")
                    .navigationTitle("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .onChange(of: selectedMonth) { _, newValue in
            dataManager.refreshData(for: newValue)
        }
        .environment(dataManager)
    }
}

#Preview {
    ContentView()
}
