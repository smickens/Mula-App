//
//  SignInView.swift
//  Mula
//
//  Created by Shanti Mickens on 8/5/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct SignInView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInError: String? = nil

    var body: some View {
        if authViewModel.isSignedIn {
            ContentView()
                .environment(authViewModel)
        } else {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let error = authViewModel.signInError {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button {
                    authViewModel.signIn(with: email, and: password)
                } label: {
                    Text("Sign In")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }


}

@Observable final class AuthViewModel {
    var isSignedIn: Bool = false
    var signInError: String? = nil

    init() {
        // Check if user is already signed in
        if Auth.auth().currentUser != nil {
            isSignedIn = true
        }
    }

    func signIn(with email: String, and password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }
            if let error = error {
                print(error)
                self.signInError = "Error signing in: \(error.localizedDescription)"
            } else {
                self.isSignedIn = true
                self.signInError = nil
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
