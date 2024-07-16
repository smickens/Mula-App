//
//  MulaApp.swift
//  Mula
//
//  Created by Shanti Mickens on 1/25/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

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
#if os(iOS)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
#elseif os(macOS)
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()

//        Auth.auth().signInAnonymously { (authResult, error) in
//            if let error = error {
//                print("Error signing in anonymously: \(error.localizedDescription)")
//            } else {
//                print("Successfully signed in anonymously.")
//                // Handle successful sign-in
//            }
//        }
    }
#endif
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
