//
//  Extensions.swift
//  Mula
//
//  Created by Shanti Mickens on 2/1/24.
//

import Foundation

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
}
