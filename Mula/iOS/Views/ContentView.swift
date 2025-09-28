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
    @State private var dataManager = DataManager.shared
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private let appearance: UITabBarAppearance = UITabBarAppearance()
    private let currentYear: Int = Calendar.current.component(.year, from: Date())
    private let months: [String] = DateFormatter().monthSymbols

    init() {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Views")) {
                    NavigationLink(destination: HomeView(selectedYear: $selectedYear, selectedMonth: $selectedMonth)) {
                        Label("Home", systemImage: "house")
                    }

                    NavigationLink(destination: ExpensesView(selectedYear: $selectedYear, selectedMonth: $selectedMonth)) {
                        Label("Expenses", systemImage: "tag")
                    }
                }

                sidebarDateOptions

                Section(header: Text("Settings")) {
                    NavigationLink(destination: SettingsView_iOS()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Mula")
        } detail: {
            Text("detail view")

//            TabView {
//                HomeView(selectedYear: $selectedYear, selectedMonth: $selectedMonth)
//                    .tabItem {
//                        Label("Home", systemImage: "house")
//                    }
//                ExpensesView(selectedMonth: $selectedMonth)
//                    .tabItem {
//                        Label("Expenses", systemImage: "tag")
//                    }
//            }
        }
        .environment(dataManager)
//        .overlay(
//            // Top-right button
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        print("Top-right button tapped")
//                    }) {
//                        Image(systemName: "gear")
//                            .foregroundColor(.blue)
//                            .padding()
//                    }
//                }
//                Spacer()
//            }
//        )
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

//    var sidebarDateOptions: some View {
//        Section(header: Text("Expenses")) {
////                    DisclosureGroup {
//            ForEach(2024...currentYear, id: \.self) { year in
//                DisclosureGroup {
//                    ForEach(1...12, id: \.self) { month in
//                        if (year < currentYear || month <= currentMonth) {
////                            NavigationLink(destination: EmptyView()) {
//                                Label("\(months[month-1])", systemImage: "\(month).circle.fill")
//                                    .onTapGesture {
//                                        dataManager.refreshData(with: String(year), and: String(month))
//                                    }
////                            }
//                        }
//                    }
//                } label: {
//                    Label(formatYear(year), systemImage: "calendar")
//                }
//            }
//        }
//    }

    // TODO: add a DateConfiguration/TimeframeConfig struct
    // TODO: allow for viewing previous by month, last 6 months, YTD
    var sidebarDateOptions: some View {
        Section(header: Text("Timeframe")) {
            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { month in
                    Text("\(months[month-1])")
                        .tag(month)
                }
            }
            .pickerStyle(.menu)

            Picker("Year", selection: $selectedYear) {
                ForEach(2024...currentYear, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.menu)
        }
    }

    func formatYear(_ year: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none // No formatting
        return formatter.string(from: NSNumber(value: year)) ?? "\(year)"
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
