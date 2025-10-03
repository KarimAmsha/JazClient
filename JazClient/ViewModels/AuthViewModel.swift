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

    func registerCompany(
        params: [String: Any],
        onsuccess: @escaping (Company) -> Void,
        onerror: ((String) -> Void)? = nil
    ) {
        isLoading = true
        errorMessage = nil

        // endpoint مبني على DataProvider حسب مشروعك
        let endpoint = DataProvider.Endpoint.registerCompany(params: params)

        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Company>.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                // إنهاء التحميل في كل الأحوال
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // التعامل مع خطأ API بشكل مركزي
                    let errorMsg = self?.errorHandling.handleAPIError(error) ?? "حدث خطأ غير متوقع"
                    self?.errorMessage = errorMsg
                    self?.showErrorPopup = true
                    onerror?(errorMsg)
                }
            }, receiveValue: { [weak self] response in
                if response.status, let company = response.items {
                    // نجاح التسجيل، أعد العنصر الرئيسي
                    self?.errorMessage = nil
                    onsuccess(company)
                } else {
                    // فشل التسجيل، أظهر الرسالة
                    let apiMsg = response.message.isEmpty ? "فشل في تسجيل الشركة" : response.message
                    self?.errorMessage = apiMsg
                    self?.showErrorPopup = true
                    onerror?(apiMsg)
                }
            })
            .store(in: &cancellables)
    }

    func registerUser(params: [String: Any], onsuccess: @escaping (String, String) -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.register(params: params)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<User>) in
                guard let self = self else { return }
                if response.status, let user = response.items {
                    self.user = user
                    self.errorMessage = nil

                    let profileCompleted = !(user.full_name?.isEmpty ?? false)

                    // تسجيل المستخدم دائماً بعد التحقق (حتى لو الملف غير مكتمل)
                    UserSettings.shared.login(user: user, id: user.id ?? "", token: user.token ?? "")

                    // يمكنك أيضاً التأكد من حالة التحقق إن أردت (عادة verify ناجح يعني isVerify = true)
                    // self.handleVerificationStatus(isVerified: user.isVerify ?? true)

                    // أعِد العلم profileCompleted لتقرر الواجهة هل تنتقل لإكمال البيانات
                    onsuccess(profileCompleted, user.token ?? "")
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func resend(params: [String: Any], onsuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.resend(params: params)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .receive(on: DispatchQueue.main)
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

        // إذا لا يوجد userID، نفّذ تسجيل خروج محلياً
        guard let userID = userSettings.id, !userID.isEmpty else {
            DispatchQueue.main.async {
                self.userSettings.logout()
                self.isLoading = false
                onsuccess()
            }
            return
        }

        let endpoint = DataProvider.Endpoint.logout(userID: userID)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self)
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
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
            .receive(on: DispatchQueue.main)
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
        // Perform the logout operation if needed
    }
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
