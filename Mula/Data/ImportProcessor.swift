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
            t.kind = .expense(.eatingOut)
        } else if t.title.localizedCaseInsensitiveContains("Uber") {
            t.title = "Uber"
            t.kind = .expense(.transit)
        } else if t.title.localizedCaseInsensitiveContains("Lyft") {
            t.title = "Lyft"
            t.kind = .expense(.transit)
        } else if t.title.localizedCaseInsensitiveContains("Safeway") {
            t.title = "Safeway"
            t.kind = .expense(.groceries)
        } else if t.title.localizedCaseInsensitiveContains("Target") {
            t.title = "Target"
            t.kind = .expense(.groceries)
        } else if t.title.localizedCaseInsensitiveContains("Dunkin") {
            t.title = "Dunkin"
            t.kind = .expense(.eatingOut)
        } else if t.title.localizedCaseInsensitiveContains("Walmart") {
            t.kind = .expense(.groceries)
        } else if t.title.localizedCaseInsensitiveContains("USAA") {
            t.title = "USAA insurance"
            t.kind = .expense(.car)
        } else if t.title.localizedCaseInsensitiveContains("return") {
            t.kind = .income(.refund)
        }
    }

    // MARK: Apple

    private static func classifyFromCreditCardCategory(_ categoryString: String) -> TransactionKind {
        switch categoryString {
        case "Hotels": return .expense(.housing)
        case "Restaurants": return .expense(.eatingOut)
        case "Grocery": return .expense(.groceries)
        case "Shopping": return .expense(.shopping)
        case "Airlines", "Transportation": return .expense(.transit)
        case "Entertainment": return .expense(.entertainment)
        default: return .expense(.other)
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
        let amount = abs(Decimal(string: values[6]) ?? 0.0)
        let kind = classifyFromCreditCardCategory(categoryString)

        return Transaction(
            id: UUID(),
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            sourceAccountId: Bank.apple.accountId
        )
    }

    // MARK: US Bank

    private static let usBankKnownNames: [String: (String, TransactionKind)] = [
        "ELECTRONIC DEPOSIT APPLE INC.": ("Apple Job", .income(.job)),
        "WEB AUTHORIZED PMT VENMO": ("Venmo (out)", .expense(.entertainment)),
        "ELECTRONIC DEPOSIT VENMO": ("Venmo (in)", .income(.other)),
        "ELECTRONIC WITHDRAWAL ATT": ("Internet Bill", .expense(.housing)),
        "ELECTRONIC WITHDRAWAL FID BKG SVC LLC": ("Fidelity Investment", .transfer(.investment)),
        "ELECTRONIC DEPOSIT APPLE GS SAVINGS": ("Transfer from Apple Savings", .transfer(.other)),
        "WEB AUTHORIZED PMT APPLE GS SAVINGS": ("Withdrawal to Apple Savings", .transfer(.savings)),
        "WEB AUTHORIZED PMT APPLECARD GSBANK": ("Apple Card Payment", .transfer(.creditCardPayment)),
        "WEB AUTHORIZED PMT WELLS FARGO CARD": ("Bilt Card Payment", .transfer(.creditCardPayment)),
        "WEB AUTHORIZED PMT CHASE CREDIT CRD": ("Chase Card Payment",.transfer(.creditCardPayment)),
        "MOBILE BANKING PAYMENT TO CREDIT CARD 5895": ("US Bank 5895 Card Payment", .transfer(.creditCardPayment)),
        "MOBILE BANKING PAYMENT TO CREDIT CARD 9996": ("US Bank 9996 Card Payment",.transfer(.creditCardPayment)),
        "MOBILE CHECK DEPOSIT": ("Mobile Check Deposit", .income(.other)),
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

        let amount = abs(Decimal(string: values[4]) ?? 0)
        var kind: TransactionKind = .expense(.other)

        if let (newTitle, newKind) = usBankKnownNames[title] {
            title = newTitle
            kind = newKind
        }

        return Transaction(
            id: UUID(),
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            sourceAccountId: Bank.usBank.accountId
        )
    }

    // MARK: Bilt / Wells Fargo

    private static let biltKnownNames: [String: (String, TransactionKind)] = [
        "BPS*BILT RENT NEW YORK NY": ("Rent", .expense(.housing)),
        "BPS*BILT REWARDS B NEW YORK NY": ("Rent", .expense(.housing)),
        "TST*BAE - CAMPBELL CAMPBELL CA": ("Best Artisan Empanadas", .expense(.eatingOut)),
        "APPLE CAFFE AP01:1 CUPERTINO CA": ("Apple Caffe", .expense(.eatingOut)),
        "CVS/PHARMACY #09856 SUNNYVALE CA": ("CVS", .expense(.groceries)),
        "APPLE ESPR BAR AP01 S5 CUPERTINO CA": ("Apple Caffe", .expense(.eatingOut)),
        "WEST SAN JOSE GROCER SAN JOSE CA": ("Grocery Outlet", .expense(.groceries)),
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

        let amount = abs(Decimal(string: values[1]) ?? 0.0)
        var kind: TransactionKind = .expense(.eatingOut)

        if let (newTitle, newKind) = biltKnownNames[title] {
            title = newTitle
            kind = newKind
        }

        return Transaction(
            id: UUID(),
            title: title,
            date: date,
            kind: kind,
            amount: amount,
            sourceAccountId: Bank.bilt.accountId
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
