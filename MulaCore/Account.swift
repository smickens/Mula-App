//
//  Account.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import Foundation

public struct Account: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var type: AccountType

    // TODO: default should read from DataManager instead ?
    public static let `default`: UUID = UUID(uuidString: "781259EA-A78D-431A-B697-3EC87A9183D2")!

    public init(id: UUID = UUID(), name: String, type: AccountType) {
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

public enum AccountType: String, CaseIterable, Codable, Identifiable {
    public var id: String { rawValue }

    case certificateOfDeposit
    case checking
    case creditCard
    case investment
    case retirement
    case saving

    public static func get(from string: String) -> AccountType? {
        return AccountType(rawValue: string)
    }

    public var displayName: String {
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
