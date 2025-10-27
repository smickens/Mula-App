//
//  ImportProcessor.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//


import Foundation

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

    // MARK: - Bank-specific Parsing

    private static func processAppleTransaction(_ row: String) -> Transaction? {
        // ["Transaction Date", "Clearing Date", "Description", "Merchant", "Category", "Type", "Amount (USD)", "Purchased By"]
        let columns = row.components(separatedBy: ",")
        guard columns.count >= 7 else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let date = dateFormatter.date(from: columns[0]) else { return nil }

        let title = columns[3].replacingOccurrences(of: "\"", with: "")
        let amount = (Double(columns[6].replacingOccurrences(of: "\"", with: "")) ?? 0.0) * -1
        let category = classifyFromCreditCardCategory(columns[4])

        // Ignore credit card payments
        guard columns[4] != "Payment" else { return nil }

        return Transaction(
            id: UUID(),
            accountId: Bank.apple.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category
        )
    }

    private static func processUSBankTransaction(_ row: String) -> Transaction? {
        // ["Date", "Transaction", "Name", "Memo", "Amount"]
        let columns = row.components(separatedBy: ",")
        guard columns.count >= 5 else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) else { return nil }

        let title = columns[2].replacingOccurrences(of: "\"", with: "")
        let amount = Double(columns[4].replacingOccurrences(of: "\"", with: "")) ?? 0.0
        let category: TransactionCategory = .other

        // Ignore credit card payments and waived fees
        let ignored = [
            "WEB AUTHORIZED PMT APPLECARD GSBANK",
            "WEB AUTHORIZED PMT WELLS FARGO CARD",
            "MOBILE BANKING PAYMENT TO CREDIT CARD 5895",
            "MOBILE BANKING PAYMENT TO CREDIT CARD 9996",
            "WEB AUTHORIZED PMT APPLE GS SAVINGS",
//            "ELECTRONIC DEPOSIT APPLE GS SAVINGS",
            "MONTHLY MAINTENANCE FEE",
            "MONTHLY MAINTENANCE FEE WAIVED"
        ]
        guard !ignored.contains(title) else { return nil }

        return Transaction(
            id: UUID(),
            accountId: Bank.usBank.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category
        )
    }

    private static func processBiltTransaction(_ row: String) -> Transaction? {
        // ["Date", "Amount", "*", "", "Name"]
        let columns = row.components(separatedBy: ",")
        guard columns.count >= 4 else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let date = dateFormatter.date(from: columns[0].replacingOccurrences(of: "\"", with: "")) else { return nil }

        let title = columns[3].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Double(columns[1].replacingOccurrences(of: "\"", with: "")) ?? 0.0
        let category: TransactionCategory = .other

        // Ignore credit card payments
        guard title != "ONLINE ACH PAYMENT THANK YOU" else { return nil }

        return Transaction(
            id: UUID(),
            accountId: Bank.bilt.accountId,
            title: title,
            date: date,
            amount: amount,
            category: category
        )
    }

    // MARK: - Helpers

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

    /// Renames or categorizes common merchants for consistency
    private static func normalizeTransaction(_ t: inout Transaction) {
        let mappings: [String: (String, TransactionCategory)] = [
            "ELECTRONIC DEPOSIT APPLE INC.": ("Apple Job", .income),
            "WEB AUTHORIZED PMT VENMO": ("Venmo (out)", .entertainment),
            "ELECTRONIC DEPOSIT VENMO": ("Venmo (in)", .other),
            "ELECTRONIC WITHDRAWAL ATT": ("Internet Bill", .housing),
            "BPS*BILT REWARDS B NEW YORK NY": ("Rent", .housing)
        ]

        if let map = mappings[t.title] {
            t.title = map.0
            t.category = map.1
        } else if t.title.localizedCaseInsensitiveContains("Uber Eats") {
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
        }
    }
}
