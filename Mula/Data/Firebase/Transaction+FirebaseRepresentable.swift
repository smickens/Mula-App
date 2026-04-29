//
//  Transaction+FirebaseRepresentable.swift
//  Mula
//
//  Created by Shanti Mickens on 2/22/26.
//

import Foundation

extension Transaction: FirebaseRepresentable {

    var firebaseKey: String {
        id.uuidString
    }

    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        let data = try encoder.encode(self)

        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TransactionFirebaseError.encodeFailed
        }

        return dictionary
    }

    static func decode(from dictionary: [String: Any]) throws -> Transaction {
        // Convert Firebase snapshot to Data
        let data = try JSONSerialization.data(withJSONObject: dictionary)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        // Decode Transaction
        return try decoder.decode(Transaction.self, from: data)
    }
}
