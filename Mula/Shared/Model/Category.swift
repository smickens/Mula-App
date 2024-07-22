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
        case .misc: return .purple
        }
    }

    var tintColor: Color {
        return tint.opacity(0.7)
    }

    static func get(from categoryString: String) -> Category {
        if categoryString == "transportation" {
            return .transportation
        } else if categoryString == "housing" {
            return .housing
        } else if categoryString == "groceries" {
            return .groceries
        } else if categoryString == "eating out" {
            return .eatingOut
        } else if categoryString == "shopping" {
            return .shopping
        } else if categoryString == "entertainment" {
            return .entertainment
        }
        return .misc
    }
}
