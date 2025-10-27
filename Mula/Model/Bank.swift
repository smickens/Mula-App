//
//  Bank.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

enum Bank: String, CaseIterable, Codable, Identifiable {
    case apple
    case usBank
    case bilt

    var id: String { rawValue }

    var accountId: UUID {
        switch self {
        case .apple:
            return UUID(uuidString: "349FC2EA-B354-4171-9FA2-661591A278C0")!
//        case .appleSavings:
//            return UUID(uuidString: "43CEECD4-3361-405E-85E8-B9D2EE85285A")!
        case .usBank:
            return UUID(uuidString: "781259EA-A78D-431A-B697-3EC87A9183D2")!
        case .bilt:
            return UUID(uuidString: "D0CE5713-B50B-47FD-9F90-B8C0E31091F6")!
        }
    }
}
