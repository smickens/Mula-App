//
//  DataManager.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import Firebase
import FirebaseDatabase

@Observable final class DataManager {

    static let shared = DataManager()

    private init() {
        let dbRef = Database.database().reference()
        expenseRef = dbRef.child("expense")
        incomeRef = dbRef.child("income")

        loadExpenses()
        loadIncomes()
    }

    private var expenseRef: DatabaseReference
    private var incomeRef: DatabaseReference

    private var allExpenses: [Expense] = []
    private var allIncomes: [Income] = []

    var transactionsForSelectedMonth: [any Transaction] = []
    var expensesForSelectedMonth: [Expense] = []
    var incomesForSelectedMonth: [Income] = []
    var bucketTotalsForSelectedMonth: [Bucket: Double] = [:]
    var categoryTotalsForSelectedMonth: [Category: Double] = [:]

    // could put this on the expense list view ?
//    public var transactionsForSelectedMonth: [Transaction] {
//        return (expensesForSelectedMonth + incomesForSelectedMonth).sorted(by: { $0.date < $1.date })
//    }

    public func refreshData(for selectedMonth: String) {
        print("Refreshing data...")
        expensesForSelectedMonth = DataManager.shared.expenses(for: selectedMonth)
        incomesForSelectedMonth = DataManager.shared.incomes(for: selectedMonth)
        let transactions: [any Transaction] = expensesForSelectedMonth + incomesForSelectedMonth
        transactionsForSelectedMonth = transactions.sorted(by: { $0.date < $1.date })

//        print("\(expensesForSelectedMonth.count) expenses in selected month")
//        print("\(incomesForSelectedMonth.count) incomes in selected month")

        for bucket in Bucket.allCases {
            if bucket == .income {
                bucketTotalsForSelectedMonth[bucket] = totalIncome(for: selectedMonth)
            } else {
                bucketTotalsForSelectedMonth[bucket] = totalExpense(for: selectedMonth, in: bucket)
            }
//            print("Bucket \(bucket.name): $\(bucketTotalsForSelectedMonth[bucket] ?? 0.0)")
        }

        for category in Category.allCases {
            categoryTotalsForSelectedMonth[category] = totalExpense(for: selectedMonth, in: category)
//            print("Category \(category.name): $\(categoryTotalsForSelectedMonth[category] ?? 0.0)")
        }
    }

// MARK: Helper functions

    func expenses(for month: String) -> [Expense] {
        return allExpenses.filter { $0.date.month == month }
    }

    func incomes(for month: String) -> [Income] {
        return allIncomes.filter { $0.date.month == month }
    }

    func expenses(for bucket: Bucket) -> [Expense] {
        return allExpenses.filter { $0.bucket == bucket }
    }

    func expenses(for month: String, in bucket: Bucket) -> [Expense] {
        let e = expenses(for: month)
        return e.filter { $0.bucket == bucket }
    }

    func expenses(for month: String, in category: Category) -> [Expense] {
        let e = expenses(for: month)
        return e.filter { $0.category == category }
    }

    func totalExpense(for month: String, in bucket: Bucket) -> Double {
        let e = expenses(for: month, in: bucket)
        return e.reduce(0.0) { $0 + $1.amount }
    }

    func totalExpense(for month: String, in category: Category) -> Double {
        let e = expenses(for: month, in: category)
        return e.reduce(0.0) { $0 + $1.amount }
    }

    func totalIncome(for month: String) -> Double {
        let i = incomes(for: month)
        return i.reduce(0.0) { $0 + $1.amount }
    }

    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

// MARK: Creating data

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

            self.allExpenses = expenses
            self.hasLoadedExpenses = true
        }
    }

    private func loadIncomes() {
        var incomes = [Income]()
        incomeRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error = error {
                print("Error getting income data: \(error.localizedDescription)")
                return
            }

            guard let value = snapshot?.value else {
                print("No income data available")
                return
            }


            if let data = value as? [String: [String: Any]] {
                for (incomeId, incomeData) in data {
                    guard let incomeDate = incomeData["date"] as? TimeInterval else {
                        print("ERROR: failed to get income's date")
                        continue
                    }

                    let income = Income(
                        id: incomeId,
                        title: incomeData["title"] as! String,
                        date: Date(timeIntervalSince1970: incomeDate),
                        amount: incomeData["amount"] as! Double
                    )

//                    print("Income: \(income)")
                    incomes.append(income)
                }
            }

            self.allIncomes = incomes
            self.hasLoadedIncomes = true
        }
    }

    private var hasLoadedExpenses: Bool = false {
        didSet {
            print("Number of Expenses Loaded: \(allExpenses.count)")
            if hasLoadedExpenses && hasLoadedIncomes {
                refreshData(for: Date().month)
            }
        }
    }
    private var hasLoadedIncomes: Bool = false {
        didSet {
            print("Number of Incomes Loaded: \(allIncomes.count)")
            if hasLoadedExpenses && hasLoadedIncomes {
                refreshData(for: Date().month)
            }
        }
    }

