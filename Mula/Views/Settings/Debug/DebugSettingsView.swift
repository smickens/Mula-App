//
//  DebugSettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import SwiftUI

struct DebugSettingsView: View {
    @Environment(DataManager.self) private var dataManager
    @State private var isReloading = false
    @State private var reloadMessage: String?
    @State private var showingConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Debug Tools")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 10) {
                Button {
                    showingConfirmation = true
                } label: {
                    if isReloading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                    } else {
                        Text("Force Reload Data")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isReloading)

                if let message = reloadMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                }
            }

            Spacer()
        }
        .padding(30)
        .confirmationDialog(
            "Force Reload Data",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Force Reload", role: .destructive) {
                Task { await forceReload() }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reload all data from Firebase, including transactions and accounts. Use this if the local data is out of sync or corrupted.")
        }
    }

    private func forceReload() async {
        isReloading = true
        reloadMessage = nil

        do {
            await MainActor.run {
                dataManager.loadAccounts()
                dataManager.loadTransactions()
            }
            reloadMessage = "✅ Data reloaded successfully."
        } catch {
            reloadMessage = "❌ Failed to reload data: \(error.localizedDescription)"
        }

        isReloading = false
    }
}
