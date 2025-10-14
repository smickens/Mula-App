//
//  DataManager.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import Firebase
import FirebaseDatabase

@Observable
final class DataManager {

    static let shared = DataManager()

    private init() {
        let dbRef = Database.database().reference()
        expenseRef = dbRef.child("expense")
        budgetRef = dbRef.child("budget")

        loadExpenses()
        loadBudgets()
    }

    private var expenseRef: DatabaseReference
    private var budgetRef: DatabaseReference

    // TODO: might remove this property altogether
//    public var selectedMonth = Date().month
//    {
//        didSet {
//            refreshData(with: selectedYear, and: selectedMonth)
//        }
//    }

    var allExpenses: [Expense] = []
//    {
//        didSet {
//            refreshData(with: selectedYear, and: selectedMonth)
//        }
//    }

    public var budget: [Bucket: Double] = [:]

    var expensesForSelectedMonth: [Expense] = []
    var bucketTotalsForSelectedMonth: [Bucket: Double] = [:]
    var categoryTotalsForSelectedMonth: [Category: Double] = [:]

    public func refreshData(with selectedYear: String, and selectedMonth: String) {
        print("Refreshing data for \(selectedMonth) \(selectedYear)...")
        expensesForSelectedMonth = DataManager.shared.expenses(with: selectedYear, and: selectedMonth).sorted(by: { $0.date < $1.date })

        for bucket in Bucket.allCases {
            bucketTotalsForSelectedMonth[bucket] = totalExpense(with: selectedYear, and: selectedMonth, in: bucket)
        }

        for category in Category.allCases {
            categoryTotalsForSelectedMonth[category] = totalExpense(with: selectedYear, and: selectedMonth, in: category)
        }
    }

// MARK: Import expenses from .csv file

