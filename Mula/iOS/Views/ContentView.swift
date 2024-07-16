//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem{
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                ExpensesListView()
            }
            .tabItem {
                Label("Expenses", systemImage: "tag")
            }

            NavigationStack {
                Text("settings")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    ContentView()
}
