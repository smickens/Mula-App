//
//  String+CSVParsing.swift
//  MulaCore
//
//  Created by Shanti Mickens on 6/4/26.
//

import Foundation

extension String {
    func removingQuotes() -> String {
        trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
    }

    func removingByteOrderMark() -> String {
        trimmingCharacters(in: CharacterSet(charactersIn: "\u{FEFF}"))
    }
}
