//
//  WishesViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 10.06.2024.
//

import SwiftUI
import Combine
import Alamofire

class WishesViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    private let errorHandling: ErrorHandling
    @Published var errorMessage: String?
    @Published var userSettings = UserSettings.shared
    @Published var isLoading: Bool = false
    @Published var groups: [Group] = []
    @Published var friends: [Friend] = []
    @Published var explor: [Wish] = []
    @Published var wishes: [Wish] = []
    @Published var wish: Wish?

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }
    
    func getWishGroups(page: Int?, limit: Int?, user_id: String?) {
        guard let token = userSettings.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getWishGroups(page: page, limit: limit, user_id: user_id, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Group>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    if let items = response.items {
                        self.groups.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                    isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }

    func loadMoreGroups(limit: Int?, user_id: String?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getWishGroups(page: currentPage, limit: limit, user_id: user_id)
    }

    func createGroup(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addGroup(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CreateGroup>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func editGroup(id: String, params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.editGroup(id: id, params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CreateGroup>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }

    func deleteGroup(id: String, params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteGroup(id: id, params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<String>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func addFriend(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addFriend(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddFriend>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func getFriends(page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getFriends(page: page, limit: limit, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Friend>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    if let items = response.items {
                        self.friends.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                    isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }

    func loadMoreFriends(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getFriends(page: currentPage, limit: limit)
    }
    
    func getExplor(page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.explore(page: page, limit: limit, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Wish>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    if let items = response.items {
                        self.explor.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                    isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }

    func loadMoreExplor(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getExplor(page: currentPage, limit: limit)
    }

    func addWish(params: [String: Any], onsuccess: @escaping (String, String) -> Void) {
        guard let token = UserSettings.shared.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addWish(params: params, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddWish>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.status {
                    self.errorMessage = response.message
                    onsuccess(response.items?.id ?? "", response.message)
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
            }
        }
    }

    func getUserWishes(page: Int?, limit: Int?, params: [String: Any]) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getUserWishes(page: page, limit: limit, params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Wish>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.status {
                    if let items = response.items {
                        self.wishes.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                    isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }

    func loadMoreWishs(limit: Int?, params: [String: Any]) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            return
        }

        currentPage += 1
        getUserWishes(page: currentPage, limit: limit, params: params)
    }

    func getWish(id: String) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getWish(id: id, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Wish>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            print("www \(result)")
            switch result {
            case .success(let response):
                if response.status {
                    self.wish = response.items
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
            }
        }
    }

    func payWish(id: String, params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.payWish(id: id, params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddWish>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func addOrderWish(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addOrderWish(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<OrderModel>.self) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
}

extension WishesViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}
