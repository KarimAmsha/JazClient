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
        return viewModel.orders.filter { order in
            // عدّل هنا للبحث في أي خاصية تريدها داخل OrderModel
            order.order_no?.localizedCaseInsensitiveContains(searchText) == true
            || order.id?.localizedCaseInsensitiveContains(searchText) == true
            // أو أضف خصائص مثل اسم العميل أو رقم الطلب ...
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // شريط الحالات
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        OrderStatusButton(title: LocalizedStringKey.news, status: .new, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.started, status: .started, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.way, status: .way, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.unconfirmed, status: .prefinished, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.finished, status: .finished, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.canceled, status: .canceled, selectedStatus: $orderType)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(Color.white.cornerRadius(8))
                .frame(height: 60)

                // شريط البحث
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("بحث في الطلبات...", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 8)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .padding(.vertical, 8)
                .animation(.default, value: searchText)

                ScrollView(showsIndicators: false) {
                    if filteredOrders.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noOrdersFound)
                    } else {
                        ForEach(filteredOrders.indices, id: \.self) { index in
                            let item = filteredOrders[index]
                            OrderItemView(item: item, onSelect: {
                                appRouter.navigate(to: .orderDetails(item.id ?? ""))
                            })
                        }
                    }

                    if viewModel.shouldLoadMoreData && searchText.isEmpty {
                        Color.clear.onAppear {
                            loadMore()
                        }
                    }

                    if viewModel.isFetchingMoreData {
                        LoadingView()
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Text(LocalizedStringKey.myOrders)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onChange(of: orderType) { type in
            loadData()
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            loadData()
            print("tttt \(UserSettings.shared.token)")
        }
        .onDisappear {
            viewModel.stopRealtimeListeners()
        }
        .onReceive(viewModel.$orders) { _ in
            viewModel.startRealtimeListeners()
        }
        .onReceive(viewModel.$orders) { orders in
            // إذا أي طلب خرج من التاب الحالي (حالة تغيرت)، انتقل للتاب الصحيح تلقائي
            if let changedOrder = orders.first(where: { $0.status != orderType.rawValue }) {
                if let newStatus = OrderStatus(rawValue: changedOrder.status ?? "") {
                    orderType = newStatus
                }
            }
        }
    }
}

#Preview {
    MyOrdersView()
}

extension MyOrdersView {
    func loadData() {
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
