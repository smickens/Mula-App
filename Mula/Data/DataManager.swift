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
        accountRef = dbRef.child("account")
        expenseRef = dbRef.child("expense")
        importBatchRef = dbRef.child("importBatch")
        transactionRef = dbRef.child("transaction")

        loadAccounts()
        loadImportBatches()
        loadTransactions()
        loadExpenses()
    }

    internal var accountRef: DatabaseReference
    internal var expenseRef: DatabaseReference
    internal var importBatchRef: DatabaseReference
    internal var transactionRef: DatabaseReference

    var accounts: [Account] = []
    var importBatches: [ImportBatch] = []
    var transactions: [Transaction] = []

    var allExpenses: [Expense] = []

    // MARK: - Transactions Queries

    func transactionsSortedByDate(with year: String, and month: String) -> [Transaction] {
        transactions(with: year, and: month).sorted { $0.date < $1.date }
    }

    func transactions(with year: String, and month: String) -> [Transaction] {
        transactions.filter { $0.date.year == year && $0.date.month == month }
    }

    func transactions(with year: String, and month: String, in category: TransactionCategory) -> [Transaction] {
        let filtered = transactions(with: year, and: month)
        return filtered.filter { $0.category == category }
    }

    func totalTransactions(with year: String, and month: String, in category: TransactionCategory) -> Double {
        let filtered = transactions(with: year, and: month, in: category)
        return filtered.reduce(0.0) { $0 + $1.amount }
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
