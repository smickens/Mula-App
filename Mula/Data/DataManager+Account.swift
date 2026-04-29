//
//  DataManager+Account.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import Foundation

extension DataManager {

    /// Loads accounts from the active data source.
    func loadAccounts() {
        Task {
            do {
                accounts = try await dataSource.loadAccounts()
            } catch {
                print("❌ Error loading accounts: \(error.localizedDescription)")
            }
        }
    }

    /// Adds a new account to the active data source.
    func addAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.addAccount(account)
                accounts.append(account)
            } catch {
                print("❌ Error adding account: \(error.localizedDescription)")
            }
        }
    }

    /// Updates an existing account in the active data source.
    func updateAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.updateAccount(account)
                if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                    accounts[index] = account
                }
            } catch {
                print("❌ Error updating account: \(error.localizedDescription)")
            }
        }
    }

    /// Deletes an account from the active data source.
    func deleteAccount(_ account: Account) {
        Task {
            do {
                try await dataSource.deleteAccount(account)
                accounts.removeAll { $0.id == account.id }
            } catch {
                print("❌ Error deleting account: \(error.localizedDescription)")
            }
        }
    }
}
