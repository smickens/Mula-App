//
//  ImportProcessor.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

public struct ImportProcessor {
    public static func processFileContent(_ content: String) throws -> ImportResult {
        let document = CSVParser.parse(content)

        guard !document.rows.isEmpty else {
            throw ImportProcessingError.missingHeaders
        }

        guard let detectedFormat = ImportFormat.detect(in: document) else {
            let headers = document.rows.first?.values ?? []
            throw ImportProcessingError.unsupportedFormat(headers: headers)
        }

        guard let table = document.table(headerRowIndex: detectedFormat.headerRowIndex) else {
            throw ImportProcessingError.missingHeaders
        }
        var transactions: [Transaction] = []
        var accountStatements: [AccountStatement] = []
        var skippedRows: [SkippedImportRow] = []

        for row in table.dataRows {
            let rowResult = detectedFormat.format.rowResult(table, row)

            transactions.append(contentsOf: rowResult.transactions)
            accountStatements.append(contentsOf: rowResult.accountStatements)

            if let reason = rowResult.skippedRowReason {
                skippedRows.append(SkippedImportRow(rowNumber: row.rowNumber, reason: reason))
            }

            if rowResult.shouldStopProcessing {
                break
            }
        }

        guard !transactions.isEmpty || !accountStatements.isEmpty else {
            throw ImportProcessingError.noImportableContent(
                detectedSource: detectedFormat.format.source,
                skippedRows: skippedRows
            )
        }

        return ImportResult(
            detectedSource: detectedFormat.format.source,
            transactions: transactions,
            accountStatements: accountStatements,
            skippedRows: skippedRows
        )
    }
}

public struct ImportResult {
    public let detectedSource: ImportSource?
    public let transactions: [Transaction]
    public let accountStatements: [AccountStatement]
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

enum ImportRowResult {
    case parsed(transactions: [Transaction], accountStatements: [AccountStatement])
    case skip(ImportSkipReason)
    case stop

    var transactions: [Transaction] {
        switch self {
        case .parsed(let transactions, _):
            return transactions
        case .skip, .stop:
            return []
        }
    }

    var accountStatements: [AccountStatement] {
        switch self {
        case .parsed(_, let accountStatements):
            return accountStatements
        case .skip, .stop:
            return []
        }
    }

    var skippedRowReason: ImportSkipReason? {
        switch self {
        case .skip(let reason):
            return reason
        case .parsed, .stop:
            return nil
        }
    }

    var shouldStopProcessing: Bool {
        switch self {
        case .stop:
            return true
        case .parsed, .skip:
            return false
        }
    }
}

enum AmountSignConvention {
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

struct ImportedTransactionCandidate {
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
        let originalCandidate = self
        var candidate = self

        for rule in rules where rule.matches(originalCandidate) {
            candidate.title = rule.newTitle ?? candidate.title
            candidate.kind = rule.kind ?? candidate.kind
        }

        return candidate
    }
}

struct ImportRule {
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

extension ImportRule.KindScope {
    func matches(_ kind: TransactionKind) -> Bool {
        switch (self, kind) {
        case (.any, _), (.expense, .expense), (.income, .income):
            return true
        case (.expense, _), (.income, _):
            return false
        }
    }
}

enum ImportRules {
    static let global: [ImportRule] = [
        ImportRule(match: "Uber", matchType: .contains, newTitle: "Uber", kind: .expense(.transit), appliesTo: .expense),
        ImportRule(match: "Uber Eats", matchType: .contains, newTitle: "Uber Eats", kind: .expense(.eatingOut), appliesTo: .expense),
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

enum BankImportRules {
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
        ImportRule(match: "COSTCO GAS", matchType: .contains, newTitle: nil, kind: .expense(.car), appliesTo: .expense),
        ImportRule(match: "WEST SAN JOSE GROCER SAN JOSE CA", matchType: .exact, newTitle: "Grocery Outlet", kind: .expense(.groceries), appliesTo: .expense)
    ]
}

enum DateImportParser {
    static func date(from string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

extension TransactionKind {
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

extension Array where Element == String {
    func containsAll(_ values: [String]) -> Bool {
        values.allSatisfy { value in
            contains { $0.caseInsensitiveCompare(value) == .orderedSame }
        }
    }
}
