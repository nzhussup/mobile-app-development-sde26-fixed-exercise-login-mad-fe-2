//
//  ContentView.swift
//  LoginExercise
//
//  Created by Nurzhanat Zhussup on 27.09.26.
//

import SwiftUI

struct ContentView: View {

    private let networking = NetworkingService()

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
            showLoginAlert(
                title: "Missing Email",
                message: "Please enter your email address."
            )
            return
        }

        guard !password.isEmpty else {
            showLoginAlert(
                title: "Missing Password",
                message: "Please enter your password."
            )
            return
        }

        isLoggingIn = true
        focusedField = nil

        networking.login(
            email: email,
            password: password
        ) { user, error in

            isLoggingIn = false

            if let error = error {
                handleLoginError(error)
                return
            }

            if let user = user {
                print("Logged in user: \(user.email)")

                showLoginAlert(
                    title: "Success",
                    message: "You are logged in as \(user.email)."
                )
            } else {
                showLoginAlert(
                    title: "Login Failed",
                    message: "An unexpected error occurred."
                )
            }
        }
    }

    private func handleLoginError(_ error: NetworkingError) {
        let message: String

        switch error {
        case .serializationFailed:
            message = "Failed to prepare the login request."

        case .invalidEmail:
            message = "Please enter a valid email address."

        case .emailNotFound:
            message = "No account exists with this email."

        case .wrongPassword:
            message = "The password is incorrect."

        case .offline:
            message = "No internet connection. Please try again."

        case .invalidResponseFormat:
            message = "Received an unexpected server response."

        case .httpError(let statusCode):
            message = "Server error (HTTP \(statusCode))."

        case .unexpectedError(let description):
            message = description
        }

        showLoginAlert(
            title: "Login Failed",
            message: message
        )
    }

    private func showLoginAlert(
        title: String,
        message: String
    ) {
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
