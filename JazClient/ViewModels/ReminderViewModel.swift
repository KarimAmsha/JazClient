//
//  ReminderViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI
import Combine

class ReminderViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    private let errorHandling: ErrorHandling
    @Published var errorMessage: String?
    @Published var userSettings = UserSettings.shared
    @Published var isLoading: Bool = false
    @Published var reminders: [Reminder] = []
    
    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }
    
    func getReminders(page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.reminder(page: page, limit: limit, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: ArrayAPIResponse<Reminder>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.code == 200 {
                    if let items = response.items {
                        self.reminders.append(contentsOf: items)
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

    func loadMorReminders(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getReminders(page: currentPage, limit: limit)
    }
    
    func addReminder(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addReminder(params: params, token: token)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<CreateReminder>.self) { [weak self] result in
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
    
    func deleteReminder(id: String, params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.deleteReminder(id: id, params: params, token: token)

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
}

extension ReminderViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}
