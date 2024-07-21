//
//  Bucket.swift
//  Mula
//
//  Created by Shanti Mickens on 7/8/24.
//

import SwiftUI

enum Bucket: String, CaseIterable, Identifiable, Codable, Hashable {
    case fixed = "Fixed"
    case spending = "Spending"
    case saving = "Savings"
    case investment = "Investments"
    case income = "Income"

    var id: String { rawValue }

    var name: String { rawValue }

    var icon: String {
        switch self {
        case .fixed: return "grid"
        case .spending: return "tag.fill"
        case .saving: return "bolt.fill"
        case .investment: return "hourglass"
        case .income: return "hourglass"
        }
    }

    var tint: Color {
        switch self {
        case .fixed: return .cyan
        case .spending: return .pink
        case .saving: return .green
        case .investment: return .indigo
        case .income: return .blue
        }
    }
}
