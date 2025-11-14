// ✅ MyOrdersView مع الخطوط المخصصة والشكل كما هو في الصورة

import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State var orderType: OrderStatus = .new
    @State private var searchText: String = ""

    var filteredOrders: [OrderModel] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return viewModel.orders
        }
        return viewModel.orders.filter {
            $0.order_no?.localizedCaseInsensitiveContains(searchText) == true ||
            $0.id?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // ✅ شريط الحالات
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    OrderStatusButton(title: "الطلبات الجديدة", status: .new, selectedStatus: $orderType)
                    OrderStatusButton(title: "طلبات قيد التنفيذ", status: .started, selectedStatus: $orderType)
                    OrderStatusButton(title: "في الطريق", status: .way, selectedStatus: $orderType)
                    OrderStatusButton(title: "بانتظار التأكيد", status: .prefinished, selectedStatus: $orderType)
                    OrderStatusButton(title: "مكتملة", status: .finished, selectedStatus: $orderType)
                    OrderStatusButton(title: "ملغية", status: .canceled, selectedStatus: $orderType)
                }
                .padding(.horizontal, 6)
            }

            // ✅ شريط البحث
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("البحث برقم الطلب", text: $searchText)
                    .customFont(weight: .medium, size: 15)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.gray.opacity(0.07))
            .cornerRadius(12)

            // ✅ الطلبات
            ScrollView(showsIndicators: false) {
                if filteredOrders.isEmpty {
                    DefaultEmptyView(title: "لا توجد طلبات")
                } else {
                    VStack(spacing: 14) {
                        ForEach(filteredOrders.indices, id: \.self) { index in
                            let item = filteredOrders[index]
                            OrderItemView(item: item) {
                                appRouter.navigate(to: .orderDetails(item.id ?? ""))
                            }
                        }
                        if viewModel.isFetchingMoreData {
                            LoadingView()
                        }
                    }
                }
            }
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("طلباتي")
                    .customFont(weight: .bold, size: 20)
            }
        }
        .onChange(of: orderType) { _ in loadData() }
        .onAppear { loadData() }
        // .onDisappear { viewModel.stopRealtimeListeners() } // 🔴 الريل تايم معلق
        /*
        .onReceive(viewModel.$orders) { newOrders in
            let visibleOrders = Array(newOrders.prefix(10))
            viewModel.startRealtimeListenersForVisibleOrders(visibleOrders)
        }
        */
        .onReceive(viewModel.$orders) { orders in
            if let changedOrder = orders.first(where: { $0.status != orderType.rawValue }),
               let newStatus = OrderStatus(rawValue: changedOrder.status ?? "") {
                orderType = newStatus
            }
        }
    }
}


#Preview {
    MyOrdersView()
}

extension MyOrdersView {
    func loadData() {
        viewModel.currentPage = 0
        viewModel.orders.removeAll()
        viewModel.getOrders(status: orderType.rawValue, page: 0, limit: 10)
    }

    func loadMore() {
        viewModel.loadMoreOrders(status: orderType.rawValue, limit: 10)
    }
    
    private func updateOrderStatus(orderID: String, status: OrderStatus, canceledNote: String = "") {
        let params: [String: Any] = [
            "status": status.rawValue,
            "canceled_note": canceledNote
        ]
        
        viewModel.updateOrderStatus(orderId: orderID, params: params, onsuccess: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                loadData()
            })
        })
    }
}
