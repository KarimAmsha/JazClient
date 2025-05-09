//
//  InitialViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import Combine
import Alamofire

class InitialViewModel: ObservableObject {
    @Published var welcomeItems: [WelcomeItem]?
    @Published var constantsItems: [ConstantItem]?
    @Published var mainCategoryItems: [MainCategory]?
    @Published var constantItem: ConstantItem?
    @Published var appconstantsItems: AppConstants?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private let errorHandling: ErrorHandling
    @Published var homeItems: HomeItems?
    @Published var products: [Products] = []
    @Published var product: Products?
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    @Published var appContactItem: [Contact] = []
    @Published var favoriteItem: FavoriteItem?
    @Published var favoriteItems: [FavoriteItems] = []
    @Published var whatsAppContactItem: Contact?

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }
    
    func fetchWelcomeItems() {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getWelcome
        
        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<WelcomeItem>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: ArrayAPIResponse<WelcomeItem>) in
                if response.status {
                    self?.welcomeItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func fetchConstantsItems() {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getConstants
        
        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<ConstantItem>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: ArrayAPIResponse<ConstantItem>) in
                if response.status {
                    self?.constantsItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func fetchConstantItemDetails(_id: String) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getConstantDetails(_id: _id)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<ConstantItem>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<ConstantItem>) in
                if response.status {
                    self?.constantItem = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func fetchAppConstantsItems() {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getAppConstants
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AppConstants>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse) in
                if response.status {
                    self?.appconstantsItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func fetchHomeItems() {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getHome
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<HomeItems>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<HomeItems>) in
                if response.status {
                    self?.homeItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func getMainCategories(q: String?) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getCategories(q: q)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<MainCategory>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: ArrayAPIResponse<MainCategory>) in
                if response.status {
                    self?.mainCategoryItems = response.items
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func fetchContactItems() {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getContact
        
        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Contact>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: ArrayAPIResponse<Contact>) in
                if response.status {
                    self?.appContactItem = response.items ?? []
                    self?.whatsAppContactItem = response.items?.filter({$0.id == "665c8b4f952065449ef7248f"}).first
                    self?.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    func getProducts(page: Int?, limit: Int?, params: [String: Any]) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getProducts(page: page, limit: limit, params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Products>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.status {
                    if let items = response.items {
                        self.products.append(contentsOf: items)
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

    func loadMoreProducts(limit: Int?, params: [String: Any]) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getProducts(page: currentPage, limit: limit, params: params)
    }
    
    func getProductDetails(id: String) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getProductDetails(id: id, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: BaseCustomStatusAPIResponse<Products>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.product = response.items
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
    
    func handleButtonTapped(index: Int) {
        guard let url = URL(string: appContactItem[index].Data ?? "") else {
            errorMessage = "Invalid URL"
            return
        }
        UIApplication.shared.open(url)
    }
    
    func addToFavorite(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addToFavorite(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<FavoriteItem>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.favoriteItem = response.items
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
    
    func getFavorite(page: Int?, limit: Int?) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getFavorite(page: page, limit: limit, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<FavoriteItems>.self) { [weak self] result in
            self?.isLoading = false
            self?.isFetchingMoreData = false
            switch result {
            case .success(let response):
                if response.status {
                    if let items = response.items {
                        self?.favoriteItems.append(contentsOf: items)
                        self?.totalPages = response.pagination?.totalPages ?? 1
                        self?.pagination = response.pagination
                    }
                    self?.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    self?.handleAPIError(.customError(message: response.message))
                    self?.isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
                self?.isFetchingMoreData = false
            }
        }
    }

    func loadMoreFavorite(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getFavorite(page: currentPage, limit: limit)
    }
    
    func addUserProduct2(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addUserProduct(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddUserProduct>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.errorMessage = response.message
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
    
    func addUserProduct(params: [String: String], onsuccess: @escaping (String, String) -> Void) {
        guard let token = UserSettings.shared.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addUserProduct(params: params, token: token)

        let url = endpoint.toAPIEndpoint().fullURL

        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: endpoint.toAPIEndpoint().headers)
            .responseDecodable(of: SingleAPIResponse<AddUserProduct>.self) { [weak self] response in
                guard let self = self else { return }

                self.isLoading = false

                switch response.result {
                case .success(let responseObject):
                    if responseObject.status {
                        self.errorMessage = responseObject.message
                        onsuccess(responseObject.items?.id ?? "", responseObject.message)
                    } else {
                        self.handleAPIError(.customError(message: responseObject.message))
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    self.handleAPIError(.requestError(error))
                }
            }
    }
    
    func addVIP2(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = UserSettings.shared.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addVIP(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddVIP>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.errorMessage = response.message
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

    
    func addVIP(params: [String: String], onsuccess: @escaping (String, String) -> Void) {
        guard let token = UserSettings.shared.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addVIP(params: params, token: token)
        
        let url = endpoint.toAPIEndpoint().fullURL
        
        AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: endpoint.toAPIEndpoint().headers)
            .responseDecodable(of: SingleAPIResponse<AddVIP>.self) { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                
                switch response.result {
                case .success(let responseObject):
                    if responseObject.status {
                        self.errorMessage = responseObject.message
                        onsuccess(responseObject.items?.id ?? "", responseObject.message)
                    } else {
                        self.handleAPIError(.customError(message: responseObject.message))
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    self.handleAPIError(.requestError(error))
                }
            }
    }
}

extension InitialViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}
