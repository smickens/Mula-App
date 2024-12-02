//
//  ExpensesView.swift
//  Mula
//
//  Created by Shanti Mickens on 8/7/24.
//

import SwiftUI

struct ExpensesView: View {
    @Bindable var dataManager: DataManager
    @State private var selectedExpense: Expense? = nil
    @State private var expenseToDelete: Expense? = nil
    @State private var addingNewExpense: Bool = false
    @State private var filteringExpenses: Bool = false
    @State private var newExpense = Expense(id: nil, title: "", date: Date(), amount: 0.0, bucket: .spending, category: .eatingOut)
    @State private var searchText: String = ""
    @State private var activeBucketFilters: Set<Bucket> = []
    @State private var activeCategoryFilters: Set<Category> = []

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(title: "Expenses", selectedMonth: $dataManager.selectedMonth)
                .padding()

            HStack(spacing: 0) {
                SearchBarView(searchText: $searchText)

                Button {
                    filteringExpenses.toggle()
                } label: {
                    Image(systemName: filterIsActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .imageScale(.large)
                        .tint(.blue)
                }
                .padding(.trailing)

                Button {
                    addingNewExpense.toggle()
                } label: {
                    Image(systemName: "plus.square.fill")
                        .imageScale(.large)
                        .tint(.blue)
                }
                .padding(.trailing)
            }
            .padding(.top, -15)

            ExpensesListView(expenses: filteredSearchResults, expenseToEdit: $selectedExpense, deleteAction: deleteExpense)
        }
        .sheet(isPresented: $addingNewExpense) {
            ExpenseAddView(expense: newExpense)
                .presentationDetents([.height(500)])
        }
        .sheet(item: $selectedExpense) { expense in
            ExpenseEditView(expense: expense)
                .presentationDetents([.height(500)])
        }
        .sheet(isPresented: $filteringExpenses) {
            filterView
                .presentationDetents([.height(500)])
        }
    }

    func deleteExpense(_ expense: Expense) {
        guard let expenseID = expense.id else {
            print("Error expense does not have a id, cannot complete delete action")
            return
        }

        dataManager.deleteExpense(id: expenseID)
    }

    var searchResults: [Expense] {
        let expenses = dataManager.expensesForSelectedMonth

        guard !searchText.isEmpty else {
            return expenses
        }

        return expenses.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }

    var filteredSearchResults: [Expense] {
        guard filterIsActive else {
            return searchResults
        }
        return searchResults.filter {
            activeBucketFilters.contains($0.bucket) || activeCategoryFilters.contains($0.category)
        }
    }

    var filterIsActive: Bool {
        return !activeBucketFilters.isEmpty || !activeCategoryFilters.isEmpty
    }

    var filterView: some View {
        VStack {
            Form {
                Section(header: Text("Select Filters").font(.headline)) {
                    ForEach(Bucket.allCases, id: \.self) { bucket in
                        let isSelected = activeBucketFilters.contains(bucket)

                        HStack {
                            ZStack {
                                Circle()
                                    .fill(bucket.tint)
                                    .frame(width: 25, height: 25)

                                Image(systemName: bucket.icon)
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                            }

                            Text(bucket.name)
                                .font(.body)
                                .fontWeight(isSelected ? .semibold : .regular)

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? bucket.tint : .gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                activeBucketFilters.remove(bucket)
                            } else {
                                activeBucketFilters.insert(bucket)
                            }
                        }
                    }

                    ForEach(Category.allCases, id: \.self) { category in
                        let isSelected = activeCategoryFilters.contains(category)

                        HStack {
                            ZStack {
                                Circle()
                                    .fill(category.tintColor)
                                    .frame(width: 25, height: 25)

                                Image(systemName: category.iconName)
                                    .foregroundColor(.white)
                                    .imageScale(.small)
                            }

                            Text(category.name)
                                .font(.body)
                                .fontWeight(isSelected ? .semibold : .regular)

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? category.tintColor : .gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                activeCategoryFilters.remove(category)
                            } else {
                                activeCategoryFilters.insert(category)
                            }
                        }
                    }
                }
            }
        }
    }
}
