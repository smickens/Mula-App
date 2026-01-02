//
//  ImportProcessor.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//


import Foundation

// TODO: might move each Bank to an extension file

/// Handles parsing and processing of CSV files into `Transaction` models.
struct ImportProcessor {

    /// Main entry point to process CSV content into transactions.
    static func processFileContentIntoTransactions(_ content: String) -> [Transaction] {
        var transactions: [Transaction] = []
        let rows = content.components(separatedBy: .newlines)
        guard rows.count > 1 else { return [] }

        // Detect bank type based on number of columns
        let numColumns = rows.first?.components(separatedBy: ",").count ?? 0
        let bank: Bank = numColumns == 8 ? .apple : (numColumns == 5 ? .usBank : .bilt)

        for row in rows.dropFirst() {
            guard !row.isEmpty else { continue }

            let transaction: Transaction?
            switch bank {
            case .apple:
                transaction = processAppleTransaction(row)
            case .usBank:
                transaction = processUSBankTransaction(row)
            case .bilt:
                transaction = processBiltTransaction(row)
            }

            if var t = transaction {
                normalizeTransaction(&t)
                transactions.append(t)
            }
        }

        return transactions
    }

    // MARK: - Transaction Parsing

    /// Renames or categorizes common merchants for consistency
    private static func normalizeTransaction(_ t: inout Transaction) {
        if t.title.localizedCaseInsensitiveContains("Uber Eats") {
            t.title = "Uber Eats"
            t.category = .eatingOut
        } else if t.title.localizedCaseInsensitiveContains("Uber") {
            t.title = "Uber"
            t.category = .transit
        } else if t.title.localizedCaseInsensitiveContains("Lyft") {
            t.title = "Lyft"
            t.category = .transit
        } else if t.title.localizedCaseInsensitiveContains("SAFEWAY") {
            t.title = "Safeway"
            t.category = .groceries
        } else if t.title.localizedCaseInsensitiveContains("TARGET") {
            t.title = "Target"
            t.category = .groceries
        } else if t.title.localizedCaseInsensitiveContains("DUNKIN") {
            t.title = "Dunkin"
            t.category = .eatingOut
        } else if t.title.localizedCaseInsensitiveContains("return") {
            t.category = .refund
        }
    }

    // MARK: Apple

    private static func classifyFromCreditCardCategory(_ categoryString: String) -> (TransactionCategory) {
        switch categoryString {
        case "Hotels": return .housing
        case "Restaurants": return .eatingOut
        case "Grocery": return .groceries
        case "Shopping": return .shopping
        case "Airlines", "Transportation": return .transit
        case "Entertainment": return .entertainment
        default: return .other
        }
    }

    private static func processAppleTransaction(_ row: String) -> Transaction? {
        // ["Transaction Date", "Clearing Date", "Description", "Merchant", "Category", "Type", "Amount (USD)", "Purchased By"]
        let values = parseCSVLine(row)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let date = dateFormatter.date(from: values[0]) else {
            print("Missing date for transaction: \(row)")
            return nil
        }

        let categoryString = values[4]
        guard categoryString != "Payment" else {
            print("Skipping transaction row for payment on credit card")
            return nil
        }

        let title = values[3]
        let amount = (Double(values[6]) ?? 0.0) * -1
        let category = classifyFromCreditCardCategory(categoryString)

        return Transaction(
            id: UUID(),
            accountId: Bank.apple.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category,
            type: .expense
        )
    }

    // MARK: US Bank

