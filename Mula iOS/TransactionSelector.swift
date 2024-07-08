//
//  TransactionSelector.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 6/22/24.
//

import SwiftUI
import FinanceKit
import FinanceKitUI

struct TransactionSelector: View {
  @State private var selectedItems: [FinanceKit.Transaction] = []

    var body: some View {
        if FinanceStore.isDataAvailable(.financialData) {
            TransactionPicker(selection: $selectedItems) {
                Text("Show Transaction Picker")
            }
        } else {
            Text("Financial Data is unavailable")
        }
    }
}
