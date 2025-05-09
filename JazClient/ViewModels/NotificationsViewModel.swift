//
//  NotificationsViewModel.swift
//  Khawi
//
//  Created by Karim Amsha on 25.10.2023.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

class NotificationsViewModel: ObservableObject {

    @Published var notificationsItems: [NotificationItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private let errorHandling: ErrorHandling
    @Published var userSettings = UserSettings.shared // Use the shared instance of UserSettings
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    @Published var settings = UserSettings.shared

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }

    func fetchNotificationsItems(page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isFetchingMoreData = true
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getNotifications(page: page, limit: limit, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<NotificationItem>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false
            
            switch result {
            case .success(let response):
                if response.status {
                    if let items = response.items {
                        self.notificationsItems.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
            }
        }
    }
    
    func loadMoreNotifications(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        fetchNotificationsItems(page: currentPage, limit: limit)
    }
    
    func deleteNotifications(id: String, onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteNotification(id: id, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: APIResponseCodable.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: APIResponseCodable) in
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

extension NotificationsViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}

extension NotificationsViewModel {
    func sendNotification(saveNotifi : Bool = false,
                             idsArray:[String],
                             obj: NotificationsStruct) {
        
        guard obj.receiverId != settings.id else { return }

        let parameters: Parameters! = ["registration_ids": idsArray,
                                        "priority": "high",
                                        "notification": ["body" : obj.message,
                                                         "sound": 1,
                                                         "title": obj.title,
                                                         "type" : obj.type?.value ?? "",
                                                         "uid"  : obj.receiverId,
                                                         "object" : obj.toDict(),
                                                         "badge": "1"]]
        
        
        sendRequestPost(param: parameters, completion: { (response, error) in
            print("send not.")
        })
    }
    
    func sendRequestPost(param:Parameters, completion:((AFDataResponse<Any>,Error?)->Void)!) {
        let headers = Constants.headers
        AF.request(String(format: Constants.FCMLink), method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                completion(response,nil)
            case .failure(let fail):
                completion(response,fail)
            }
        }
    }
}
