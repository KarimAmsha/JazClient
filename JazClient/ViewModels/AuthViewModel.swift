//
//  AuthViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var loggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorTitle: String = LocalizedStringKey.error
    @Published var errorMessage: String?
    @Published var showErrorPopup: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private let errorHandling: ErrorHandling
    @Published var userSettings = UserSettings.shared

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }

    func registerUser(params: [String: Any], onsuccess: @escaping (String, String) -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.register(params: params)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    self?.user = response.items
                    self?.handleVerificationStatus(isVerified: response.items?.isVerify ?? false)
                    self?.errorMessage = nil
                    if let userId = response.items?.id, let token = response.items?.token {
                        onsuccess(userId, token)
                    } else {
                        onsuccess("", "")
                    }
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func verify(params: [String: Any], onsuccess: @escaping (Bool, String) -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.verify(params: params)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    self?.user = response.items
                    self?.errorMessage = nil
                    let profileCompleted = !(self?.user?.full_name?.isEmpty ?? false)
                    if profileCompleted {
                        self?.handleVerificationStatus(isVerified: response.items?.isVerify ?? false)
                    } else {
                        self?.userSettings.token = self?.user?.token ?? ""
                        onsuccess(profileCompleted, self?.user?.token ?? "")
                    }
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func resend(params: [String: Any], onsuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.resend(params: params)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    self?.user = response.items
                    self?.handleVerificationStatus(isVerified: response.items?.isVerify ?? false)
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func logoutUser(onsuccess: @escaping () -> Void) {
//        guard let token = userSettings.token else {
//            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
//            return
//        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.logout(userID: userSettings.id ?? "")
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    self?.user = response.items
                    self?.userSettings.logout()
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func deleteAccount(onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteAccount(id: userSettings.id ?? "", token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    self?.user = response.items
                    self?.userSettings.logout()
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func guest(onsuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.guest
        
        DataProvider.shared.request(endpoint: endpoint, responseType: CustomApiResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: CustomApiResponse) in
                if let status = response.status, status {
                    self?.errorMessage = nil
                    UserSettings.shared.guestLogin(token: response.items ?? "")
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.messageAr ?? ""))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func logout() {
        // Perform the logout operation
//        userSettings.id = 0
//        userSettings.access_token = ""
        // ... Reset other user-related properties ...

//        updateLoginStatus()
    }

    // Other authentication-related functions

    // You can include user profile management functions here as well.
}

extension AuthViewModel {
    func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
    
    func handleVerificationStatus(isVerified: Bool) {
        if isVerified {
            // User is verified
            if let user = self.user {
                UserSettings.shared.login(user: user, id: user.id ?? "", token: user.token ?? "")
            }
        } else {
            // User is not verified
            errorMessage = nil
        }
    }
}
