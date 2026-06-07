//
//  ImportProcessorTests.swift
//  MulaTests
//
//  Created by Shanti Mickens on 6/4/26.
//

@testable import MulaCore
import Foundation
import Testing

enum ImportProcessorTests {

    @Suite("Apple Card")
    struct AppleCard {

        @Test func parsesTransactions() throws {
            let content = csvContent(
                headers: ["Transaction Date", "Clearing Date", "Merchant", "Category", "Type", "Amount (USD)"],
                rows: [
                    ["03/02/2026", "03/02/2026", "Blue Bottle Coffee", "Restaurants", "Purchase", "12.34"],
                    ["03/03/2026", "03/03/2026", "Target return", "Shopping", "Purchase", "-8.50"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .apple)
            #expect(result.transactions.count == 2)
            #expect(result.skippedRows.isEmpty)

            let coffee = result.transactions[0]
            #expect(coffee.title == "Blue Bottle Coffee")
            #expect(formattedDate(coffee.date) == "2026-03-02")
            #expect(coffee.kind == .expense(.eatingOut))
            #expect(coffee.amount == decimal("12.34"))
            #expect(coffee.sourceAccountId == Bank.apple.accountId)

            let refund = result.transactions[1]
            #expect(refund.title == "Target return")
            #expect(formattedDate(refund.date) == "2026-03-03")
            #expect(refund.kind == .income(.refund))
            #expect(refund.amount == decimal("8.50"))
            #expect(refund.sourceAccountId == Bank.apple.accountId)
        }

        @Test func skipsRowsWithMissingMerchant() throws {
            let content = csvContent(
                headers: ["Transaction Date", "Clearing Date", "Merchant", "Category", "Type", "Amount (USD)"],
                rows: [
                    ["03/02/2026", "03/02/2026", "", "Restaurants", "Purchase", "12.34"],
                    ["03/03/2026", "03/03/2026", "Blue Bottle Coffee", "Restaurants", "Purchase", "4.50"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .apple)
            #expect(result.transactions.count == 1)
            #expect(result.skippedRows.count == 1)
            #expect(result.skippedRows[0].rowNumber == 2)
            #expect(result.skippedRows[0].reason == .missingRequiredValue("Merchant"))
            #expect(result.transactions[0].title == "Blue Bottle Coffee")
        }
    }

    @Suite("US Bank")
    struct USBank {

        @Test func parsesTransactions() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [
                    ["2026-03-04", "POS", "LYFT *RIDE", "", "-17.89"],
                    ["2026-03-05", "DEP", "ELECTRONIC DEPOSIT VENMO", "", "25.00"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .usBank)
            #expect(result.transactions.count == 2)
            #expect(result.skippedRows.isEmpty)

            let ride = result.transactions[0]
            #expect(ride.title == "Lyft")
            #expect(formattedDate(ride.date) == "2026-03-04")
            #expect(ride.kind == .expense(.transit))
            #expect(ride.amount == decimal("17.89"))
            #expect(ride.sourceAccountId == Bank.usBank.accountId)

            let deposit = result.transactions[1]
            #expect(deposit.title == "Venmo (in)")
            #expect(formattedDate(deposit.date) == "2026-03-05")
            #expect(deposit.kind == .income(.other))
            #expect(deposit.amount == decimal("25.00"))
            #expect(deposit.sourceAccountId == Bank.usBank.accountId)
        }

        @Test func skipsRowsWithInvalidDate() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [
                    ["not-a-date", "POS", "LYFT *RIDE", "", "-17.89"],
                    ["2026-03-05", "DEP", "ELECTRONIC DEPOSIT VENMO", "", "25.00"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .usBank)
            #expect(result.transactions.count == 1)
            #expect(result.skippedRows.count == 1)
            #expect(result.skippedRows[0].rowNumber == 2)
            #expect(result.skippedRows[0].reason == .invalidDate("not-a-date"))
            #expect(result.transactions[0].title == "Venmo (in)")
        }
    }

    @Suite("Fidelity 401k")
    struct Fidelity401k {

        @Test func parsesTransactions() throws {
            let content = csvContent(
                headers: ["Run Date", "Action", "Description", "Amount ($)"],
                rows: [
                    ["03/06/2026", "Contributions", "Employer Match", "120.50"],
                    ["03/07/2026", "Contributions", "", "80.00"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .fidelity401k)
            #expect(result.transactions.count == 2)
            #expect(result.skippedRows.isEmpty)

            let employerMatch = result.transactions[0]
            #expect(employerMatch.title == "Contributions - Employer Match")
            #expect(formattedDate(employerMatch.date) == "2026-03-06")
            #expect(employerMatch.kind == .saving(.contribution))
            #expect(employerMatch.amount == decimal("120.50"))
            #expect(employerMatch.sourceAccountId == Bank.fidelity401k.accountId)

            let noDescription = result.transactions[1]
            #expect(noDescription.title == "Contributions - (No Desc)")
            #expect(formattedDate(noDescription.date) == "2026-03-07")
            #expect(noDescription.kind == .saving(.contribution))
            #expect(noDescription.amount == decimal("80.00"))
            #expect(noDescription.sourceAccountId == Bank.fidelity401k.accountId)
        }
    }

    @Suite("Wells Fargo")
    struct WellsFargo {

        @Test func parsesTransactions() throws {
            let content = csvContent(
                headers: ["DATE", "DESCRIPTION", "AMOUNT"],
                rows: [
                    ["03/08/2026", "TST*BAE - CAMPBELL CAMPBELL CA", "-19.75"],
                    ["03/09/2026", "ONLINE ACH PAYMENT THANK YOU", "250.00"],
                    ["03/10/2026", "WEST SAN JOSE GROCER SAN JOSE CA", "-43.21"]
                ]
            )

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
            #expect(empanadas.amount == decimal("19.75"))
            #expect(empanadas.sourceAccountId == Bank.wellsFargo.accountId)

            let groceries = result.transactions[1]
            #expect(groceries.title == "Grocery Outlet")
            #expect(formattedDate(groceries.date) == "2026-03-10")
            #expect(groceries.kind == .expense(.groceries))
            #expect(groceries.amount == decimal("43.21"))
            #expect(groceries.sourceAccountId == Bank.wellsFargo.accountId)
        }

        @Test func skipsRowsWithInvalidAmount() throws {
            let content = csvContent(
                headers: ["DATE", "DESCRIPTION", "AMOUNT"],
                rows: [
                    ["03/08/2026", "TST*BAE - CAMPBELL CAMPBELL CA", "not-a-number"],
                    ["03/10/2026", "WEST SAN JOSE GROCER SAN JOSE CA", "-43.21"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.detectedBank == .wellsFargo)
            #expect(result.transactions.count == 1)
            #expect(result.skippedRows.count == 1)
            #expect(result.skippedRows[0].rowNumber == 2)
            #expect(result.skippedRows[0].reason == .invalidAmount("not-a-number"))
            #expect(result.transactions[0].title == "Grocery Outlet")
        }
    }

    @Suite("Errors And Skips")
    struct Errors {

        @Test func throwsMissingHeadersForEmptyContent() {
            expectImportProcessingError(for: try ImportProcessor.processFileContent("")) { error in
                guard case .missingHeaders = error else {
                    return false
                }

                return true
            }
        }

        @Test func throwsUnsupportedFormatForUnknownHeaders() {
            let content = csvContent(
                headers: ["Posted On", "Vendor", "Total"],
                rows: [["2026-03-02", "Coffee", "12.34"]]
            )

            expectImportProcessingError(for: try ImportProcessor.processFileContent(content)) { error in
                guard case .unsupportedFormat(let headers) = error else {
                    return false
                }

                return headers == ["Posted On", "Vendor", "Total"]
            }
        }

        @Test func throwsWhenAllRowsAreSkipped() {
            let content = csvContent(
                headers: ["Run Date", "Action", "Description", "Amount ($)"],
                rows: [
                    ["03/06/2026", "Dividend", "Quarterly Dividend", "120.50"],
                    ["03/07/2026", "Transfer", "Balance Move", "80.00"]
                ]
            )

            expectImportProcessingError(for: try ImportProcessor.processFileContent(content)) { error in
                guard case .noImportableTransactions(let detectedBank, let skippedRows) = error else {
                    return false
                }

                return detectedBank == .fidelity401k
                    && skippedRows.count == 2
                    && skippedRows[0].rowNumber == 2
                    && skippedRows[0].reason == .ignoredTransaction("Dividend")
                    && skippedRows[1].rowNumber == 3
                    && skippedRows[1].reason == .ignoredTransaction("Transfer")
            }
        }
    }

    @Suite("Normalization And Rules")
    struct Rules {

        @Test func normalizesUberEatsBeforeGenericUber() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [["2026-03-11", "POS", "UBER EATS SAN JOSE CA", "", "-22.40"]]
            )

            let result = try ImportProcessor.processFileContent(content)
            let transaction = try #require(result.transactions.first)

            #expect(transaction.title == "Uber Eats")
            #expect(transaction.kind == .expense(.eatingOut))
            #expect(transaction.amount == decimal("22.40"))
        }

        @Test func normalizesUberToTransit() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [["2026-03-11", "POS", "UBER TRIP HELP.UBER.COM", "", "-18.25"]]
            )

            let result = try ImportProcessor.processFileContent(content)
            let transaction = try #require(result.transactions.first)

            #expect(transaction.title == "Uber")
            #expect(transaction.kind == .expense(.transit))
        }

        @Test func normalizesTargetExpenseToGroceries() throws {
            let content = csvContent(
                headers: ["Transaction Date", "Clearing Date", "Merchant", "Category", "Type", "Amount (USD)"],
                rows: [["03/12/2026", "03/12/2026", "Target T-1234", "Shopping", "Purchase", "31.16"]]
            )

            let result = try ImportProcessor.processFileContent(content)
            let transaction = try #require(result.transactions.first)

            #expect(transaction.title == "Target")
            #expect(transaction.kind == .expense(.groceries))
        }

        @Test func keepsReturnAsRefundIncome() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [["2026-03-13", "DEP", "TARGET RETURN", "", "14.99"]]
            )

            let result = try ImportProcessor.processFileContent(content)
            let transaction = try #require(result.transactions.first)

            #expect(transaction.title == "TARGET RETURN")
            #expect(transaction.kind == .income(.refund))
            #expect(transaction.amount == decimal("14.99"))
        }

        @Test func rewritesUsBankVenmoOutAndIn() throws {
            let content = csvContent(
                headers: ["Date", "Transaction", "Name", "Memo", "Amount"],
                rows: [
                    ["2026-03-14", "POS", "WEB AUTHORIZED PMT VENMO", "", "-45.00"],
                    ["2026-03-15", "DEP", "ELECTRONIC DEPOSIT VENMO", "", "18.75"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.transactions.count == 2)
            #expect(result.transactions[0].title == "Venmo (out)")
            #expect(result.transactions[0].kind == .expense(.entertainment))
            #expect(result.transactions[1].title == "Venmo (in)")
            #expect(result.transactions[1].kind == .income(.other))
        }

        @Test func rewritesWellsFargoSpecificMerchants() throws {
            let content = csvContent(
                headers: ["DATE", "DESCRIPTION", "AMOUNT"],
                rows: [
                    ["03/16/2026", "BPS*BILT RENT NEW YORK NY", "-2100.00"],
                    ["03/17/2026", "APPLE CAFFE AP01:1 CUPERTINO CA", "-8.25"],
                    ["03/18/2026", "CVS/PHARMACY #09856 SUNNYVALE CA", "-12.10"]
                ]
            )

            let result = try ImportProcessor.processFileContent(content)

            #expect(result.transactions.count == 3)

            let rent = result.transactions[0]
            #expect(rent.title == "Rent")
            #expect(rent.kind == .expense(.housing))

            let cafe = result.transactions[1]
            #expect(cafe.title == "Apple Caffe")
            #expect(cafe.kind == .expense(.eatingOut))

            let cvs = result.transactions[2]
            #expect(cvs.title == "CVS")
            #expect(cvs.kind == .expense(.groceries))
        }
    }
}
