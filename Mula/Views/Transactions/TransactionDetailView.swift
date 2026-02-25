//
//  TransactionDetailView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/26/25.
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(DataManager.self) private var dataManager
    let transaction: Transaction
    let displayingAccountId: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Transaction Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(transaction.category.baseColor)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: transaction.category.iconName)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.title)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Text(transaction.date, format: .dateTime.month().day().year())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                // Transaction Details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Type", value: transaction.kind.displayName)

                    DetailRow(label: "Amount", value: "\(transaction.amountSigned(displayingAccountId: displayingAccountId))")

                    DetailRow(label: "Category", value: transaction.category.displayName)

                    if case .transfer(_, let destinationAccountId) = transaction.kind {
                        DetailRow(label: "From", value: accountName(for: transaction.sourceAccountId))

                        DetailRow(label: "To", value: accountName(for: destinationAccountId))
                    } else {
                        DetailRow(label: "Account", value: accountName(for: transaction.sourceAccountId))
                    }

                    if let importBatch = dataManager.importBatches.first(where: { $0.id == transaction.importBatchId }) {
                        DetailRow(
                            label: "Import",
                            value: importBatch.name ?? "Untitled Import"
                        )
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 350, idealWidth: 400)
    }

    private func accountName(for accountId: UUID?) -> String {
        guard let accountId = accountId,
              let account = dataManager.accounts.first(where: { $0.id == accountId }) else {
            return "Unknown"
        }
        return account.name
    }
}
