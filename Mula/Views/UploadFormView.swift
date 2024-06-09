//
//  UploadFormView.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/24.
//

import SwiftUI

struct UploadFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var fileContent: String
    @State private var newExpenses: [Expense] = []
    @State private var selectedExpense: Expense?
    
    @State private var editedTitle: String = ""
    @State private var editedAmount: Double = 0.0
    @State private var editedCategory: Category = .misc
    @State private var editedDate: Date = Date()

    var body: some View {
        VStack {
            Text("Confirm Expenses")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                newExpensesList

                editFields
            }
        }
        .frame(width: 600, height: 340)
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button{
                    clearAllNewExpenses()
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .foregroundColor(.red)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button{
                    saveNewExpenses()
                } label: {
                    Text("Save New Expenses")
                }
            }
        }
        .onAppear {
            newExpenses = processCSV(fileContent)
            selectedExpense = newExpenses.first
        }
        .onChange(of: selectedExpense) { _, newValue in
            guard let newValue else { return }
            editedTitle = newValue.title
            editedAmount = newValue.amount
            editedCategory = newValue.category
            editedDate = newValue.date
        }
    }
    
    private var newExpensesList: some View {
        List(newExpenses, selection: $selectedExpense) { expense in
            ExpenseView(expense: expense, swipeActionsEnabled: false)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        newExpenses.removeAll { $0.id == expense.id }
                        modelContext.delete(expense)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(selectedExpense == expense ? Color.gray.opacity(0.2) : Color.clear)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        selectedExpense = expense
                    }
                }
        }
        .frame(width: 340)
    }
    
    private var editFields: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle, prompt: Text("Groceries"))
                    .onChange(of: editedTitle) { _, newValue in
                        selectedExpense?.title = editedTitle
                    }

                TextField("Amount", value: $editedAmount, format: .currency(code: "USD"))
                    .onChange(of: editedAmount) { _, newValue in
                        selectedExpense?.amount = editedAmount
                    }

                Picker("Category", selection: $editedCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.name)
                    }
                }
                .onChange(of: editedCategory) { _, newValue in
                    selectedExpense?.category = editedCategory
                }

                DatePicker("Date", selection: $editedDate, in: ...Date(), displayedComponents: .date)
                    .onChange(of: editedDate) { _, newValue in
                        selectedExpense?.date = editedDate
                    }
            }
            .textFieldStyle(.roundedBorder)
        }
    }

    private func saveNewExpenses() {
        do {
            try modelContext.transaction {
                for expense in newExpenses {
                    modelContext.insert(expense)
                }
            }
        } catch {
            // Handle error
        }

        dismiss()
    }

    private func clearAllNewExpenses() {
        for expense in newExpenses {
            modelContext.delete(expense)
        }
    }