    func processFileContentIntoExpenses(_ content: String) -> [Expense] {
        var expenses: [Expense] = []
        let rows = content.components(separatedBy: "\n")

        let numColumns = rows.first?.components(separatedBy: ",").count ?? 0
        let bank: Bank = numColumns == 8 ? .apple : (numColumns == 5 ? .usBank : .bilt)

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
                let mappedExpenseTitles: [String: (String, Bucket, Category)] = [
                    "ELECTRONIC DEPOSIT APPLE INC.": ("Apple Job", .income, .job),
                    "WEB AUTHORIZED PMT VENMO": ("Venmo (out)", .spending, .entertainment),
                    "ELECTRONIC DEPOSIT VENMO": ("Venmo (in)", .income, .misc),
                    "ELECTRONIC WITHDRAWAL ATT": ("Internet Bill", .fixed, .housing),
                    "BPS*BILT REWARDS B NEW YORK NY": ("Rent", .fixed, Category.housing)
                ]
                if let mappedTitle = mappedExpenseTitles[expense.title] {
                    expense.title = mappedTitle.0
                    expense.bucket = mappedTitle.1
                    expense.category = mappedTitle.2
                }
                if expense.title.range(of: "Uber Eats", options: .caseInsensitive) != nil {
                    expense.title = "Uber Eats"
                    expense.bucket = .spending
                    expense.category = .eatingOut
                } else if expense.title.range(of: "Uber", options: .caseInsensitive) != nil {
                    expense.title = "Uber"
                    expense.bucket = .fixed
                    expense.category = .transportation
                } else if expense.title.range(of: "Lyft", options: .caseInsensitive) != nil {
                    expense.title = "Lyft"
                    expense.bucket = .fixed
                    expense.category = .transportation
                } else if expense.title.range(of: "APPLE CAFFE", options: .caseInsensitive) != nil {
                    expense.title = "Apple Caffe"
                    expense.bucket = .spending
                    expense.category = .eatingOut
                } else if expense.title.range(of: "SAFEWAY", options: .caseInsensitive) != nil {
                    expense.title = "Safeway"
                    expense.bucket = .fixed
                    expense.category = .groceries
                } else if expense.title.range(of: "TARGET", options: .caseInsensitive) != nil {
                    expense.title = "Target"
                    expense.bucket = .fixed
                    expense.category = .groceries
                } else if expense.title.range(of: "DUNKIN", options: .caseInsensitive) != nil {
                    expense.title = "Dunkin"
                    expense.bucket = .spending
                    expense.category = .eatingOut
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
        let expenseAmount = (Double(columns[6].replacingOccurrences(of: "\"", with: "")) ?? 0.0) * -1
        let (expenseBucket, expenseCategory) = classifyFromCreditCardCategory(columns[4].replacingOccurrences(of: "\"", with: ""))

        // Filter out credit card payment transactions
        let ignoredCatgories = ["Payment"]
        guard !ignoredCatgories.contains(columns[4].replacingOccurrences(of: "\"", with: "")) else {
            return nil
        }

        return newExpense(title: expenseTitle, date: expenseDate, amount: expenseAmount, bucket: expenseBucket, category: expenseCategory)
    }

    private func processUSBankTransaction(_ row: String) -> Expense? {
        // ["Date", "Transaction", "Name", "Memo", "Amount"]
        let columns = row.components(separatedBy: ",")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let expenseDate = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) ?? Date()
        let expenseTitle = columns[2].replacingOccurrences(of: "\"", with: "")
        let expenseAmount = Double(columns[4].replacingOccurrences(of: "\"", with: "")) ?? 0.0
        let expenseBucket = expenseAmount < 0 ? Bucket.income : Bucket.spending
        let expenseCategory = Category.misc

        // Filter out the following: credit card payment transactions, moving money to/from Apple Savings, and waived monthly maintenance fees
        let ignoredPayments = ["WEB AUTHORIZED PMT APPLECARD GSBANK", "WEB AUTHORIZED PMT WELLS FARGO CARD", "MOBILE BANKING PAYMENT TO CREDIT CARD 5895", "MOBILE BANKING PAYMENT TO CREDIT CARD 9996", "WEB AUTHORIZED PMT APPLE GS SAVINGS", "ELECTRONIC DEPOSIT APPLE GS SAVINGS", "MONTHLY MAINTENANCE FEE", "MONTHLY MAINTENANCE FEE WAIVED"]
        guard !ignoredPayments.contains(expenseTitle) else {
            return nil
        }

        return newExpense(title: expenseTitle, date: expenseDate, amount: expenseAmount, bucket: expenseBucket, category: expenseCategory)
    }

    private func processBiltTransaction(_ row: String) -> Expense? {
        // ["Date", "Amount", "*", "", "Name"]
        let columns = row.components(separatedBy: ",")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        let expenseDate = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) ?? Date()
        let expenseTitle = columns[3].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let expenseAmount = Double(columns[1].replacingOccurrences(of: "\"", with: "")) ?? 0.0
        let expenseBucket = expenseAmount < 0 ? Bucket.income : Bucket.spending
        let expenseCategory = Category.misc

        // Filter out credit card payment transactions
        let ignoredPayments = ["ONLINE ACH PAYMENT THANK YOU"]
        guard !ignoredPayments.contains(expenseTitle) else {
            return nil
        }

