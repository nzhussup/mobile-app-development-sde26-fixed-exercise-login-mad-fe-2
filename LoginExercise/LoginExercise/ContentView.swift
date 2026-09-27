//
//  ContentView.swift
//  LoginExercise
//
//  Created by Nurzhanat Zhussup on 27.09.26.
//

import SwiftUI

struct ContentView: View {
    private let correctEmail = "student@example.com"
    private let correctPassword = "password"

    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @FocusState private var focusedField: LoginField?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Login")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Email")
                        .font(.headline)

                    Spacer()
                }

                TextField("Enter email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .password
                    }
                    .disabled(isLoggingIn)

                HStack {
                    Text("Password")
                        .font(.headline)

                    Spacer()
                }

                SecureField("Enter password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        login()
                    }
                    .disabled(isLoggingIn)
            }

            Button("Login") {
                login()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoggingIn)

            if isLoggingIn {
                ProgressView("Logging in...")
            }

            Spacer()
        }
        .padding()
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func login() {
        guard !isLoggingIn else {
            return
        }

        guard !email.isEmpty else {
            showLoginAlert(title: "Missing Email", message: "Please enter your email address.")
            return
        }

        guard !password.isEmpty else {
            showLoginAlert(title: "Missing Password", message: "Please enter your password.")
            return
        }

        isLoggingIn = true
        focusedField = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoggingIn = false

            if email == correctEmail && password == correctPassword {
                showLoginAlert(title: "Success", message: "You are logged in.")
            } else {
                showLoginAlert(title: "Login Failed", message: "Email or password is incorrect.")
            }
        }
    }

    private func showLoginAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

private enum LoginField {
    case email
    case password
}

#Preview {
    ContentView()
}
