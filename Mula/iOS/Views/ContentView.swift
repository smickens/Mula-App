//
//  ContentView.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 7/14/24.
//

import SwiftUI

enum Tabs: Equatable, Hashable {
    case home
    case expenses
    case settings
//    case search
}

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    @State private var dataManager = DataManager.shared
    let appearance: UITabBarAppearance = UITabBarAppearance()

    init() {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView(dataManager: dataManager)
                }

                Tab("Expenses", systemImage: "tag", value: .expenses) {
                    ExpensesView(dataManager: dataManager)
                }

                Tab("Settings", systemImage: "gear", value: .settings) {
                    SettingsView(dataManager: dataManager)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
        }
        .environment(dataManager)
        // TODO: could put this logic under settings to create these "job" defaults for a certain date that I select
        // TODO: maybe a whole form there to enter paycheck and quickly input these numbers
//        .onAppear {
//            guard let startDate = createDate(year: 2024, month: 3, day: 15) else {
//                fatalError("Invalid start date")
//            }
//
//            guard let endDate = createDate(year: 2024, month: 7, day: 5) else {
//                fatalError("Invalid end date")
//            }
//
//            let calendar = Calendar.current
//
//            var currentDate = startDate
//
//            while currentDate <= endDate {
//                // Print the current date in the desired format
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateStyle = .medium
//
//                // Move forward by 2 weeks
//                if let newDate = calendar.date(byAdding: .weekOfYear, value: 2, to: currentDate) {
//                    currentDate = newDate
//                } else {
//                    break
//                }
//
//                let expenseJob = Expense(id: nil, title: "Apple Job", date: currentDate, amount: 0, bucket: .income, category: .job)
//                dataManager.addExpense(expense: expenseJob)
//
//                let expense401k = Expense(id: nil, title: "Apple 401k", date: currentDate, amount: 0, bucket: .saving, category: .retirement)
//                dataManager.addExpense(expense: expense401k)
//
//                let expense401kMatch = Expense(id: nil, title: "Apple 401k Match", date: currentDate, amount: 0, bucket: .saving, category: .retirement)
//                dataManager.addExpense(expense: expense401kMatch)
//
//                let expenseESPPStock = Expense(id: nil, title: "Apple ESPP Stock", date: currentDate, amount: 0, bucket: .investment, category: .stocks)
//                dataManager.addExpense(expense: expenseESPPStock)
//            }
//        }
    }

    func createDate(year: Int, month: Int, day: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
    }
}

#Preview {
    ContentView()
}
