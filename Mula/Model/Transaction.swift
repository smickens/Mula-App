//
//  Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 10/20/25.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID

    var accountId: UUID?
    var importBatchId: UUID?

    var title: String
    var date: Date
    var amount: Double

    var category: TransactionCategory

    var firebaseKey: String {
        id.uuidString
    }
}

enum TransactionCategory: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }

    case housing          // rent, utilities, internet, etc.
    case eatingOut
    case groceries
    case shopping
    case car              // gas, maintenance, servicing, tires, etc.
    case transit          // flights, bus, caltrain, ubers
    case entertainment
    case income
    case transfer
    case refund
    case dividend
    case interest
    case investment
    case creditCardPayment
    case other

    static func get(from string: String) -> TransactionCategory? {
        TransactionCategory(rawValue: string)
    }

    var displayName: String {
        switch self {
        case .housing: return "Housing"
        case .eatingOut: return "Eating Out"
        case .groceries: return "Groceries"
        case .shopping: return "Shopping"
        case .car: return "Car"
        case .transit: return "Transit"
        case .entertainment: return "Entertainment"
        case .income: return "Income"
        case .transfer: return "Transfer"
        case .refund: return "Refund"
        case .dividend: return "Dividend"
        case .interest: return "Interest"
        case .investment: return "Investment"
        case .creditCardPayment: return "Credit Card Payment"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .housing: return "house.fill"
        case .eatingOut: return "fork.knife"
        case .groceries: return "flame"
        case .shopping: return "bag.fill"
        case .car: return "car.fill"
        case .transit: return "tram.fill"
        case .entertainment: return "smiley.fill"
        case .income: return "briefcase.fill"
        case .transfer: return "arrow.left.arrow.right"
        case .refund: return "arrow.uturn.backward.circle.fill"
        case .dividend: return "chart.bar.fill"
        case .interest: return "percent"
        case .other: return "ellipsis.circle.fill"
        case .investment: return "dollarsign.bank.building.fill"
        case .creditCardPayment: return "creditcard.fill"
        }
    }

    private var tint: Color {
        switch self {
        case .housing: return .blue
        case .eatingOut: return .orange
        case .groceries: return .green
        case .shopping: return .pink
        case .car: return .red
        case .transit: return .purple
        case .entertainment: return .teal
        case .income: return .green
        case .transfer: return .gray
        case .refund: return .mint
        case .dividend: return .indigo
        case .interest: return .cyan
        case .investment: return .indigo
        case .creditCardPayment: return .teal
        case .other: return .brown
        }
    }

    var tintColor: Color {
        return tint.opacity(0.7)
    }
}
