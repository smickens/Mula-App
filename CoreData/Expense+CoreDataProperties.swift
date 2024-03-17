//
//  Expense+CoreDataProperties.swift
//  Mula
//
//  Created by Shanti Mickens on 2/2/24.
//
//

import Foundation
import CoreData

extension Expense: Identifiable {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Double
    @NSManaged public var categoryValue: String?
}

extension Expense {
    var category: Category {
        get {
            if let categoryValue {
                return Category(rawValue: categoryValue) ?? .misc
            }
            return .misc
        }
        set {
            self.categoryValue = newValue.rawValue
        }
    }
}
