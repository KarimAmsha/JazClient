//
//  UserViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import Combine
import Firebase

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var addressBook: [AddressItem]?
//    @Published var reviewItems: [ReviewItems] = []
    private var cancellables = Set<AnyCancellable>()
    @Published var errorTitle: String = LocalizedStringKey.error
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    private let errorHandling: ErrorHandling
    private let dataProvider = DataProvider.shared
    @Published var uploadProgress: Double? // Use an optional Double
    @Published var userSettings = UserSettings.shared // Use the shared instance of UserSettings
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
//    @Published var users: [FBUser] = []
//    @Published var fbUser: FBUser?
//    @Published var checkPoint: CheckPoint?

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }

    func updateUploadProgress(newProgress: Double) {
        uploadProgress = newProgress
    }
    
    func startUpload() {
        isLoading = false
        isLoading = true
    }
    
    func finishUpload() {
        isLoading = false
    }
    
    func updateUserData(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        print("tokentoken \(token)")

        startUpload()
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.updateUserData(params: params, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.finishUpload()
                case .failure(let error):
                    print("1111 \(error)")
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                    self.finishUpload()
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                if response.status {
                    // Handle the successful response, if needed
                    self?.user = response.items // The user object
                    self?.handleUserData()
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    print("2222 \(response.message)")
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.finishUpload()
            })
            .store(in: &cancellables)
    }

    func updateUserDataWithImage(imageData: Data?, additionalParams: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        self.updateUploadProgress(newProgress: 0) // Initialize the progress to 0%
        startUpload()
        
        var endpoint: DataProvider.Endpoint
        var imageFiles: [(Data, String)] = []
        if let imageData = imageData {
            endpoint = .updateUserDataWithImage(params: additionalParams, imageData: imageData, token: token)
            imageFiles.append((imageData, "image"))
        } else {
            // In this case, you still want to send a request with additionalParams
            endpoint = .updateUserDataWithImage(params: additionalParams, imageData: nil, token: token)
        }
        
        dataProvider.requestMultipart(endpoint: endpoint, imageFiles: imageFiles, responseType: SingleAPIResponse<User>.self)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.updateUploadProgress(newProgress: 1.0) // Set progress to 100% when the upload is complete
                    self?.finishUpload()
                case .failure(let error):
                    // Handle the error
                    self?.handleAPIError(error)
                    self?.finishUpload()
                }
            }, receiveValue: { (response, uploadProgress) in
                if response.status {
                    // Handle the successful response, if needed
                    self.updateUploadProgress(newProgress: uploadProgress) // The upload progress (0.0 to 1.0)
                    self.user = response.items // The user object
                    self.handleUserData()
                    self.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                    
                    // Handle status code 405 using ErrorHandler
                    self.errorHandling.handleStatusCode405(code: response.code, errorMessage: response.message, updateErrorMessage: { errorMessage in
                        self.errorMessage = errorMessage
                    }, onLogout: {
                        self.userSettings.logout()
                    })
                }
                
            })
            .store(in: &cancellables)
    }
    
