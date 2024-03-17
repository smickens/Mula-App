//
//  ExpenseRepository.swift
//  Mula
//
//  Created by Shanti Mickens on 2/2/24.
//

import CoreData

class ExpenseRepository {
    static let shared = ExpenseRepository()

    private let context = CoreDataStack.shared.context

    func fetchExpenses() -> [Expense] {
        let fetchRequest: NSFetchRequest<Expense> = Expense.createFetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching expenses: \(error.localizedDescription)")
            return []
        }
    }

    func saveContext() {
        CoreDataStack.shared.saveContext()
    }

    func createExpense(id: UUID, title: String, date: Date, amount: Double, category: Category) -> Expense {
        let newExpense = Expense(context: context)
        newExpense.id = id
        newExpense.title = title
        newExpense.date = date
        newExpense.amount = amount
        newExpense.category = category

        return newExpense
    }

    func saveNewExpense(id: UUID, title: String, date: Date, amount: Double, category: Category) {
        let _ = createExpense(id: id, title: title, date: date, amount: amount, category: category)
        saveContext()
    }

    func updateExpense(id: UUID, newTitle: String, newDate: Date, newAmount: Double, newCategory: Category) {
        // Fetch the existing expense with the given ID
        let fetchRequest: NSFetchRequest<Expense> = Expense.createFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let existingExpense = try context.fetch(fetchRequest).first {
                // Update the properties of the existing expense
                existingExpense.title = newTitle
                existingExpense.date = newDate
                existingExpense.amount = newAmount
                existingExpense.category = newCategory

                // Save the changes to the managed object context
                try context.save()
            } else {
                print("Expense with ID \(id) not found")
            }
        } catch {
            print("Error updating expense: \(error.localizedDescription)")
        }
    }

    func deleteExpense(expense: Expense) {
        context.delete(expense)

//        let context = CoreDataStack.shared.context
//
//        do {
//            context.delete(expense)
//            try context.save()
//        } catch {
//            print("Error deleting an expense w/ title \(expense.title ?? "Default Title"): \(error.localizedDescription)")
//        }
    }

//    func resetAllRecords() {
//        let context = CoreDataStack.shared.context
//        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//
//        do {
//            try context.execute(deleteRequest)
//            try context.save()
//        } catch {
//            print("Error resetting all records: \(error.localizedDescription)")
//        }
//    }


}
