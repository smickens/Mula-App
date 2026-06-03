//
//  Bank.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

enum Bank: String, CaseIterable, Codable, Identifiable {
    case apple
    case fidelity401k
    case usBank
    case wellsFargo

    var id: String { rawValue }

    // credit card accounts only
    var accountId: UUID {
        switch self {
        case .apple:
            return UUID(uuidString: "349FC2EA-B354-4171-9FA2-661591A278C0")!
//        case .appleSavings:
//            return UUID(uuidString: "43CEECD4-3361-405E-85E8-B9D2EE85285A")!
        case .fidelity401k:
            return UUID(uuidString: "7C186F0E-A35C-4F7E-B3E3-6BE52FB7A07A")!
        case .usBank:
            return UUID(uuidString: "781259EA-A78D-431A-B697-3EC87A9183D2")!
        case .wellsFargo:
            return UUID(uuidString: "D0CE5713-B50B-47FD-9F90-B8C0E31091F6")!
        }
    }

    var displayName: String {
        switch self {
        case .apple:
            return "Apple Card"
        case .fidelity401k:
            return "Fidelity 401k"
        case .usBank:
            return "US Bank"
        case .wellsFargo:
            return "Wells Fargo"
        }
    }
}
