//
//  MulaApp.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import SwiftData

@main
struct MulaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.monospaced)
                .frame(minWidth: 850, idealWidth: 850, minHeight: 500, idealHeight: 500)
        }
        .commands {
            SidebarCommands()
        }
        .modelContainer(for: [Expense.self, Budget.self])
    }
}
