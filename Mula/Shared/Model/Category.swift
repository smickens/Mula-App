//
//  Category.swift
//  Mula
//
//  Created by Shanti Mickens on 1/31/24.
//

import Foundation
import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable {
    case housing = "Housing"
    case eatingOut = "Eating Out"
    case groceries = "Groceries"
    case shopping = "Shopping"
    case transportation = "Transportation" // gas, uber
    case entertainment = "Entertainment"
    case job = "Job"
    case retirement = "Retirement"
    case stocks = "Stocks"
    case misc = "Misc"

    var id: String { rawValue }

    var name: String { rawValue }

    var iconName: String {
        switch self {
        case .housing: return "house.fill"
        case .eatingOut: return "flame.fill"
        case .groceries: return "flame"
        case .shopping: return "bag.fill"
        case .transportation: return "car.fill"
        case .entertainment: return "smiley.fill"
        case .job: return "briefcase.fill"
        case .retirement: return "chart.line.uptrend.xyaxis"
        case .stocks: return "chart.bar.fill"
        case .misc: return "staroflife.fill"
        }
    }

    private var tint: Color {
        switch self {
        case .housing: return .blue
        case .eatingOut: return .green
        case .groceries: return .red
        case .shopping: return .pink
        case .transportation: return .orange
        case .entertainment: return .yellow
        case .job: return .teal
        case .retirement: return .mint
        case .stocks: return .indigo
        case .misc: return .purple
        }
    }

    var tintColor: Color {
        return tint.opacity(0.7)
    }

    static func get(from categoryString: String) -> Category {
        let lowercaseCategoryString = categoryString.lowercased()
        for category in Category.allCases {
            if lowercaseCategoryString == category.rawValue.lowercased()  {
                return category
            }
        }
        return .misc
    }
}
