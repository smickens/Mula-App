//
//  SettingsView.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            AccountsView()
                .tabItem {
                    Text("Accounts")
                }

            DebugSettingsView()
                .tabItem {
                    Text("Debug")
                }
        }
        .padding()
    }
}
