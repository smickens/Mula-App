//
//  TransactionView.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import SwiftUI
import MulaCore

struct TransactionViewConfiguration: Hashable {
    var amountDisplayMode: TransactionAmountDisplayMode
    var amountDetailMode: TransactionAmountDetailMode

    static let standard = TransactionViewConfiguration(
        amountDisplayMode: .standard(displayingAccountId: nil),
        amountDetailMode: .automatic
    )

    static func standard(displayingAccountId: UUID?) -> TransactionViewConfiguration {
        TransactionViewConfiguration(
            amountDisplayMode: .standard(displayingAccountId: displayingAccountId),
            amountDetailMode: .automatic
        )
    }

    static let mySpending = TransactionViewConfiguration(
        amountDisplayMode: .mySpending,
        amountDetailMode: .automatic
    )

    static let allSpending = TransactionViewConfiguration(
        amountDisplayMode: .allSpending,
        amountDetailMode: .automatic
    )

    func hidingAmountDetails() -> TransactionViewConfiguration {
        var copy = self
        copy.amountDetailMode = .hidden
        return copy
    }
}

enum TransactionAmountDisplayMode: Hashable {
    case standard(displayingAccountId: UUID?)
    case mySpending
    case allSpending
}

enum TransactionAmountDetailMode: Hashable {
    case automatic
    case hidden
}

struct TransactionView: View {
    @Environment(DataManager.self) private var dataManager

    @Binding var selectedTransactionID: UUID?
    @State private var showingEditTransactionForm = false

    let swipeActionsEnabled: Bool
    let transaction: Transaction
    let configuration: TransactionViewConfiguration

    init(
        selectedTransactionID: Binding<UUID?>,
        swipeActionsEnabled: Bool,
        transaction: Transaction,
        configuration: TransactionViewConfiguration = .standard
    ) {
        self._selectedTransactionID = selectedTransactionID
        self.swipeActionsEnabled = swipeActionsEnabled
        self.transaction = transaction
        self.configuration = configuration
    }

    var body: some View {
        HStack {
            // Category Icon
            ZStack {
                Circle()
                    .fill(transaction.category.baseColor)
                    .frame(width: 35, height: 35)

                Image(systemName: transaction.category.iconName)
                    .foregroundColor(.white)
            }

            // Title + Date
            VStack(alignment: .leading) {
                Text(transaction.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(formatDate(transaction.date))

                    if transaction.hasCustomMyShare {
                        Label("My Share", systemImage: "person.2.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
                .font(.caption)

                if let amountDetailText {
                    Text(amountDetailText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Amount display
            Text(amountSigned, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundStyle(amountColor)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(amountColor.opacity(0.2))
                )
        }
        .padding(5)
        .contentShape(Rectangle())
        .gesture(tapGesture)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button {
                    selectedTransactionID = transaction.id
                    showingEditTransactionForm.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.yellow)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if swipeActionsEnabled {
                Button(role: .destructive) {
                    deleteTransaction()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
        .sheet(isPresented: $showingEditTransactionForm) {
            EditTransactionFormView(transaction: transaction)
        }
    }

    private var amountSigned: Decimal {
        switch configuration.amountDisplayMode {
        case .standard(let displayingAccountId):
            return transaction.amountSigned(displayingAccountId: displayingAccountId)
        case .mySpending:
            return -transaction.mySpendingAmount
        case .allSpending:
            return transaction.amountSigned(displayingAccountId: nil)
        }
    }

    private var amountColor: Color {
        switch configuration.amountDisplayMode {
        case .standard(let displayingAccountId):
            return transaction.amountColor(displayingAccountId: displayingAccountId)
        case .mySpending:
            return transaction.mySpendingAmount == 0 ? .secondary : .red
        case .allSpending:
            return transaction.amountColor(displayingAccountId: nil)
        }
    }

    private var amountDetailText: String? {
        guard configuration.amountDetailMode == .automatic,
              transaction.hasCustomMyShare,
              let myShareAmount = transaction.myShareAmount else {
            return nil
        }

        switch configuration.amountDisplayMode {
        case .standard:
            return nil
        case .mySpending:
            return "Full amount: \(transaction.amount.toCurrency())"
        case .allSpending:
            return "My Share: \(myShareAmount.toCurrency())"
        }
    }

    // MARK: - Gestures

    private var tapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                selectedTransactionID = transaction.id
            }
            .simultaneously(with: TapGesture(count: 2)
                .onEnded {
                    if swipeActionsEnabled {
                        showingEditTransactionForm.toggle()
                    }
                }
            )
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
    }

    private func deleteTransaction() {
        print("Deleting transaction: \(transaction.id) \(transaction.displayTitle)")
        dataManager.deleteTransaction(transaction)
    }
}
