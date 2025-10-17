//
//  Account.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import Foundation

// etrade?
// apple_savings, usbank_cd1, usbank_cd2, usbank_cd3
// credit_card ?, usbank_checking
// OR AccountType ?

struct Account: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: AccountType

    init(id: UUID = UUID(), name: String, type: AccountType) {
        self.id = id
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
    }
}

enum AccountType: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }

    case certificateOfDeposit
    case checking
    case creditCard
    case investment
    case retirement
    case saving

    static func get(from string: String) -> AccountType? {
        return AccountType(rawValue: string)
    }

    var displayName: String {
        switch self {
        case .certificateOfDeposit: return "Certificate of Deposit"
        case .checking: return "Checking"
        case .creditCard: return "Credit Card"
        case .investment: return "Investment"
        case .retirement: return "Retirement"
        case .saving: return "Saving"
        }
    }
}