// MARK: Updating data

    public func updateExpense(id: String, title: String, date: Date, amount: Double, bucket: Bucket, category: Category) {
        guard let amountString = numberFormatter.string(from: amount as NSNumber) else {
            print("Error converting expense's amount (\(amount)) to a String")
            return
        }

        let updatedExpense = [
            "title": title,
            "date": date.timeIntervalSince1970,
            "amount": Double(amountString) ?? 0.0,
            "bucket": bucket.name,
            "category": category.name,
        ] as [String : Any]

        print("updated expense")
        print(updatedExpense)

        expenseRef.child(id).updateChildValues(updatedExpense) { error, _ in
            if let error = error {
                print("Error updating expense w/ id \(id): \(error.localizedDescription)")
            }
        }
    }

    public func updateIncome(id: String, title: String, date: Date, amount: Double) {
        guard let amountString = numberFormatter.string(from: amount as NSNumber) else {
            print("Error converting income's amount (\(amount)) to a String")
            return
        }

        let updatedIncome = [
            "title": title,
            "date": date.timeIntervalSince1970,
            "amount": Double(amountString) ?? 0.0,
        ] as [String : Any]

        print("updated income")
        print(updatedIncome)

        incomeRef.child(id).updateChildValues(updatedIncome) { error, _ in
            if let error = error {
                print("Error updating income w/ id \(id): \(error.localizedDescription)")
            }
        }
    }

// MARK: Deleting data

    public func deleteExpense(id: String) {
        expenseRef.child(id).removeValue() { error, _ in
            if let error = error {
                print("Error deleting expense w/ id \(id): \(error.localizedDescription)")
            }
        }
    }

    public func deleteIncome(id: String) {
        incomeRef.child(id).removeValue() { error, _ in
            if let error = error {
                print("Error deleting income w/ id \(id): \(error.localizedDescription)")
            }
        }
    }


//    func addFakeExpense() {
//        let newExpense = ["name": "expense #\(Int.random(in: 1...20))",
//                          "amount": "$\(Double.random(in: 10...100))"]
//
//        fakeExpensesReference.childByAutoId().setValue(newExpense) { (error, ref) in
//            if let error = error {
//                print("Error adding new expense: \(error.localizedDescription)")
//            } else {
//                print("New expense added successfully!")
//            }
//        }
//    }

//    func uploadExpenses(expenses: [Expense]) {
//        for expense in expenses {
//            if expense.isIncome {
//                uploadIncome(income: expense)
//                continue
//            }
//
//            let formatter = NumberFormatter()
//            formatter.numberStyle = .decimal
//            formatter.maximumFractionDigits = 2
//            let amountString = formatter.string(from: expense.amount as NSNumber)!
//
//            var newExpense = [
//                "title": expense.title,
//                "date": expense.date.timeIntervalSince1970,
//                "amount": abs(Double(amountString) ?? 0.0)
//            ] as [String : Any]
//
//            let category: String
//            let subCategory: String
//            switch expense.category {
//            case .housing:
//                category = "fixed"
//                subCategory = "housing"
//            case .food:
//                category = "spending"
//                subCategory = "eating out"
//            case .shopping:
//                category = "spending"
//                subCategory = "shopping"
//            case .transportation:
//                category = "fixed"
//                subCategory = "transportation"
//            case .entertainment:
//                category = "spending"
//                subCategory = "entertainment"
//            case .misc:
//                category = "spending"
//                subCategory = "misc"
//            case .income:
//                category = "ERROR"
//                subCategory = "ERROR"
//            }
//
//            newExpense["bucket"] = category
//            newExpense["category"] = subCategory
//
//            expenseRef.childByAutoId().setValue(newExpense) { (error, ref) in
//                if let error = error {
//                    print("Error adding new expense: \(error.localizedDescription)")
//                }
//            }
//        }
//    }

//    func uploadIncome(income: Expense) {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 2
//        let amountString = formatter.string(from: income.amount as NSNumber)!
//
//        let newIncome = [
//            "title": income.title,
//            "date": income.date.timeIntervalSince1970,
//            "amount": Double(amountString) ?? 0.0,
//        ] as [String : Any]
//
//        incomeRef.childByAutoId().setValue(newIncome) { (error, ref) in
//            if let error = error {
//                print("Error adding new expense: \(error.localizedDescription)")
//            }
//        }
//    }

    // Firebase listener handle
//    var observer: AuthStateDidChangeListenerHandle?
//
//    // Checks whether user is logged in
//    func checkLoginStatus() {
//        Auth.auth().addStateDidChangeListener { (auth, user) in
//            if user == nil {
//                self.login()
//            }
//        }
//    }
//
//    // Log user in
//    func login() {
//        let email = ""
//        let password = ""
//        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
//            print(authResult!.description)
//            print(authResult!.debugDescription)
//            print(authResult!.additionalUserInfo.debugDescription)
//        }
//    }
//
//    // Start observing update .childAdded events
//    func claimObserver() {
//        self.observer = Auth.auth().addStateDidChangeListener() { (auth, user) in
//            var entries: [DataSnapshot] = []
//            self.childReference.observe(.childAdded, with: { snapshot in
//                if snapshot.hasChildren() {
//                    entries.append(snapshot)
//                }
//                self.logEntries = entries
//            })
//        }
//    }
//
//    // Release database observer
//    func releaseObserver() {
//        if self.observer != nil {
//            Auth.auth().removeStateDidChangeListener(self.observer!)
//            self.observer = nil
//        }
//    }
}
