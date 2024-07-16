//
//  MulaApp.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import AppKit

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

class AppDelegate: NSObject, Platform.delegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()

        let _ = DataManager.shared

//        Auth.auth().signInAnonymously { (authResult, error) in
//            if let error = error {
//                print("Error signing in anonymously: \(error.localizedDescription)")
//            } else {
//                print("Successfully signed in anonymously.")
//                // Handle successful sign-in
//            }
//        }
    }
}


@main
struct MulaApp: App {
    // register app delegate for Firebase setup
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif

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
