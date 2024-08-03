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
        budgetRef = dbRef.child("budget")

        loadExpenses()
        loadBudgets()
    }

    private var expenseRef: DatabaseReference
    private var budgetRef: DatabaseReference

    public var selectedMonth = Date().month {
        didSet {
            refreshData(for: selectedMonth)
        }
    }

    private var allExpenses: [Expense] = [] {
        didSet {
            refreshData(for: selectedMonth)
        }
    }

    public var budget: [Bucket: Double] = [:]

    var expensesForSelectedMonth: [Expense] = []
    var bucketTotalsForSelectedMonth: [Bucket: Double] = [:]
    var categoryTotalsForSelectedMonth: [Category: Double] = [:]

    public func refreshData(for selectedMonth: String) {
        print("Refreshing data...")
        expensesForSelectedMonth = DataManager.shared.expenses(for: selectedMonth).sorted(by: { $0.date < $1.date })

        for bucket in Bucket.allCases {
            bucketTotalsForSelectedMonth[bucket] = totalExpense(for: selectedMonth, in: bucket)
        }

        for category in Category.allCases {
            categoryTotalsForSelectedMonth[category] = totalExpense(for: selectedMonth, in: category)
        }
    }

// MARK: Helper functions

    func expenses(for month: String) -> [Expense] {
        return allExpenses.filter { $0.date.month == month }
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

    public func addExpense(expense: Expense) {
        guard let amountString = numberFormatter.string(from: expense.amount as NSNumber) else {
            print("Error converting expense's amount (\(expense.amount)) to a String")
            return
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
            return
        }

        expenseRef.child("\(autoId)").setValue(newExpenseDictionary) { (error, ref) in
            if let error = error {
                print("Error adding new expense: \(error.localizedDescription)")
            } else {
                expense.id = autoId
                self.allExpenses.append(expense)
            }
        }
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

            self.allExpenses = expenses
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
        expenseRef.child(id).removeValue() { error, _ in
            if let error = error {
                print("Error deleting expense w/ id \(id): \(error.localizedDescription)")
            } else if let expenseIndex = self.allExpenses.firstIndex(where: { $0.id == id }) {
                self.allExpenses.remove(at: expenseIndex)
            } else {
                print("Error didn't find expense id \(id) in expenses list to remove")
            }
        }
    }

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
