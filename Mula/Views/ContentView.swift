//
//  ContentView.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import SwiftData

// TODO: fix spending overview section numbers
// TODO: fix budget page numbers

// TODO: add money tiles view
// TODO: add sub-category to break up food -> eating out vs groceries
// TODO: add warning for uploading duplicate expenses ? (popup with list of duplicated expenses and option to accept all, reject all, or click ones to accept)
// TODO: charts/trends page showing total money spent with stacked bar chart breaking down categories
// could either have checkboxes for choosing what to include on this chart and/or ability to swipe between to pages already broken down by category

struct ContentView: View {
    @Query(sort: \Expense.date, order: .forward) var expenses: [Expense]
    
    @State private var selectedTab: Tab = .home

    var body: some View {
        NavigationView {            
            List(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                    
                    // TODO: add a gear icon next to the settings page
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
                Text("Home")
            case .expenses:
                ExpensesView(expenses: expenses)
            case .trends:
                Text("Trends")
            case .settings:
                SettingsView()
            }
        }
    }

    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}
