//
//  User.swift
//  LoginExercise
//
//  Created by Nurzhanat Zhussup on 11.10.26.
//


import Foundation

nonisolated struct User: Codable {
    let localId: String
    let email: String
    let displayName: String
    let idToken: String
    let registered: Bool
    let refreshToken: String
    let expiresIn: String
}
