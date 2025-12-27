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
            AccountsSettingsView()
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