// MARK: Transaction CSV Processing
    
    private func processCSV(_ content: String) -> [Expense] {
        var expenses: [Expense] = []
        let rows = content.components(separatedBy: "\n")
        
        let numColumns = rows.first?.components(separatedBy: ",").count ?? 0
        let bank: Bank = numColumns == 8 ? .apple : (numColumns == 5 ? .usBank : .bilt)
        
        var processedExpenses = [Expense]()
        for row in rows.dropFirst() {
            guard !row.isEmpty else { continue }
            
            func processRowByBank() -> Expense? {
                switch bank {
                case .apple:
                    return processAppleTransaction(row)
                case .usBank:
                    return processUSBankTransaction(row)
                case .bilt:
                    return processBiltTransaction(row)
                }
            }
            
            if let expense = processRowByBank() {
                // Rename common transactions
                let mappedExpenseTitles: [String: (String, Category?)] = [
                    "ELECTRONIC DEPOSIT APPLE INC.": ("Apple Job", nil),
                    "WEB AUTHORIZED PMT VENMO": ("Venmo (out)", nil),
                    "ELECTRONIC DEPOSIT VENMO": ("Venmo (in)", nil),
                    "ELECTRONIC WITHDRAWAL ATT": ("Internet Bill", .housing),
                    "BPS*BILT REWARDS B NEW YORK NY": ("Rent", Category.housing)
                ]
                if let mappedTitle = mappedExpenseTitles[expense.title] {
                    expense.title = mappedTitle.0
                    expense.category = mappedTitle.1 ?? expense.category
                }
                if expense.title.range(of: "Uber Eats", options: .caseInsensitive) != nil {
                    expense.title = "Uber Eats"
                    expense.category = .food
                } else if expense.title.range(of: "Uber", options: .caseInsensitive) != nil {
                    expense.title = "Uber"
                    expense.category = .transportation
                } else if expense.title.range(of: "Lyft", options: .caseInsensitive) != nil {
                    expense.title = "Lyft"
                    expense.category = .transportation
                } else if expense.title.range(of: "APPLE CAFFE", options: .caseInsensitive) != nil {
                    expense.title = "Apple Caffe"
                    expense.category = .food
                } else if expense.title.range(of: "SAFEWAY", options: .caseInsensitive) != nil {
                    expense.title = "Safeway"
                    expense.category = .food
                } else if expense.title.range(of: "TARGET", options: .caseInsensitive) != nil {
                    expense.title = "Target"
                    expense.category = .shopping
                } else if expense.title.range(of: "DUNKIN", options: .caseInsensitive) != nil {
                    expense.title = "Dunkin"
                    expense.category = .food
                }
                
                expenses.append(expense)
            }
        }
        
        return expenses
    }

    private func processAppleTransaction(_ row: String) -> Expense? {
        // ["Transaction Date", "Clearing Date", "Description", "Merchant", "Category", "Type", "Amount (USD)", "Purchased By"]
        let columns = row.components(separatedBy: ",")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
            
        let expenseDate = dateFormatter.date(from: columns[0]) ?? Date()
        let expenseTitle = columns[3].replacingOccurrences(of: "\"", with: "")
        let expenseAmount = Double(columns[6].replacingOccurrences(of: "\"", with: "")) ?? 0.0
        let expenseCategory = getCategory(fromString: columns[4].replacingOccurrences(of: "\"", with: ""))
        
        // Filter out credit card payment transactions
        let ignoredCatgories = ["Payment"]
        guard !ignoredCatgories.contains(columns[4].replacingOccurrences(of: "\"", with: "")) else {
            return nil
        }
        
        return nil
    }
    
    private func processUSBankTransaction(_ row: String) -> Expense? {
        // ["Date", "Transaction", "Name", "Memo", "Amount"]
        let columns = row.components(separatedBy: ",")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let expenseDate = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) ?? Date()
        let expenseTitle = columns[2].replacingOccurrences(of: "\"", with: "")
        let expenseAmount = (Double(columns[4].replacingOccurrences(of: "\"", with: "")) ?? 0.0) * -1
        let expenseCategory = expenseAmount < 0 ? Category.income : Category.misc
        
        // Filter out the following: credit card payment transactions, moving money to/from Apple Savings, and waived monthly maintenance fees
        let ignoredPayments = ["WEB AUTHORIZED PMT APPLECARD GSBANK", "WEB AUTHORIZED PMT WELLS FARGO CARD", "MOBILE BANKING PAYMENT TO CREDIT CARD 5895", "MOBILE BANKING PAYMENT TO CREDIT CARD 9996", "WEB AUTHORIZED PMT APPLE GS SAVINGS", "ELECTRONIC DEPOSIT APPLE GS SAVINGS", "MONTHLY MAINTENANCE FEE", "MONTHLY MAINTENANCE FEE WAIVED"]
        guard !ignoredPayments.contains(expenseTitle) else {
            return nil
        }
            
        return Expense(title: expenseTitle, date: expenseDate, amount: -expenseAmount, category: expenseCategory)
    }
    
    private func processBiltTransaction(_ row: String) -> Expense? {
        // ["Date", "Amount", "*", "Name"]
        let columns = row.components(separatedBy: ",")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let expenseDate = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) ?? Date()
        let expenseTitle = columns[3].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let expenseAmount = (Double(columns[1].replacingOccurrences(of: "\"", with: "")) ?? 0.0) * -1
        let expenseCategory = expenseAmount < 0 ? Category.income : Category.misc
        
        // Filter out credit card payment transactions
        let ignoredPayments = ["ONLINE ACH PAYMENT THANK YOU"]
        guard !ignoredPayments.contains(expenseTitle) else {
            return nil
        }
            
        return Expense(title: expenseTitle, date: expenseDate, amount: -expenseAmount, category: expenseCategory)
    }

    private func getCategory(fromString category: String) -> Category? {
        let ignoreCatgories = ["Payment"]
        guard !ignoreCatgories.contains(category) else { return nil }

        let housingCategories = ["Hotels"]
        let foodCategories = ["Restaurants", "Grocery"]
        let shoppingCategories = ["Shopping"]
//        let miscCategories = []
        let transportationCategories = ["Airlines", "Transportation"]
        let entertainmentCategories = ["Entertainment"]

        if (housingCategories.contains(category)) {
            return .housing
        } else if (foodCategories.contains(category)) {
            return .food
        } else if (shoppingCategories.contains(category)) {
            return .shopping
        } else if (transportationCategories.contains(category)) {
            return .transportation
        } else if (entertainmentCategories.contains(category)) {
            return .entertainment
        }

        return .misc
    }
}
