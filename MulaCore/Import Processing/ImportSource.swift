//
//  ImportSource.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

public enum ImportSource: String, CaseIterable, Codable, Identifiable {
    case apple
    case fidelity401k
    case fidelityInvestments
    case usBank
    case wellsFargo

    public var id: String { rawValue }

    public var accountId: UUID {
        switch self {
        case .apple:
            return UUID(uuidString: "349FC2EA-B354-4171-9FA2-661591A278C0")!
        case .fidelity401k:
            return UUID(uuidString: "7C186F0E-A35C-4F7E-B3E3-6BE52FB7A07A")!
        case .fidelityInvestments:
            return UUID(uuidString: "D7CF1D39-14A1-4030-B59A-052CF483F050")!
        case .usBank:
            return UUID(uuidString: "781259EA-A78D-431A-B697-3EC87A9183D2")!
        case .wellsFargo:
            return UUID(uuidString: "D0CE5713-B50B-47FD-9F90-B8C0E31091F6")!
        }
    }

    public var displayName: String {
        switch self {
        case .apple:
            return "Apple Card"
        case .fidelity401k:
            return "Fidelity 401k"
        case .fidelityInvestments:
            return "Fidelity Investments"
        case .usBank:
            return "US Bank"
        case .wellsFargo:
            return "Wells Fargo"
        }
    }
}
