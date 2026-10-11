//
//  NetworkError.swift
//  LoginExercise
//
//  Created by Nurzhanat Zhussup on 11.10.26.
//


import Foundation

enum NetworkingError: Error {
    case serializationFailed
    case invalidEmail
    case emailNotFound
    case wrongPassword
    case offline
    case invalidResponseFormat
    case httpError(Int)
    case unexpectedError(String)
}

nonisolated struct ResponseError: Codable {
    let error: FirebaseError

    struct FirebaseError: Codable {
        let code: Int
        let message: String
        let errors: [ErrorDetail]?
    }

    struct ErrorDetail: Codable {
        let message: String
        let domain: String?
        let reason: String?
    }
}