//    func updateUserDataWithImage(token: String, imageFiles: [(Data, String)]?, additionalParams: [String: Any], onsuccess: @escaping (String) -> Void) {
////        guard let token = userSettings.token else {
////            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
////            return
////        }
//        
//        self.updateUploadProgress(newProgress: 0) // Initialize the progress to 0%
//        startUpload()
//        
//        var endpoint: DataProvider.Endpoint
//        endpoint = .updateUserDataWithImage(params: additionalParams, imageFiles: imageFiles, token: token)
//
//        dataProvider.requestMultipart(endpoint: endpoint, imageFiles: imageFiles, responseType: SingleAPIResponse<User>.self)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .finished:
//                    self?.updateUploadProgress(newProgress: 1.0) // Set progress to 100% when the upload is complete
//                    self?.finishUpload()
//                case .failure(let error):
//                    // Handle the error
//                    self?.handleAPIError(error)
//                    self?.finishUpload()
//                }
//            }, receiveValue: { (response, uploadProgress) in
//                if response.status {
//                    // Handle the successful response, if needed
//                    self.updateUploadProgress(newProgress: uploadProgress) // The upload progress (0.0 to 1.0)
//                    self.user = response.items // The user object
//                    self.handleUserData()
//                    self.errorMessage = nil
//                    onsuccess(response.message)
//                } else {
//                    // Use the centralized error handling component
//                    self.handleAPIError(.customError(message: response.message))
//                }
//                
//            })
//            .store(in: &cancellables)
//    }
    
    func fetchUserData(onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getUserProfile(token: token)
        
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
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func addReview(orderID: String, params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addReview(orderID: orderID, params: params, token: token)
        
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
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}

extension UserViewModel {
    func addAddressOther(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addAddress(params: params, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<AddressItem>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<AddressItem>) in
                if response.status {
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func addAddress(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.addAddress(params: params, token: token)

        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<AddressItem>.self) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func getAddressList() {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = DataProvider.Endpoint.getAddressList(token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: ArrayAPIResponse<AddressItem>.self) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    self?.addressBook = response.items
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func deleteAddress(id: String, onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = DataProvider.Endpoint.deleteAddress(id: id, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: ArrayAPIResponse<AddressItem>.self) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func updateAddress(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.updateAddress(params: params, token: token)

        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<AddressItem>.self) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }

    func getAddressByType(type: String) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let endpoint = DataProvider.Endpoint.getAddressByType(type: type, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: ArrayAPIResponse<AddressItem>.self) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    self?.addressBook = response.items
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self?.handleAPIError(error)
            }
        }
    }
    
    func addComplain(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addComplain(params: params, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<Complain>.self) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self?.errorMessage = nil
                    onsuccess(response.message)
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
    
//    func getReviews(page: Int?, limit: Int?, id: String) {
//        guard let token = userSettings.token else {
//            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
//            return
//        }
//
//        isFetchingMoreData = true
//        errorMessage = nil
//
//        let endpoint = DataProvider.Endpoint.getRates(page: page, limit: limit, id: id, token: token)
//        
//        dataProvider.request(endpoint: endpoint, responseType: PaginationArrayAPIResponse<ReviewItems>.self) { [weak self] result in
//            guard let self = self else { return }
//            self.isLoading = false
//            self.isFetchingMoreData = false
//            
//            switch result {
//            case .success(let response):
//                if response.status {
//                    if let items = response.items {
//                        self.reviewItems.append(contentsOf: items)
//                        print("nnnn \(self.reviewItems)")
//                        self.totalPages = response.pagination?.totalPages ?? 1
//                        self.pagination = response.pagination
//                    }
//                    self.errorMessage = nil
//                } else {
//                    // Handle API error and update UI
//                    handleAPIError(.customError(message: response.message))
//                    isFetchingMoreData = false
//                }
//            case .failure(let error):
//                // Use the centralized error handling component
//                self.handleAPIError(error)
//                self.isFetchingMoreData = false
//            }
//        }
//    }

//    func loadMoreReview(id: String, limit: Int?) {
//        guard !isFetchingMoreData, currentPage < totalPages else {
//            // Don't fetch more data while a request is already in progress or no more pages available
//            return
//        }
//
//        currentPage += 1
//        getReviews(page: currentPage, limit: limit, id: id)
//    }
}

extension UserViewModel {
    func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
    
    func handleUserData() {
        if let user = self.user {
            UserSettings.shared.login(user: user, id: user.id ?? "", token: user.token ?? "")
        }
    }
}

extension UserViewModel {
//    func fetchAllUsers() {
//        // Fetch users from Firebase and populate the users property
//        let ref = Database.database().reference()
//        let usersRef = ref.child("user")
//
//        usersRef.observeSingleEvent(of: .value) { snapshot in
//            var users: [FBUser] = []
//
//            for case let child as DataSnapshot in snapshot.children {
//                let user = FBUser(child)
//                users.append(user)
//            }
//
//            DispatchQueue.main.async {
//                self.users = users
//            }
//        }
//    }
    
//    func fetchUserDataFromFirebase(userId: String) {
//        guard !userId.isEmpty else {
//            return
//        }
//        
//        let ref = Database.database().reference()
//        
//        ref.child("user").child(userId).observeSingleEvent(of: .value, with: { snapshot in
//            if snapshot.exists() {
//                self.fbUser = FBUser(snapshot)
//            } else {
//                self.fbUser = nil
//            }
//        })
//    }
}

extension UserViewModel {
//    func updateUserWithToken(settings: UserSettings, completion: @escaping (String?, Bool) -> Void) {
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                completion("Error: \(error.localizedDescription)", false)
//            } else if let token = token {
//                let user = FBUser(id: settings.id ?? "",
//                                  fcmToken: token,
//                                  image: settings.user?.image ?? "",
//                                  lastOnline: 0,
//                                  name: settings.user?.full_name ?? "",
//                                  online: false)
//                
//                self.updateFBUserData(id: settings.id ?? "", user: user) { errorMsg, status in
//                    completion(errorMsg, status)
//                }
//            }
//        }
//    }
    
//    func updateFBUserData(id: String, user: FBUser, completion: @escaping (String?, Bool) -> Void) {
//        guard !id.isEmpty else {
//            completion("User ID is empty", false)
//            return
//        }
//
//        Constants.usersRef.child(id).updateChildValues(user.toAnyObject()) { error, _ in
//            if let error = error {
//                completion(error.localizedDescription, false)
//            } else {
//                completion(nil, true)
//            }
//        }
//    }
}

extension UserViewModel {
    func refreshFcmToken(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.refreshFcmToken(params: params, token: token)
        
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
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self?.handleAPIError(.customError(message: response.message))
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}
