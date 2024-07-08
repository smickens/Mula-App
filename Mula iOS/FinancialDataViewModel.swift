//
//  FinancialDataViewModel.swift
//  Mula iOS
//
//  Created by Shanti Mickens on 6/22/24.
//

import Foundation
import FinanceKit

// MARK: can't use financekit without entitlement
class FinancialDataViewModel: ObservableObject {
    let store = FinanceStore.shared
    var accounts : [Account] = []

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard FinanceStore.isDataAvailable(.financialData) else { return }

        Task {
            do {
                let authStatus = try await store.requestAuthorization()

                guard authStatus == .authorized else { return }

                queryAccounts()
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func queryAccounts() {
        let sortDescriptor = SortDescriptor(\Account.displayName)
        let predicate = #Predicate<Account> { account in
           account.institutionName == "Apple"
        }
        let query = AccountQuery(
           sortDescriptors: [sortDescriptor],
           predicate: predicate
        )

        Task {
            do {
                accounts = try await store.accounts(query: query)
            } catch {
                print("Error: \(error)")
            }
        }
    }

}
