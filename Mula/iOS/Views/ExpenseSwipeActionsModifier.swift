//
//  ExpenseSwipeActionsModifier.swift
//  Mula
//
//  Created by Shanti Mickens on 7/24/24.
//

import SwiftUI

struct ExpenseSwipeActionsModifier: ViewModifier {
    var onEdit: () -> Void
    var onDelete: () -> Void

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.yellow)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension View {
    func expenseSwipeActions(
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(ExpenseSwipeActionsModifier(onEdit: onEdit, onDelete: onDelete))
    }
}

