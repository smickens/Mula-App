//
//  DataManager+Accounts.swift
//  Mula
//
//  Created by Shanti Mickens on 10/16/25.
//

import Foundation
import FirebaseDatabase

extension DataManager {

    /// Loads accounts from Firebase
    func loadAccounts() {
        accountRef.getData { [weak self] error, snapshot in
            guard let self = self else { return }

            if let error {
                print("❌ Error getting account data: \(error.localizedDescription)")
                return
            }

            guard let value = snapshot?.value else {
                print("⚠️ No account data available")
                return
            }

            if let data = value as? [String: [String: Any]] {
                for (accountId, accountData) in data {
                    guard let name = accountData["name"] as? String,
                          let typeString = accountData["type"] as? String,
                          let type = AccountType.get(from: typeString)
                    else {
                        print("⚠️ Skipping malformed account: \(accountData)")
                        continue
                    }

                    let account = Account(
                        id: UUID(uuidString: accountId) ?? UUID(),
                        name: name,
                        type: type
                    )

                    self.accounts.append(account)
                }
            }

            print("✅ Loaded \(accounts.count) accounts from Firebase.")
        }
    }

    /// Adds a new account to Firebase
    func addAccount(_ account: Account) {
        let accountDictionary: [String: Any] = [
            "name": account.name,
            "type": account.type.rawValue
        ]

        let accountID = account.id.uuidString

        accountRef.child(accountID).setValue(accountDictionary) { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error adding account: \(error.localizedDescription)")
            } else {
                self.accounts.append(account)
                print("✅ Added new account \(account.name)")
            }
        }
    }

    /// Updates an existing account in Firebase
    func updateAccount(_ account: Account) {
        let accountDictionary: [String: Any] = [
            "name": account.name,
            "type": account.type.rawValue
        ]

        accountRef.child(account.id.uuidString).updateChildValues(accountDictionary) { [weak self] error, _ in
            if let error {
                print("❌ Error updating account: \(error.localizedDescription)")
                return
            }

            guard let self = self else { return }

            print("✅ Updated account \(account.name)")

            // Update locally so UI reflects the change immediately
            if let index = self.accounts.firstIndex(where: { $0.id == account.id }) {
                self.accounts[index] = account
            }
        }
    }

    /// Deletes an account from Firebase
    func deleteAccount(_ account: Account) {
        accountRef.child(account.id.uuidString).removeValue { [weak self] error, _ in
            guard let self = self else { return }

            if let error {
                print("❌ Error deleting account: \(error.localizedDescription)")
            } else if let index = self.accounts.firstIndex(where: { $0.id == account.id }) {
                self.accounts.remove(at: index)
                print("✅ Deleted account with id \(account.id) name \(account.name)")
            }
        }
    }
}
