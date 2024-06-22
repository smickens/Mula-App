//
//  Budget.swift
//  Mula
//
//  Created by Shanti Mickens on 6/3/24.
//

import Foundation
import SwiftData

@Model
class Budget {
    @Attribute(.unique) let categoryTitle: String
    let category: Category
    var target: Double
    
    init(category: Category, target: Double) {
        self.categoryTitle = category.name
        self.category = category
        self.target = target
    }
}
