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

        print("Number of Expenses Loaded: \(allExpenses.count)")
        print("Number of Incomes Loaded: \(allIncomes.count)")
    }

    private var expenseRef: DatabaseReference
    private var incomeRef: DatabaseReference

    private var allExpenses: [Expense] = []
    private var allIncomes: [Income] = []

    private var hasLoadedExpenses: Bool = false {
        didSet {
            if hasLoadedExpenses && hasLoadedIncomes {
                refreshData(for: Date().month)
            }
        }
    }
    private var hasLoadedIncomes: Bool = false {
        didSet {
            if hasLoadedExpenses && hasLoadedIncomes {
                refreshData(for: Date().month)
            }
        }
    }

    @Published var expensesForSelectedMonth: [Expense] = []
    @Published var incomesForSelectedMonth: [Income] = []
    @Published var bucketTotalsForSelectedMonth: [Bucket: Double] = [:]
    @Published var categoryTotalsForSelectedMonth: [Category: Double] = [:]

   public var transactionsForSelectedMonth: [Transaction] {
        return (expensesForSelectedMonth + incomesForSelectedMonth).sorted(by: { $0.date < $1.date })
    }

    public func refreshData(for selectedMonth: String) {
        print("Refreshing data...")
        expensesForSelectedMonth = DataManager.shared.expenses(for: selectedMonth)
        incomesForSelectedMonth = DataManager.shared.incomes(for: selectedMonth)
        print("\(expensesForSelectedMonth.count) expenses in selected month")
        print("\(incomesForSelectedMonth.count) incomes in selected month")

        for bucket in Bucket.allCases {
            if bucket == .income {
                bucketTotalsForSelectedMonth[bucket] = totalIncome(for: selectedMonth)
            } else {
                bucketTotalsForSelectedMonth[bucket] = totalExpense(for: selectedMonth, in: bucket)
            }
            print("Bucket \(bucket.name): $\(bucketTotalsForSelectedMonth[bucket] ?? 0.0)")
        }

        for category in Category.allCases {
            categoryTotalsForSelectedMonth[category] = totalExpense(for: selectedMonth, in: category)
            print("Category \(category.name): $\(categoryTotalsForSelectedMonth[category] ?? 0.0)")
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
//
//    func readFakeExpenses() {
//        fakeExpensesReference.getData { error, snapshot in
//            if let error = error {
//                print("Error getting data: \(error.localizedDescription)")
//                return
//            }
//
//            guard let snapshot else {
//                print("No data available")
//                return
//            }
//
//            if let value = snapshot.value {
//                print("Snapshot value: \(value)")
//
//                // If the data is a dictionary
//                if let users = value as? [String: Any] {
//                    for (userId, userData) in users {
//                        print("User ID: \(userId), Data: \(userData)")
//                    }
//                }
//            } else {
//                print("No data available")
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
