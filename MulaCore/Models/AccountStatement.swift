//
//  AccountStatement.swift
//  MulaCore
//
//  Created by OpenAI on 6/7/26.
//

import Foundation

public struct AccountStatement: Identifiable, Codable, Hashable {
    public let id: UUID
    public let accountId: UUID
    public let date: Date
    public let balance: Decimal
    public let importBatchId: UUID?

    public init(
        id: UUID = UUID(),
        accountId: UUID,
        date: Date,
        balance: Decimal,
        importBatchId: UUID? = nil
    ) {
        self.id = id
        self.accountId = accountId
        self.date = date
        self.balance = balance
        self.importBatchId = importBatchId
    }

    public func withImportBatchId(_ importBatchId: UUID) -> AccountStatement {
        AccountStatement(
            id: id,
            accountId: accountId,
            date: date,
            balance: balance,
            importBatchId: importBatchId
        )
    }
}
