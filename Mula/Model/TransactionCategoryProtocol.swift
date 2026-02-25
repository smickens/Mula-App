//
//  Category.swift
//  Mula
//
//  Created by Shanti Mickens on 2/10/26.
//

import SwiftUI

// since protocol cannot conform to things, is there any point in writing these other ones by it ?
protocol TransactionCategoryProtocol: CaseIterable, Identifiable, Codable, Hashable {
    var id: String { get }
    var displayName: String { get }
    var iconName: String { get }
    var baseColor: Color { get }
}

enum ExpenseCategory: String, CaseIterable, TransactionCategoryProtocol {
    case housing, eatingOut, groceries, shopping, car, transit, entertainment, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .housing: return "Housing"
        case .eatingOut: return "Eating Out"
        case .groceries: return "Groceries"
        case .shopping: return "Shopping"
        case .car: return "Car"
        case .transit: return "Transit"
        case .entertainment: return "Entertainment"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .housing: return "house.fill"
        case .eatingOut: return "fork.knife"
        case .groceries: return "cart.fill"
        case .shopping: return "bag.fill"
        case .car: return "car.fill"
        case .transit: return "tram.fill"
        case .entertainment: return "smiley.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var baseColor: Color {
        switch self {
        case .housing: return .blue
        case .eatingOut: return .orange
        case .groceries: return .green
        case .shopping: return .pink
        case .car: return .red
        case .transit: return .purple
        case .entertainment: return .teal
        case .other: return .brown
        }
    }
}

enum IncomeCategory: String, CaseIterable, TransactionCategoryProtocol {
    case job, refund, dividend, interest, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .job: return "Job"
        case .refund: return "Refund"
        case .dividend: return "Dividend"
        case .interest: return "Interest"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .job: return "briefcase.fill"
        case .refund: return "arrow.uturn.backward.circle.fill"
        case .dividend: return "chart.bar.fill"
        case .interest: return "percent"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var baseColor: Color {
        switch self {
        case .job: return .green
        case .refund: return .mint
        case .dividend: return .indigo
        case .interest: return .cyan
        case .other: return .gray
        }
    }
}

enum TransferCategory: String, CaseIterable, TransactionCategoryProtocol {
    case savings
    case investment
    case retirement
    case creditCardPayment
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .savings: return "Savings"
        case .investment: return "Investment"
        case .retirement: return "Retirement"
        case .creditCardPayment: return "Credit Card Payment"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .savings: return "banknote"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .retirement: return "calendar"
        case .creditCardPayment: return "creditcard"
        case .other: return "questionmark.circle"
        }
    }

    var baseColor: Color {
        switch self {
        case .savings: return .blue
        case .investment: return .purple
        case .retirement: return .orange
        case .creditCardPayment: return .gray
        case .other: return .secondary
        }
    }
}
