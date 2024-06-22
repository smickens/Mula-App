//
//  Item.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 6/22/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
