//
//  ImportBatch.swift
//  Mula
//
//  Created by Shanti Mickens on 10/22/25.
//

import Foundation

struct ImportBatch: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let name: String?

    init(id: UUID = UUID(), date: Date = Date(), name: String? = nil) {
        self.id = id
        self.date = date
        self.name = name
    }

    var firebaseKey: String {
        id.uuidString
    }
}
