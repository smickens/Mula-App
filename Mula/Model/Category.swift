//
//  Category.swift
//  Mula
//
//  Created by Shanti Mickens on 1/31/24.
//

import Foundation
import SwiftUI

// TODO: category protocol ??

struct SubCategory: Identifiable {
    var id = UUID()
    var name: String
    var icon: Image
    var tintColor: Color
    var parentCategory: Category
}

enum Category: String, CaseIterable, Identifiable {
    case housing = "Housing"
    case food = "Food" // eating out, ordering, groceries
    case shopping = "Shopping"
    case transportation = "Transportation" // gas, uber
    case entertainment = "Entertainment"
    case misc = "Misc"

    var id: String { rawValue }

    var name: String { rawValue }

    var icon: Image {
        switch self {
        case .housing: return Image(systemName: "house.fill")
        case .food: return Image(systemName: "flame.fill")
        case .shopping: return Image(systemName: "bag.fill")
        case .misc: return Image(systemName: "staroflife.fill")
        case .transportation: return Image(systemName: "car.fill")
        case .entertainment: return Image(systemName: "smiley.fill")
        }
    }

    private var tint: Color {
        switch self {
        case .housing: return .blue
        case .food: return .green
        case .shopping: return .pink
        case .misc: return .purple
        case .transportation: return .orange
        case .entertainment: return .yellow
        }
    }

    var tintColor: Color {
        return tint.opacity(0.7)
    }
}
