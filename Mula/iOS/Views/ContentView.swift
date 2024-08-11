//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dataManager = DataManager.shared
    let appearance: UITabBarAppearance = UITabBarAppearance()

    init() {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

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

                SettingsView(dataManager: dataManager)
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
