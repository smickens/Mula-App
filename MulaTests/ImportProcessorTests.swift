//
//  ImportProcessorTests.swift
//  MulaTests
//
//  Created by Shanti Mickens on 6/4/26.
//

@testable import MulaCore
import Foundation
import Testing

struct ImportProcessorTests {

    @Test func processFileContentParsesAppleCardTransactions() throws {
        let content = """
        Transaction Date,Clearing Date,Merchant,Category,Type,Amount (USD)
        03/02/2026,03/02/2026,Blue Bottle Coffee,Restaurants,Purchase,12.34
        03/03/2026,03/03/2026,Target return,Shopping,Purchase,-8.50
        """

        let result = try ImportProcessor.processFileContent(content)

        #expect(result.detectedBank == .apple)
        #expect(result.transactions.count == 2)
        #expect(result.skippedRows.isEmpty)

        let coffee = result.transactions[0]
        #expect(coffee.title == "Blue Bottle Coffee")
        #expect(formattedDate(coffee.date) == "2026-03-02")
        #expect(coffee.kind == .expense(.eatingOut))
        #expect(coffee.amount == Decimal(string: "12.34"))
        #expect(coffee.sourceAccountId == Bank.apple.accountId)

        let refund = result.transactions[1]
        #expect(refund.title == "Target return")
        #expect(formattedDate(refund.date) == "2026-03-03")
        #expect(refund.kind == .income(.refund))
        #expect(refund.amount == Decimal(string: "8.50"))
        #expect(refund.sourceAccountId == Bank.apple.accountId)
    }

    @Test func processFileContentParsesUSBankTransactions() throws {
        let content = """
        Date,Transaction,Name,Memo,Amount
        2026-03-04,POS,LYFT *RIDE,,-17.89
        2026-03-05,DEP,ELECTRONIC DEPOSIT VENMO,,25.00
        """

        let result = try ImportProcessor.processFileContent(content)

        #expect(result.detectedBank == .usBank)
        #expect(result.transactions.count == 2)
        #expect(result.skippedRows.isEmpty)

        let ride = result.transactions[0]
        #expect(ride.title == "Lyft")
        #expect(formattedDate(ride.date) == "2026-03-04")
        #expect(ride.kind == .expense(.transit))
        #expect(ride.amount == Decimal(string: "17.89"))
        #expect(ride.sourceAccountId == Bank.usBank.accountId)

        let deposit = result.transactions[1]
        #expect(deposit.title == "Venmo (in)")
        #expect(formattedDate(deposit.date) == "2026-03-05")
        #expect(deposit.kind == .income(.other))
        #expect(deposit.amount == Decimal(string: "25.00"))
        #expect(deposit.sourceAccountId == Bank.usBank.accountId)
    }

    @Test func processFileContentParsesFidelity401kTransactions() throws {
        let content = """
        Run Date,Action,Description,Amount ($)
        03/06/2026,Contributions,Employer Match,120.50
        03/07/2026,Contributions,,80.00
        """

        let result = try ImportProcessor.processFileContent(content)

        #expect(result.detectedBank == .fidelity401k)
        #expect(result.transactions.count == 2)
        #expect(result.skippedRows.isEmpty)

        let employerMatch = result.transactions[0]
        #expect(employerMatch.title == "Contributions - Employer Match")
        #expect(formattedDate(employerMatch.date) == "2026-03-06")
        #expect(employerMatch.kind == .saving(.contribution))
        #expect(employerMatch.amount == Decimal(string: "120.50"))
        #expect(employerMatch.sourceAccountId == Bank.fidelity401k.accountId)

        let noDescription = result.transactions[1]
        #expect(noDescription.title == "Contributions - (No Desc)")
        #expect(formattedDate(noDescription.date) == "2026-03-07")
        #expect(noDescription.kind == .saving(.contribution))
        #expect(noDescription.amount == Decimal(string: "80.00"))
        #expect(noDescription.sourceAccountId == Bank.fidelity401k.accountId)
    }

    @Test func processFileContentParsesWellsFargoTransactions() throws {
        let content = """
        DATE,DESCRIPTION,AMOUNT
        03/08/2026,TST*BAE - CAMPBELL CAMPBELL CA,-19.75
        03/09/2026,ONLINE ACH PAYMENT THANK YOU,250.00
        03/10/2026,WEST SAN JOSE GROCER SAN JOSE CA,-43.21
        """

        let result = try ImportProcessor.processFileContent(content)

        #expect(result.detectedBank == .wellsFargo)
        #expect(result.transactions.count == 2)
        #expect(result.skippedRows.count == 1)
        #expect(result.skippedRows[0].rowNumber == 3)
        #expect(result.skippedRows[0].reason == .ignoredTransaction("Credit card payment"))

        let empanadas = result.transactions[0]
        #expect(empanadas.title == "Best Artisan Empanadas")
        #expect(formattedDate(empanadas.date) == "2026-03-08")
        #expect(empanadas.kind == .expense(.eatingOut))
        #expect(empanadas.amount == Decimal(string: "19.75"))
        #expect(empanadas.sourceAccountId == Bank.wellsFargo.accountId)

        let groceries = result.transactions[1]
        #expect(groceries.title == "Grocery Outlet")
        #expect(formattedDate(groceries.date) == "2026-03-10")
        #expect(groceries.kind == .expense(.groceries))
        #expect(groceries.amount == Decimal(string: "43.21"))
        #expect(groceries.sourceAccountId == Bank.wellsFargo.accountId)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