        return newExpense(title: expenseTitle, date: expenseDate, amount: expenseAmount, bucket: expenseBucket, category: expenseCategory)
    }

    private func classifyFromCreditCardCategory(_ categoryString: String) -> (Bucket, Category) {
        var bucket: Bucket = .spending
        var category: Category = .misc

        let ignoreCatgories = ["Payment"]
        if !ignoreCatgories.contains(categoryString) {
            let housingCategories = ["Hotels"]
            let foodCategories = ["Restaurants"]
            let groceriesCategories = ["Grocery"]
            let shoppingCategories = ["Shopping"]
            let transportationCategories = ["Airlines", "Transportation"]
            let entertainmentCategories = ["Entertainment"]

            if (housingCategories.contains(categoryString)) {
                return (.fixed, .housing)
            } else if (foodCategories.contains(categoryString)) {
                return (.spending, .eatingOut)
            } else if (groceriesCategories.contains(categoryString)) {
                return (.fixed, .groceries)
            } else if (shoppingCategories.contains(categoryString)) {
                return (.spending, .shopping)
            } else if (transportationCategories.contains(categoryString)) {
                return (.fixed, .transportation)
            } else if (entertainmentCategories.contains(categoryString)) {
                return (.spending, .entertainment)
            }
        }

        return (bucket, category)
    }

    private func getCategoryFromCreditCardCategory(_ category: String) -> Category? {
        let ignoreCatgories = ["Payment"]
        guard !ignoreCatgories.contains(category) else { return nil }

        let housingCategories = ["Hotels"]
        let foodCategories = ["Restaurants"]
        let groceriesCategories = ["Grocery"]
        let shoppingCategories = ["Shopping"]
        let transportationCategories = ["Airlines", "Transportation"]
        let entertainmentCategories = ["Entertainment"]

        if (housingCategories.contains(category)) {
            return .housing
        } else if (foodCategories.contains(category)) {
            return .eatingOut
        } else if (groceriesCategories.contains(category)) {
            return .groceries
        } else if (shoppingCategories.contains(category)) {
            return .shopping
        } else if (transportationCategories.contains(category)) {
            return .transportation
        } else if (entertainmentCategories.contains(category)) {
            return .entertainment
        }

        return .misc
    }

// MARK: Helper functions
    // TODO: add helpers that have this take in Ints

    func expensesSortedByDate(with year: String, and month: String) -> [Expense] {
        return expenses(with: year, and: month).sorted { $0.date < $1.date }
    }

    func expenses(with year: String, and month: String) -> [Expense] {
        return allExpenses.filter { $0.date.year == year && $0.date.month == month }
    }

    func expenses(for bucket: Bucket) -> [Expense] {
        return allExpenses.filter { $0.bucket == bucket }
    }

    func expenses(with year: String, and month: String, in bucket: Bucket) -> [Expense] {
        let e = expenses(with: year, and: month)
        return e.filter { $0.bucket == bucket }
    }

    func expenses(with year: String, and month: String, in category: Category) -> [Expense] {
        let e = expenses(with: year, and: month)
        return e.filter { $0.category == category }
    }

    func totalExpense(with year: String, and month: String, in bucket: Bucket) -> Double {
        let e = expenses(with: year, and: month, in: bucket)
        return e.reduce(0.0) { $0 + $1.amount }
    }

    func totalExpense(with year: String, and month: String, in category: Category) -> Double {
        let e = expenses(with: year, and: month, in: category)
        return e.reduce(0.0) { $0 + $1.amount }
    }

    func budget(for bucket: Bucket) -> Double {
        return budget[bucket] ?? 0.0
    }

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

// MARK: Creating data

    func newExpense(title: String, date: Date, amount: Double, bucket: Bucket, category: Category) -> Expense {
        return Expense(id: UUID().uuidString, title: title, date: date, amount: amount, bucket: bucket, category: category)
    }

    func addNewExpense(title: String, date: Date, amount: Double, bucket: Bucket, category: Category) -> Bool {
        let newExpense = newExpense(title: title, date: date, amount: amount, bucket: bucket, category: category)
        return addExpense(expense: newExpense)
    }

    public func addExpenses(_ expenses: [Expense]) -> [Expense] {
        var expensesFailed: [Expense] = []
        for expense in expenses {
            let added = addExpense(expense: expense)
            if !added {
                print("Error adding expense: \(expense)")
                expensesFailed.append(expense)
            }
        }
        return expensesFailed
    }

    public func addExpense(expense: Expense) -> Bool {
        guard let amountString = numberFormatter.string(from: expense.amount as NSNumber) else {
            print("Error converting expense's amount (\(expense.amount)) to a String")
            return false
        }

        let newExpenseDictionary = [
            "title": expense.title,
            "date": expense.date.timeIntervalSince1970,
            "amount": Double(amountString) ?? 0.0,
            "bucket": expense.bucket.rawValue,
            "category": expense.category.rawValue,
        ] as [String : Any]

        guard let autoId = expenseRef.childByAutoId().key else {
            print("Error getting new auto id for expense")
            return false
        }

        expenseRef.child("\(autoId)").setValue(newExpenseDictionary) { (error, ref) in
            if let error = error {
                print("Error adding new expense: \(error.localizedDescription)")
            } else {
                expense.id = autoId
                self.allExpenses.append(expense)
            }
        }

        // TODO: handle error with async
        return true
    }

