//
//  DebugSettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import SwiftUI

struct DebugSettingsView: View {
    @Environment(DataManager.self) private var dataManager

    // Force Reload
    @State private var isReloading = false
    @State private var reloadMessage: String?
    @State private var showForceReloadConfirmation = false

    // Test Data
    @State private var useTestData = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Debug Tools")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 10) {
                Button {
                    showForceReloadConfirmation = true
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

                Toggle("Use Test Data", isOn: $useTestData)
                    .onChange(of: useTestData) { _, newValue in
                        dataManager.useTestData = newValue
                    }
            }

            Spacer()
        }
        .padding(30)
        .confirmationDialog(
            "Force Reload Data",
            isPresented: $showForceReloadConfirmation,
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

        dataManager.loadData()
        reloadMessage = "✅ Data reloaded successfully."

        isReloading = false
    }
}
