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

    var icon: Image {
        switch self {
        case .housing: return Image(systemName: "house.fill")
        case .eatingOut: return Image(systemName: "flame.fill")
        case .groceries: return Image(systemName: "flame")
        case .shopping: return Image(systemName: "bag.fill")
        case .transportation: return Image(systemName: "car.fill")
        case .entertainment: return Image(systemName: "smiley.fill")
        case .misc: return Image(systemName: "staroflife.fill")
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
}
