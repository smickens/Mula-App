//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dataManager = DataManager.shared

    var body: some View {
        NavigationStack {
            TabView {
                HomeView(dataManager: dataManager)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }

                ExpensesListView(dataManager: dataManager)
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
        .environment(dataManager)
    }
}

#Preview {
    ContentView()
}
