//
//  PaymentState.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI
import Combine

class PaymentState: ObservableObject {
    @Published var paymentSuccess: Bool = false
    @Published var errorTitle: String = LocalizedStringKey.error
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    private let errorHandling: ErrorHandling
    private let dataProvider = DataProvider.shared
    @Published var userSettings = UserSettings.shared
    @Published var walletDataItems: [WalletData] = []
    @Published var walletResponse: WalletResponse? = WalletResponse(items: nil, total: nil, last_date: nil, status_code: nil, message: nil, messageAr: nil, messageEn: nil, pagenation: nil)
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    @Published var user: User?
    @Published var coupon: Coupon?
    private var cancellables = Set<AnyCancellable>()
    
    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    // Add this method to update paymentSuccess property
    func updatePaymentSuccess(paymentSuccess: Bool, paymentError: String) {
        DispatchQueue.main.async {
            self.paymentSuccess = paymentSuccess
            if !paymentError.isEmpty {
                self.errorMessage = paymentError.localized
            }
        }
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }
    
//    func startCardPayment(amount: Double) {
//        PaymentManager.startCardPayment(
//            on: topMostViewController(),
//            configuration: simulatedPaymentConfiguration(amount: amount),
//            delegate: paymentDelegate
//        )
//    }
    
//    // Simulated: Replace this method with actual PaymentSDKConfiguration initialization
//    func simulatedPaymentConfiguration(amount: Double) -> PaymentSDKConfiguration {
//        let theme = PaymentSDKTheme.default
//        theme.logoImage = UIImage(named: "ic_logo")
//        theme.backgroundColor = .white
//        theme.buttonFontColor = .black
//        theme.backButtonColor = .black
//
//        return PaymentSDKConfiguration(profileID: "94514",
//                                       serverKey: "SKJN2DKWTD-JGLHWBTNWK-JKMJHJW2ZD",
//                                       clientKey: "CRKMQQ-R77P6T-BHV27Q-TV2RN2",
//                                       currency: "SAR",
//                                       amount: amount,
//                                       merchantCountryCode: "SA")
//                .cartDescription("Flowers")
//                .cartID("1234")
//                .screenTitle(LocalizedStringKey.addAccount)
//                .theme(theme)
//                .billingDetails(PaymentSDKBillingDetails(name: userSettings.user?.full_name ?? "",
//                                                         email: userSettings.user?.email ?? "",
//                                                         phone: userSettings.user?.phone_number ?? "",
//                                                         addressLine: userSettings.user?.address ?? "",
//                                                         city: "Riyad",
//                                                         state: "Riyad",
//                                                         countryCode: "sa",
//                                                         zip: "12345"))
//    }
//
    func topMostViewController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.windows.first!.rootViewController!
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}

extension PaymentState {
    func fetchWallet(page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getWallet(page: page, limit: limit, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: WalletResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("errorerrorerror \(error)")
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                    self.isFetchingMoreData = false
                }
            }, receiveValue: { [weak self] (response: WalletResponse) in
                guard let self = self else { return }
                isFetchingMoreData = false
                self.walletResponse = response
                if response.status_code == 200 {
                    if let items = response.items {
                        self.walletDataItems.append(contentsOf: items)
                        self.totalPages = response.pagenation?.totalPages ?? 1
                        self.pagination = response.pagenation
                    }
                    self.errorMessage = nil
                } else {
                    // Use the centralized error handling component
                    handleAPIError(.customError(message: response.message ?? ""))
                }
                self.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func loadMoreWalletItems(limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        fetchWallet(page: currentPage, limit: 10)
    }

    func addBalanceToWallet(params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addBalanceToWallet(params: params, token: token)
        
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
                    self?.user = response.items // The user object
                    self?.handleUserData()
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
    
    func checkCoupon(params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.checkCoupon(params: params, token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: SingleAPIResponse<Coupon>.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: SingleAPIResponse<Coupon>) in
                if response.status {
                    self?.coupon = response.items // The user object
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

extension PaymentState {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
    
    func handleUserData() {
        if let user = self.user {
            UserSettings.shared.login(user: user, id: user.id ?? "", token: user.token ?? "")
        }
    }
}
