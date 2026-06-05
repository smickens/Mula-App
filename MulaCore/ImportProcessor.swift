//
//  ImportProcessor.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

public struct ImportProcessor {
    public static func processFileContent(_ content: String) throws -> TransactionImportResult {
        let table = CSVParser.parse(content)

        guard !table.headers.isEmpty else {
            throw ImportProcessingError.missingHeaders
        }

        guard let format = BankImportFormat.detect(from: table.headers) else {
            throw ImportProcessingError.unsupportedFormat(headers: table.headers)
        }

        var transactions: [Transaction] = []
        var skippedRows: [SkippedImportRow] = []

        for row in table.dataRows {
            let rowResult = format.transaction(row)

            switch rowResult {
            case .success(let transaction):
                transactions.append(transaction)

            case .skip(let reason):
                skippedRows.append(SkippedImportRow(rowNumber: row.rowNumber, reason: reason))
            }
        }

        guard !transactions.isEmpty else {
            throw ImportProcessingError.noImportableTransactions(
                detectedBank: format.bank,
                skippedRows: skippedRows
            )
        }

        return TransactionImportResult(
            detectedBank: format.bank,
            transactions: transactions,
            skippedRows: skippedRows
        )
    }
}

public enum ImportProcessingError: LocalizedError {
    case missingHeaders
    case unsupportedFormat(headers: [String])
    case noImportableTransactions(detectedBank: Bank, skippedRows: [SkippedImportRow])

    public var errorDescription: String? {
        switch self {
        case .missingHeaders:
            return "This file does not appear to contain CSV headers."

        case .unsupportedFormat(let headers):
            return "This CSV format is not supported yet. Found headers: \(headers)."

        case .noImportableTransactions(let detectedBank, let skippedRows):
            let bankName = detectedBank.displayName

            if skippedRows.isEmpty {
                return "No importable transactions were found for \(bankName)."
            }

            return "No importable transactions were found for \(bankName). \(skippedRows.count) rows were skipped."
        }
    }
}

public struct TransactionImportResult {
    public let detectedBank: Bank?
    public let transactions: [Transaction]
    public let skippedRows: [SkippedImportRow]
}

public struct SkippedImportRow: Identifiable {
    public let id = UUID()
    public let rowNumber: Int
    public let reason: ImportSkipReason
}

public enum ImportSkipReason: Equatable {
    case unsupportedFormat
    case emptyRow
    case missingRequiredValue(String)
    case invalidDate(String)
    case invalidAmount(String)
    case ignoredTransaction(String)
}

private enum ImportRowResult {
    case success(Transaction)
    case skip(ImportSkipReason)
}

private enum AmountSignConvention {
    case positiveIsExpense
    case negativeIsExpense

    func defaultKind(for signedAmount: Decimal, expenseKind: TransactionKind) -> TransactionKind {
        switch self {
        case .positiveIsExpense:
            return signedAmount < 0 ? .income(.refund) : expenseKind
        case .negativeIsExpense:
            return signedAmount > 0 ? .income(.refund) : expenseKind
        }
    }
}

private struct BankImportFormat {
    let bank: Bank
    let matches: ([String]) -> Bool
    let transaction: (CSVRow) -> ImportRowResult

    static func detect(from headers: [String]) -> BankImportFormat? {
        allFormats.first { $0.matches(headers) }
    }

    private static let allFormats: [BankImportFormat] = [
        .apple,
        .fidelity401k,
        .usBank,
        .wellsFargo
    ]
}

