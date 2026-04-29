//
//  FirebaseRepresentable.swift
//  Mula
//
//  Created by Shanti Mickens on 2/22/26.
//

import Foundation

protocol FirebaseRepresentable {
    var firebaseKey: String { get }

    func asDictionary() throws -> [String: Any]

    static func decode(from dictionary: [String: Any]) throws -> Transaction
}

enum TransactionFirebaseError: LocalizedError {
    case encodeFailed
    case decodeFailed

    var errorDescription: String? {
        switch self {
        case .encodeFailed:
            return "Failed to encode transaction"
        case .decodeFailed:
            return "Failed to decode transaction"
        }
    }
}