    private static let usBankKnownNames: [String: (String, TransactionCategory, TransactionType)] = [
        "ELECTRONIC DEPOSIT APPLE INC.": ("Apple Job", .income, .income),
        "WEB AUTHORIZED PMT VENMO": ("Venmo (out)", .entertainment, .transfer),
        "ELECTRONIC DEPOSIT VENMO": ("Venmo (in)", .other, .transfer),
        "ELECTRONIC WITHDRAWAL ATT": ("Internet Bill", .housing, .expense),
        "ELECTRONIC WITHDRAWAL FID BKG SVC LLC": ("Fidelity Investment", .investment, .transfer),
        "ELECTRONIC DEPOSIT APPLE GS SAVINGS": ("Transfer from Apple Savings", .transfer, .transfer),
        "WEB AUTHORIZED PMT APPLE GS SAVINGS": ("Withdrawal to Apple Savings", .savings, .transfer),
        "WEB AUTHORIZED PMT APPLECARD GSBANK": ("Apple Card Payment", .creditCardPayment, .transfer),
        "WEB AUTHORIZED PMT WELLS FARGO CARD": ("Bilt Card Payment", .creditCardPayment, .transfer),
        "WEB AUTHORIZED PMT CHASE CREDIT CRD": ("Chase Card Payment", .creditCardPayment, .transfer),
        "MOBILE BANKING PAYMENT TO CREDIT CARD 5895": ("US Bank 5895 Card Payment", .creditCardPayment, .transfer),
        "MOBILE BANKING PAYMENT TO CREDIT CARD 9996": ("US Bank 9996 Card Payment", .creditCardPayment, .transfer),
    ]

    private static func processUSBankTransaction(_ row: String) -> Transaction? {
        // ["Date", "Transaction", "Name", "Memo", "Amount"]
        let values = parseCSVLine(row)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: values[0]) else { return nil }

        var title = values[2]

        let ignored = [
            "MONTHLY MAINTENANCE FEE",
            "MONTHLY MAINTENANCE FEE WAIVED"
        ]
        guard !ignored.contains(title) else {
            print("Skipping transaction row for waived maintenance fee")
            return nil
        }

        let amount = Double(values[4]) ?? 0.0
        var category: TransactionCategory = .other
        var type: TransactionType = .expense

        if let (newTitle, newCategory, newType) = usBankKnownNames[title] {
            title = newTitle
            category = newCategory
            type = newType
        }

        return Transaction(
            id: UUID(),
            accountId: Bank.usBank.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category,
            type: type
        )
    }

    // MARK: Bilt / Wells Fargo

    private static let biltKnownNames: [String: (String, TransactionCategory, TransactionType)] = [
        "BPS*BILT RENT NEW YORK NY": ("Rent", .housing, .expense),
        "BPS*BILT REWARDS B NEW YORK NY": ("Rent", .housing, .expense),
        "TST*BAE - CAMPBELL CAMPBELL CA": ("Best Artisan Empanadas", .eatingOut, .expense),
        "APPLE CAFFE AP01:1 CUPERTINO CA": ("Apple Caffe", .eatingOut, .expense),
        "CVS/PHARMACY #09856 SUNNYVALE CA": ("CVS", .groceries, .expense),
        "APPLE ESPR BAR AP01 S5 CUPERTINO CA": ("Apple Caffe", .eatingOut, .expense),
        "WEST SAN JOSE GROCER SAN JOSE CA": ("Grocery Outlet", .groceries, .expense),
    ]

    private static func processBiltTransaction(_ row: String) -> Transaction? {
        // ["Date", "Amount", "*", "", "Name"]
        let values = parseCSVLine(row)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let date = dateFormatter.date(from: values[0].replacingOccurrences(of: "\"", with: "")) else { return nil }

        var title = values[3]

        guard title != "ONLINE ACH PAYMENT THANK YOU" else {
            print("Skipping transaction row for payment on credit card")
            return nil
        }

        let amount = Double(values[1]) ?? 0.0
        var category: TransactionCategory = .eatingOut
        var type: TransactionType = .expense

        if let (newTitle, newCategory, newType) = biltKnownNames[title] {
            title = newTitle
            category = newCategory
            type = newType
        }

        return Transaction(
            id: UUID(),
            accountId: Bank.bilt.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category,
            type: type
        )
    }

    // MARK: - Helpers

    private static func parseCSVLine(_ line: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false

        for character in line {
            if character == "\"" {
                insideQuotes.toggle()
            } else if character == "," && !insideQuotes {
                columns.append(currentColumn.trimmingCharacters(in: .whitespaces).removingQuotes())
                currentColumn = ""
            } else {
                currentColumn.append(character)
            }
        }

        // Add the last column
        columns.append(currentColumn.trimmingCharacters(in: .whitespaces).removingQuotes())

        return columns
    }
}
