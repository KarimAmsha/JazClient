//
//  CartViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private let errorHandling: ErrorHandling
    @Published var cart: Cart?
    @Published var cartItems: CartItems?
    @Published var cartCount: Int?
    @Published var cartTotal: CartTotal?

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }

    func addToCart(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addToCart(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Cart>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.cart = response.items
                    self.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func getCartItems() {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getCartItems(token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CartItems>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.cartItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func updateCartItems(cartItems: [UpdateCart], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil

        let params: [String: Any] = ["Cart": cartItems.map { ["cart_id": $0.cart_id ?? "", "qty": $0.qty ?? 0] }]
        let endpoint = DataProvider.Endpoint.updateCartItems(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Cart>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.cart = response.items
                    self.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }

    func deleteCart(onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteCart(token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CartItems>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.cartItems = response.items
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func deleteCartItem(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteCartItem(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CartItems>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.cartItems = response.items
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func cartCount(onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.cartCount(token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Int>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.cartCount = response.items
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func cartTotal(onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.cartTotal(token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CartTotal>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.cartTotal = response.items
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
    
    func checkCartCoupun(params: [String: Any]) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.checkCartCoupun(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CartTotal>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.cartTotal = response.items
                    self.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(.customError(message: error.localizedDescription))
            }
        }
    }
}

extension CartViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}
