//
//  OrderViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 26.05.2024.
//

import SwiftUI
import Combine
import FirebaseDatabase

class OrderViewModel: ObservableObject {
    
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var isFetchingMoreData = false
    @Published var pagination: Pagination?
    @Published var orders: [OrderModel] = []
    @Published var order: OrderModel?
    @Published var orderId: AddOrderItem?
    @Published var orderBody: OrderBody?
    private let errorHandling: ErrorHandling
    private let dataProvider = DataProvider.shared
    @Published var errorMessage: String?
    @Published var userSettings = UserSettings.shared
    @Published var isLoading: Bool = false
    @Published var coupon: Coupon?
    private var cancellables = Set<AnyCancellable>()
    @Published var tamaraCheckout: TamaraCheckoutData?
    private var orderListenerHandle: DatabaseHandle?
    private var orderRealtimeRef: DatabaseReference?
    var orderListeners: [String: DatabaseHandle] = [:]
    var orderRefs: [String: DatabaseReference] = [:]

    init(errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    var shouldLoadMoreData: Bool {
        guard let totalPages = pagination?.totalPages else {
            return false
        }
        
        return currentPage < totalPages
    }

    func addOrder(params: [String: Any], onsuccess: @escaping (String, String) -> Void) {
        print("addOrder(params:) CALLED")
        guard let token = userSettings.token else {
            print("Token MISSING")
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addOrder(params: params, token: token)
        print("endpoint ready:", endpoint)

        dataProvider.sendDataToAPI(
            endpoint: endpoint,
            responseType: AddOrderResponse.self
        ) { [weak self] result in
            print("sendDataToAPI CALLBACK", result)
            self?.isLoading = false
            switch result {
            case .success(let response):
                print("response:", response)
                if response.status, let item = response.items {
                    self?.orderId = item
                    self?.errorMessage = nil
                    onsuccess(item.id, response.message)
                } else {
                    self?.handleAPIError(.customError(message: response.message))
                }
            case .failure(let error):
                self?.handleAPIError(error)
            }
        }
    }

    func getOrders(status: String?, page: Int?, limit: Int?) {
        guard let token = userSettings.token else {
            handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isFetchingMoreData = true
        errorMessage = nil

        let endpoint = DataProvider.Endpoint.getOrders(status: status, page: page, limit: limit, token: token)

        dataProvider.request(endpoint: endpoint, responseType: OrderResponse.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isFetchingMoreData = false

            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    if let items = response.items {
                        self.orders.append(contentsOf: items)
                        self.totalPages = response.pagination?.totalPages ?? 1
                        self.pagination = response.pagination
                    }
                    self.errorMessage = nil
                } else {
                    // Handle API error and update UI
                    handleAPIError(.customError(message: response.message ?? ""))
                    isFetchingMoreData = false
                }
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }

    func loadMoreOrders(status: String?, limit: Int?) {
        guard !isFetchingMoreData, currentPage < totalPages else {
            // Don't fetch more data while a request is already in progress or no more pages available
            return
        }

        currentPage += 1
        getOrders(status: status, page: currentPage, limit: limit)
    }
    
    func getOrderDetails(orderId: String, onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.getOrderDetails(orderId: orderId, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<OrderBody>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                if response.status {
                    self.orderBody = response.items
                    self.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
                self.isFetchingMoreData = false
            }
        }
    }
    
    func updateOrderStatus(orderId: String, params: [String: Any], onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }

        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.updateOrderStatus(orderId: orderId, params: params, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<OrderModel>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self.errorMessage = nil
                    onsuccess()
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
            }
        }
    }
    
    func addReview(orderID: String, params: [String: Any], onsuccess: @escaping (String) -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.addReview(orderID: orderID, params: params, token: token)
        
        dataProvider.request(endpoint: endpoint, responseType: SingleAPIResponse<User>.self) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.status {
                    self.errorMessage = nil
                    onsuccess(response.message)
                } else {
                    // Use the centralized error handling component
                    self.handleAPIError(.customError(message: response.message))
                }
                self.isLoading = false
            case .failure(let error):
                // Use the centralized error handling component
                self.handleAPIError(error)
            }
        }
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
                    self?.coupon = response.items
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
    
    func tamaraCheckout(params: TamaraBody, onsuccess: @escaping () -> Void) {
        guard let token = userSettings.token else {
            self.handleAPIError(.customError(message: LocalizedStringKey.tokenError))
            return
        }
        
        isLoading = true
        errorMessage = nil
        let endpoint = DataProvider.Endpoint.tamaraCheckout(params: params.toDict() ?? [:], token: token)
        
        DataProvider.shared.request(endpoint: endpoint, responseType: TamaraCheckoutResponse.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // Use the centralized error handling component
                    self.handleAPIError(error)
                }
            }, receiveValue: { [weak self] (response: TamaraCheckoutResponse) in
                if response.status {
                    self?.tamaraCheckout = response.items
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

extension OrderViewModel {
    private func handleAPIError(_ error: APIClient.APIError) {
        let errorDescription = errorHandling.handleAPIError(error)
        errorMessage = errorDescription
    }
}

extension OrderViewModel {
    func startListeningOrderRealtime(orderId: String) {
        let ref = Database.database().reference().child("orders").child(orderId)
        self.orderRealtimeRef = ref
        self.orderListenerHandle = ref.observe(.value, with: { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict),
               let realtimeOrder = try? JSONDecoder().decode(OrderRealTime.self, from: jsonData) {
                DispatchQueue.main.async {
                    if var order = self?.orderBody {
                        order.status = realtimeOrder.status
                        // ... إذا فيه حقول ثانية ضيفها هنا
                        self?.orderBody = order
                    }
                }
            }
        })
    }

    func stopListeningOrderRealtime() {
        if let ref = orderRealtimeRef, let handle = orderListenerHandle {
            ref.removeObserver(withHandle: handle)
        }
        orderListenerHandle = nil
        orderRealtimeRef = nil
    }
}

extension OrderViewModel {
    func startRealtimeListeners() {
        // أوقف جميع الليسنرز القديمة أولاً
        stopRealtimeListeners()
        // أضف Listener لكل طلب جديد
        for order in orders {
            listenForOrderChange(orderId: order.id ?? "")
        }
    }

    func stopRealtimeListeners() {
        for (orderId, handle) in orderListeners {
            orderRefs[orderId]?.removeObserver(withHandle: handle)
        }
        orderListeners.removeAll()
        orderRefs.removeAll()
    }

    func listenForOrderChange(orderId: String) {
        guard !orderId.isEmpty else { return }
        let ref = Database.database().reference().child("orders").child(orderId)
        let handle = ref.observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let realtimeOrder = try? JSONDecoder().decode(OrderRealTime.self, from: jsonData)
            else { return }

            if let index = self?.orders.firstIndex(where: { $0.id == orderId }) {
                // فقط إذا تغيرت الحالة فعليًا
                if self?.orders[index].status != realtimeOrder.status {
                    self?.orders[index].status = realtimeOrder.status
                    // لو عندك خصائص أخرى ممكن تحدثها هنا...
                }
            }
        }
        orderListeners[orderId] = handle
        orderRefs[orderId] = ref
    }
}
