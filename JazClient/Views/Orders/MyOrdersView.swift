//
//  MyOrdersView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct MyOrdersView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State var orderType: OrderStatus = .new

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        OrderStatusButton(title: LocalizedStringKey.news, status: .new, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.started, status: .started, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.underway, status: .way, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.unconfirmed, status: .prefinished, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.finished, status: .finished, selectedStatus: $orderType)
                        OrderStatusButton(title: LocalizedStringKey.canceled, status: .canceled, selectedStatus: $orderType)
                    }
                    .frame(maxWidth: .infinity) // Ensure the HStack takes up all available width
                }
                .background(Color.white.cornerRadius(8))
                .frame(height: 60)

                ScrollView(showsIndicators: false) {
                    if viewModel.orders.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noOrdersFound)
                    } else {
                        let orders = viewModel.orders
                        ForEach(orders.indices, id: \.self) { index in
                            let item = orders[index]
                            OrderItemView(item: item, onSelect: {
                                appRouter.navigate(to: .orderDetails(item.id ?? ""))
                            })
                        }
                    }
                    
                    if viewModel.shouldLoadMoreData {
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
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

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