// MARK: Reading data

    private func loadExpenses() {
        var expenses = [Expense]()
        expenseRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error = error {
                print("Error getting expense data: \(error.localizedDescription)")
                return
            }

            guard let value = snapshot?.value else {
                print("No expense data available")
                return
            }


            if let data = value as? [String: [String: Any]] {
                for (expenseId, expenseData) in data {
                    guard let expenseDate = expenseData["date"] as? TimeInterval else {
                        print("ERROR: failed to get expense's date")
                        continue
                    }

                    let expense = Expense(
                        id: expenseId,
                        title: expenseData["title"] as! String,
                        date: Date(timeIntervalSince1970: expenseDate),
                        amount: expenseData["amount"] as! Double,
                        bucket: Bucket.get(from: expenseData["bucket"] as! String),
                        category: Category.get(from: expenseData["category"] as! String)
                    )

//                    print("Expense: \(expense)")
                    expenses.append(expense)
                }
            }

            Task { @MainActor in
                self.allExpenses = expenses
            }
        }
    }

    private func loadBudgets() {
        budgetRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error = error {
                print("Error getting budgets: \(error.localizedDescription)")
                return
            }

            guard let value = snapshot?.value else {
                print("No budget data available")
                return
            }

            if let data = value as? [String: Any] {
                for (bucketString, budgetAmount) in data {
                    let bucket = Bucket.get(from: bucketString)

                    budget[bucket] = budgetAmount as? Double ?? 0.0

                    print("Budget for bucket \(bucket.name) is \(String(describing: budget[bucket]))")
                }
            }
        }
    }

// MARK: Updating data

    public func updateExpense(expense: Expense) {
        let updatedExpense = [
            "title": expense.title,
            "date": expense.date.timeIntervalSince1970,
            "amount": expense.amount,
            "bucket": expense.bucket.name,
            "category": expense.category.name,
        ] as [String : Any]

        guard let expenseID = expense.id else {
            print("Error expense does not have a id, cannot complete update action")
            return
        }

        expenseRef.child(expenseID).updateChildValues(updatedExpense) { error, _ in
            if let error = error {
                print("Error updating expense w/ id \(expenseID): \(error.localizedDescription)")
            }
        }
    }

    public func updateBudget(for bucket: Bucket, to amount: Double) {
        let updatedBudget = [
            "\(bucket.name.lowercased())": amount,
        ] as [String : Any]

        budgetRef.updateChildValues(updatedBudget) { error, _ in
            if let error = error {
                print("Error updating budget for bucket \(bucket.name): \(error.localizedDescription)")
            }
        }
    }

// MARK: Deleting data

    public func deleteExpense(id: String) {
        expenseRef.child(id).removeValue() { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("Error deleting expense w/ id \(id): \(error.localizedDescription)")
            } else {
                Task { @MainActor in
                    if let index = self.allExpenses.firstIndex(where: { $0.id == id }) {
                        self.allExpenses.remove(at: index)

                        print("Deleted expense w/ id \(id))")
                    }
                }
            }
        }
    }
}
