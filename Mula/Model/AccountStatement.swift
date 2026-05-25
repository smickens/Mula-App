//
//  AccountStatement.swift
//  Mula
//
//  Created by Shanti Mickens on 5/18/24.
//

import Foundation

struct AccountStatement: Identifiable, Codable, Hashable {
    let id: UUID
    let accountId: UUID
    let date: Date
    let balance: Decimal

    init(
        id: UUID = UUID(),
        accountId: UUID,
        date: Date,
        balance: Decimal
    ) {
        self.id = id
        self.accountId = accountId
        self.date = date
        self.balance = balance
    }
}
