//
//  MulaApp.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI

@main
struct MulaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .fontDesign(.monospaced)
        }
        .commands {
            SidebarCommands()
        }
    }
}
