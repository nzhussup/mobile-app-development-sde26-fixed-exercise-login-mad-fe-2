//
//  NetworkingService.swift
//  LoginExercise
//
//  Created by Nurzhanat Zhussup on 11.10.26.
//

import Foundation

class NetworkingService {

    private let session = URLSession(configuration: .default)

    private let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"

    func login(
        email: String,
        password: String,
        completionHandler: @escaping (User?, NetworkingError?) -> Void
    ) {
        // Always call the completion handler on the main thread.
        func complete(
            _ user: User?,
            _ error: NetworkingError?
        ) {
            DispatchQueue.main.async {
                completionHandler(user, error)
            }
        }

        let endpoint = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)"

        guard let url = URL(string: endpoint) else {
            complete(nil, .unexpectedError("Invalid API URL"))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]

        // Serialize request body.
        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
        } catch {
            complete(nil, .serializationFailed)
            return
        }

        let task = session.dataTask(with: request) {
            data, response, error in

            // Handle network errors.
            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain &&
                    (error.code == NSURLErrorNotConnectedToInternet ||
                     error.code == NSURLErrorNetworkConnectionLost) {
                    complete(nil, .offline)
                } else {
                    complete(
                        nil,
                        .unexpectedError(error.localizedDescription)
                    )
                }
                return
            }

            // Validate HTTP response.
            guard let httpResponse = response as? HTTPURLResponse else {
                complete(nil, .invalidResponseFormat)
                return
            }

            guard let data = data else {
                complete(nil, .invalidResponseFormat)
                return
            }

            let decoder = JSONDecoder()

            // Handle unsuccessful HTTP responses.
            guard (200...299).contains(httpResponse.statusCode) else {

                if let responseError = try? decoder.decode(
                    ResponseError.self,
                    from: data
                ) {
                    let message = responseError.error.message

                    switch message {
                    case "INVALID_EMAIL":
                        complete(nil, .invalidEmail)

                    case "EMAIL_NOT_FOUND":
                        complete(nil, .emailNotFound)

                    case "INVALID_PASSWORD":
                        complete(nil, .wrongPassword)

                    case "INVALID_LOGIN_CREDENTIALS":
                        complete(
                            nil,
                            .unexpectedError(
                                "Invalid email or password."
                            )
                        )

                    default:
                        complete(
                            nil,
                            .httpError(httpResponse.statusCode)
                        )
                    }
                } else {
                    complete(
                        nil,
                        .httpError(httpResponse.statusCode)
                    )
                }

                return
            }

            // Decode successful login response.
            do {
                let user = try decoder.decode(
                    User.self,
                    from: data
                )

                complete(user, nil)

            } catch {
                complete(nil, .invalidResponseFormat)
            }
        }

        // Start the asynchronous request.
        task.resume()
    }
}
