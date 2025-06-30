//
//  UserSettings.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import Combine
import Foundation

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var user: User?
    @Published var id: String?
    @Published var token: String?
    @Published var userRole: UserRole = .client
    @Published var fcmToken: String? {
        didSet {
            if let token = fcmToken {
                saveFCMTokenToStorage(token: token)
            }
        }
    }

    @Published var loggedIn: Bool {
        didSet {
            if !loggedIn {
                user = nil
                id = nil
                token = nil
                clearUserStorage()
            }
        }
    }
    
    init() {
        // Initialize properties first
        user = nil
        id = nil
        token = nil
        loggedIn = false
        
        // Now you can call methods
        if let storedUser = loadUserFromStorage() {
            user = storedUser.user
            id = storedUser.id
            token = storedUser.token
            loggedIn = true
        }
    }
    
    func login(user: User, id: String, token: String) {
        self.user = user
        self.id = id
        self.token = token
        loggedIn = true
        saveUserToStorage(user: user, id: id, token: token)
    }
    
    func guestLogin(token: String) {
        self.user = nil
        self.id = nil
        self.token = token
        loggedIn = true
        saveTokenToStorage(token: token)
    }
    
    func logout() {
        loggedIn = false
    }
    
    private func saveFCMTokenToStorage(token: String) {
        UserDefaults.standard.set(token, forKey: Keys.fcmToken)
    }

    private func loadUserFromStorage() -> (user: User, id: String, token: String)? {
        if let userData = UserDefaults.standard.data(forKey: Keys.userData),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData),
           let storedId = UserDefaults.standard.string(forKey:  Keys.id),
           let storedToken = UserDefaults.standard.string(forKey:  Keys.token) {
            return (user: decodedUser, id: storedId, token: storedToken)
        }
        return nil
    }
    
    private func saveUserToStorage(user: User, id: String, token: String) {
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: Keys.userData)
            UserDefaults.standard.set(id, forKey: Keys.id)
            UserDefaults.standard.set(token, forKey:  Keys.token)
        }
    }
    
    private func saveTokenToStorage(token: String) {
        UserDefaults.standard.set(token, forKey:  Keys.token)
    }

    func clearUserStorage() {
        UserDefaults.standard.removeObject(forKey: Keys.userData)
        UserDefaults.standard.removeObject(forKey:  Keys.id)
        UserDefaults.standard.removeObject(forKey:  Keys.token)
        UserDefaults.standard.removeObject(forKey: Keys.fcmToken)
    }
}

extension UserSettings {
    private struct Keys {
        static let id = "id"
        static let userData = "userData"
        static let token = "token"
        static let fcmToken = "fcmToken"
    }
}
