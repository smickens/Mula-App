//
//  DataManager.swift
//  Mula
//
//  Created by Shanti Mickens on 7/14/24.
//

import Firebase

final class DataManager {

    // Prevent clients from creating another instance
    private init() {
        loadExpenses()
        loadIncomes()
    }

    static let shared = DataManager()

    private lazy var dbReference: DatabaseReference = {
        return Database.database().reference()
    }()

    lazy var fakeExpensesReference: DatabaseReference = {
        return dbReference.child("fakeExpenses")
    }()

    lazy var expenseRef: DatabaseReference = {
        return dbReference.child("expense")
    }()

    lazy var incomeRef: DatabaseReference = {
        return dbReference.child("income")
    }()

    var expenses: [Expense] = []
    var incomes: [Income] = []
//    private(set) var expenses: [Expense]? {
//        didSet {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "firebaseDataDidUpdateNotification"), object: nil)
//        }
//    }

    private func category(from categoryString: String) -> Category {
        if categoryString == "transportation" {
            return .transportation
        } else if categoryString == "housing" {
            return .housing
        } else if categoryString == "groceries" {
            return .groceries
        } else if categoryString == "eating out" {
            return .eatingOut
        } else if categoryString == "shopping" {
            return .shopping
        } else if categoryString == "entertainment" {
            return .entertainment
        }
        return .misc
    }

    private func bucket(from bucketString: String) -> Bucket {
        if bucketString == "fixed" {
            return .fixed
        } else if bucketString == "saving" {
            return .saving
        } else if bucketString == "investment" {
            return .investment
        } else if bucketString == "spending" {
            return .spending
        }
        return .fixed
    }

    private func loadExpenses() {
        expenseRef.getData { error, snapshot in
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
                        bucket: self.bucket(from: expenseData["bucket"] as! String),
                        category: self.category(from: expenseData["category"] as! String)
                    )

                    print("Expense: \(expense)")
                    self.expenses.append(expense)
                }
            }
        }
    }

    func expenses(for month: String) -> [Expense] {
        return expenses.filter { $0.date.month == month }
    }

    func incomes(for month: String) -> [Income] {
        return incomes.filter { $0.date.month == month }
    }

    func expenses(for bucket: Bucket) -> [Expense] {
        return expenses.filter { $0.bucket == bucket }
    }

    func expenses(for month: String, in bucket: Bucket) -> [Expense] {
        let e = expenses(for: month)
        return e.filter { $0.bucket == bucket }
    }

    func total(for month: String, in bucket: Bucket) -> Double {
        let e = expenses(for: month, in: bucket)
        return e.reduce(0.0) { $0 + $1.amount }
    }

    func totalIncome(for month: String) -> Double {
        let i = incomes(for: month)
        return i.reduce(0.0) { $0 + $1.amount }
    }

    func addFakeExpense() {
        let newExpense = ["name": "expense #\(Int.random(in: 1...20))",
                          "amount": "$\(Double.random(in: 10...100))"]

        fakeExpensesReference.childByAutoId().setValue(newExpense) { (error, ref) in
            if let error = error {
                print("Error adding new expense: \(error.localizedDescription)")
            } else {
                print("New expense added successfully!")
            }
        }
    }

    func readFakeExpenses() {
        fakeExpensesReference.getData { error, snapshot in
            if let error = error {
                print("Error getting data: \(error.localizedDescription)")
                return
            }

            guard let snapshot else {
                print("No data available")
                return
            }

            if let value = snapshot.value {
                print("Snapshot value: \(value)")

                // If the data is a dictionary
                if let users = value as? [String: Any] {
                    for (userId, userData) in users {
                        print("User ID: \(userId), Data: \(userData)")
                    }
                }
            } else {
                print("No data available")
            }
        }
    }

    private func loadIncomes() {
        incomeRef.getData { error, snapshot in
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

                    print("Income: \(income)")
                    self.incomes.append(income)
                }
            }
        }
    }

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
