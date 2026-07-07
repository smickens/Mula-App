//
//  TestSupport.swift
//  MulaTests
//
//  Created by Shanti Mickens on 6/7/26.
//

@testable import MulaCore
import Foundation
import Testing

func csvContent(headers: [String], rows: [[String]]) -> String {
    ([headers] + rows)
        .map { $0.joined(separator: ",") }
        .joined(separator: "\n")
}

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func decimal(_ string: String) -> Decimal {
    Decimal(string: string)!
}

func expectImportProcessingError(
    for operation: @autoclosure () throws -> ImportResult,
    matching predicate: (ImportProcessingError) -> Bool
) {
    do {
        _ = try operation()
        Issue.record("Expected ImportProcessingError to be thrown.")
    } catch let error as ImportProcessingError {
        #expect(predicate(error))
    } catch {
        Issue.record("Expected ImportProcessingError, got \(error).")
    }
}
