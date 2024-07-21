//
//  Transaction.swift
//  Mula
//
//  Created by Shanti Mickens on 7/20/24.
//

import Foundation

protocol Transaction {
    var title: String { get set }
    var date: Date { get set }
    var amount: Double { get set }
}