private extension BankImportFormat {
    static let apple = BankImportFormat(
        bank: .apple,
        matches: { headers in
            headers.containsAll(["Transaction Date", "Merchant", "Category", "Amount (USD)"])
        },
        transaction: { row in
            let dateString = row.value(for: "Transaction Date")
            let merchant = row.value(for: "Merchant")
            let category = row.value(for: "Category")
            let amountString = row.value(for: "Amount (USD)")

            guard !merchant.isEmpty else {
                return .skip(.missingRequiredValue("Merchant"))
            }

            guard category != "Payment" else {
                return .skip(.ignoredTransaction("Credit card payment"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let baseKind = AmountSignConvention.positiveIsExpense.defaultKind(
                for: signedAmount,
                expenseKind: TransactionKind.expenseCategoryFromCreditCard(category)
            )
            let transaction = ImportedTransactionCandidate(
                title: merchant,
                date: date,
                signedAmount: signedAmount,
                kind: baseKind,
                sourceAccountId: Bank.apple.accountId
            )
            .applyingGlobalRules()
            .applyingBankRules(BankImportRules.apple)
            .transaction

            return .success(transaction)
        }
    )

    static let usBank = BankImportFormat(
        bank: .usBank,
        matches: { headers in
            headers.containsAll(["Date", "Transaction", "Name", "Memo", "Amount"])
        },
        transaction: { row in
            let dateString = row.value(for: "Date")
            let title = row.value(for: "Name")
            let amountString = row.value(for: "Amount")

            guard !title.isEmpty else {
                return .skip(.missingRequiredValue("Name"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "yyyy-MM-dd") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let candidate = ImportedTransactionCandidate(
                title: title,
                date: date,
                signedAmount: signedAmount,
                kind: AmountSignConvention.negativeIsExpense.defaultKind(for: signedAmount, expenseKind: .expense(.other)),
                sourceAccountId: Bank.usBank.accountId
            )
            .applyingGlobalRules()

            if BankImportRules.usBankIgnoredTitles.contains(candidate.title) {
                return .skip(.ignoredTransaction(candidate.title))
            }

            return .success(candidate.applyingBankRules(BankImportRules.usBank).transaction)
        }
    )

    static let fidelity401k = BankImportFormat(
        bank: .fidelity401k,
        matches: { headers in
            headers.containsAll(["Run Date", "Action", "Description", "Amount ($)"])
        },
        transaction: { row in
            let action = row.value(for: "Action")

            guard action.caseInsensitiveCompare("Contributions") == .orderedSame else {
                return .skip(.ignoredTransaction(action))
            }

            let dateString = row.value(for: "Run Date")
            let description = row.value(for: "Description")
            let amountString = row.value(for: "Amount ($)")

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let descriptionText = description.isEmpty ? "(No Desc)" : description

            let transaction = ImportedTransactionCandidate(
                title: "Contributions - \(descriptionText)",
                date: date,
                signedAmount: signedAmount,
                kind: .saving(.contribution),
                sourceAccountId: Bank.fidelity401k.accountId
            )
            .transaction

            return .success(transaction)
        }
    )

    static let wellsFargo = BankImportFormat(
        bank: .wellsFargo,
        matches: { headers in
            headers.containsAll(["DATE", "DESCRIPTION", "AMOUNT"])
        },
        transaction: { row in
            let dateString = row.value(for: "DATE")
            let title = row.value(for: "DESCRIPTION")
            let amountString = row.value(for: "AMOUNT")

            guard !title.isEmpty else {
                return .skip(.missingRequiredValue("DESCRIPTION"))
            }

            guard title != "ONLINE ACH PAYMENT THANK YOU" else {
                return .skip(.ignoredTransaction("Credit card payment"))
            }

            guard let date = DateImportParser.date(from: dateString, format: "MM/dd/yyyy") else {
                return .skip(.invalidDate(dateString))
            }

            guard let signedAmount = Decimal(string: amountString) else {
                return .skip(.invalidAmount(amountString))
            }

            let transaction = ImportedTransactionCandidate(
                title: title,
                date: date,
                signedAmount: signedAmount,
                kind: AmountSignConvention.negativeIsExpense.defaultKind(for: signedAmount, expenseKind: .expense(.eatingOut)),
                sourceAccountId: Bank.wellsFargo.accountId
            )
            .applyingGlobalRules()
            .applyingBankRules(BankImportRules.wellsFargo)
            .transaction

            return .success(transaction)
        }
    )
}

private struct ImportedTransactionCandidate {
    var title: String
    let date: Date
    let signedAmount: Decimal
    var kind: TransactionKind
    let sourceAccountId: UUID

    var transaction: Transaction {
        Transaction(
            id: UUID(),
            title: title,
            date: date,
            kind: kind,
            amount: abs(signedAmount),
            sourceAccountId: sourceAccountId
        )
    }

    func applyingGlobalRules() -> ImportedTransactionCandidate {
        applyingRules(ImportRules.global)
    }

    func applyingBankRules(_ rules: [ImportRule]) -> ImportedTransactionCandidate {
        applyingRules(rules)
    }

    private func applyingRules(_ rules: [ImportRule]) -> ImportedTransactionCandidate {
        var candidate = self

        for rule in rules where rule.matches(candidate) {
            candidate.title = rule.newTitle ?? candidate.title
            candidate.kind = rule.kind ?? candidate.kind
        }

        return candidate
    }
}

private struct ImportRule {
    let match: String
    let matchType: MatchType
    let newTitle: String?
    let kind: TransactionKind?
    let appliesTo: KindScope

    init(
        match: String,
        matchType: MatchType,
        newTitle: String?,
        kind: TransactionKind?,
        appliesTo: KindScope = .any
    ) {
        self.match = match
        self.matchType = matchType
        self.newTitle = newTitle
        self.kind = kind
        self.appliesTo = appliesTo
    }

    enum MatchType {
        case exact
        case contains
    }

    enum KindScope {
        case any
        case expense
        case income
    }

    func matches(_ candidate: ImportedTransactionCandidate) -> Bool {
        guard appliesTo.matches(candidate.kind) else {
            return false
        }

        switch matchType {
        case .exact:
            return candidate.title.caseInsensitiveCompare(match) == .orderedSame
        case .contains:
            return candidate.title.localizedCaseInsensitiveContains(match)
        }
    }
}

private extension ImportRule.KindScope {
    func matches(_ kind: TransactionKind) -> Bool {
        switch (self, kind) {
        case (.any, _), (.expense, .expense), (.income, .income):
            return true
        case (.expense, _), (.income, _):
            return false
        }
    }
}

private enum ImportRules {
    static let global: [ImportRule] = [
        ImportRule(match: "Uber Eats", matchType: .contains, newTitle: "Uber Eats", kind: .expense(.eatingOut), appliesTo: .expense),
        ImportRule(match: "Uber", matchType: .contains, newTitle: "Uber", kind: .expense(.transit), appliesTo: .expense),
        ImportRule(match: "Lyft", matchType: .contains, newTitle: "Lyft", kind: .expense(.transit), appliesTo: .expense),
        ImportRule(match: "Safeway", matchType: .contains, newTitle: "Safeway", kind: .expense(.groceries), appliesTo: .expense),
        ImportRule(match: "Target", matchType: .contains, newTitle: "Target", kind: .expense(.groceries), appliesTo: .expense),
        ImportRule(match: "Dunkin", matchType: .contains, newTitle: "Dunkin", kind: .expense(.eatingOut), appliesTo: .expense),
        ImportRule(match: "Walmart", matchType: .contains, newTitle: nil, kind: .expense(.groceries), appliesTo: .expense),
        ImportRule(match: "USAA", matchType: .contains, newTitle: "USAA insurance", kind: .expense(.car), appliesTo: .expense),
        ImportRule(match: "return", matchType: .contains, newTitle: nil, kind: .income(.refund)),
        ImportRule(match: "Hollister", matchType: .contains, newTitle: nil, kind: .expense(.shopping), appliesTo: .expense)
    ]
}

private enum BankImportRules {
    static let usBankIgnoredTitles: Set<String> = [
        "MONTHLY MAINTENANCE FEE",
        "MONTHLY MAINTENANCE FEE WAIVED",
        "WEB AUTHORIZED PMT APPLECARD GSBANK",
        "WEB AUTHORIZED PMT WELLS FARGO CARD",
        "WEB AUTHORIZED PMT CHASE CREDIT CRD",
        "WEB AUTHORIZED PMT APPLE GS SAVINGS",
        "ELECTRONIC DEPOSIT APPLE GS SAVINGS",
        "MOBILE BANKING PAYMENT TO CREDIT CARD 5895",
        "MOBILE BANKING PAYMENT TO CREDIT CARD 9996",
        "ELECTRONIC DEPOSIT APPLE INC.",
        "ELECTRONIC WITHDRAWAL FID BKG SVC LLC"
    ]

    static let apple: [ImportRule] = []

    static let usBank: [ImportRule] = [
        ImportRule(match: "WEB AUTHORIZED PMT VENMO", matchType: .exact, newTitle: "Venmo (out)", kind: .expense(.entertainment)),
        ImportRule(match: "ELECTRONIC DEPOSIT VENMO", matchType: .exact, newTitle: "Venmo (in)", kind: .income(.other)),
        ImportRule(match: "ELECTRONIC WITHDRAWAL ATT", matchType: .exact, newTitle: "Internet Bill", kind: .expense(.housing)),
        ImportRule(match: "MOBILE CHECK DEPOSIT", matchType: .exact, newTitle: "Mobile Check Deposit", kind: .income(.other)),
        ImportRule(match: "ZELLE INSTANT PMT FROM", matchType: .exact, newTitle: nil, kind: .income(.other)),
        ImportRule(match: "ZELLE INSTANT PMT TO", matchType: .exact, newTitle: nil, kind: .expense(.entertainment))
    ]

    static let wellsFargo: [ImportRule] = [
        ImportRule(match: "BPS*BILT RENT NEW YORK NY", matchType: .exact, newTitle: "Rent", kind: .expense(.housing), appliesTo: .expense),
        ImportRule(match: "BPS*BILT REWARDS B NEW YORK NY", matchType: .exact, newTitle: "Rent", kind: .expense(.housing), appliesTo: .expense),
        ImportRule(match: "TST*BAE - CAMPBELL CAMPBELL CA", matchType: .exact, newTitle: "Best Artisan Empanadas", kind: .expense(.eatingOut), appliesTo: .expense),
        ImportRule(match: "APPLE CAFFE AP01:1 CUPERTINO CA", matchType: .exact, newTitle: "Apple Caffe", kind: .expense(.eatingOut), appliesTo: .expense),
        ImportRule(match: "CVS/PHARMACY #09856 SUNNYVALE CA", matchType: .exact, newTitle: "CVS", kind: .expense(.groceries), appliesTo: .expense),
        ImportRule(match: "APPLE ESPR BAR AP01 S5 CUPERTINO CA", matchType: .exact, newTitle: "Apple Caffe", kind: .expense(.eatingOut), appliesTo: .expense),
        ImportRule(match: "WEST SAN JOSE GROCER SAN JOSE CA", matchType: .exact, newTitle: "Grocery Outlet", kind: .expense(.groceries), appliesTo: .expense)
    ]
}

private enum DateImportParser {
    static func date(from string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

private extension TransactionKind {
    static func expenseCategoryFromCreditCard(_ categoryString: String) -> TransactionKind {
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
}

private extension Array where Element == String {
    func containsAll(_ values: [String]) -> Bool {
        values.allSatisfy { value in
            contains { $0.caseInsensitiveCompare(value) == .orderedSame }
        }
    }
}
