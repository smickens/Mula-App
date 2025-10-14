//
//  MulaApp.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

@main
struct MulaApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SignInView()
                .fontDesign(.monospaced)
                .frame(minWidth: 900, idealWidth: 900, minHeight: 650, idealHeight: 650)
        }
        .commands {
            SidebarCommands()
        }
    }
}
