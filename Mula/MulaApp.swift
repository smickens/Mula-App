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

struct Platform {
#if os(iOS)
    typealias application = UIApplication
    typealias delegate = UIApplicationDelegate
    typealias delegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
    typealias application = NSApplication
    typealias delegate = NSApplicationDelegate
    typealias delegateAdaptor = NSApplicationDelegateAdaptor
#endif
}


@main
struct MulaApp: App {
    // Configure Firebase when the app launches
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SignInView()
#if os(macOS)
                .fontDesign(.monospaced)
                .frame(minWidth: 850, idealWidth: 850, minHeight: 500, idealHeight: 500)
#endif
        }
#if os(macOS)
        .commands {
            SidebarCommands()
        }
#endif
    }
}
