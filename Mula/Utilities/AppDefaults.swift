//
//  AppDefaults.swift
//  Mula
//
//  Created by Codex on 5/25/26.
//

import Foundation

enum AppDefaults {
    enum Debug {
        private static let useTestDataKey = "debug.useTestData"

        static var useTestData: Bool {
            get {
                UserDefaults.standard.bool(forKey: useTestDataKey)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: useTestDataKey)
            }
        }
    }
}
