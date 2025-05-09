//
//  CartView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct CartView: View {
    @State private var quantities: [Int] = Array(repeating: 1, count: 10)
    @State private var quantity: Int = 1
    @State var selectedItems: [String] = Array(repeating: "", count: 10)
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = CartViewModel(errorHandling: ErrorHandling())

    var isSelected: Bool {
        selectedItems.contains { $0 == "" }
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoadingView()
            }
            
            if let items = viewModel.cartItems, let results = items.results, results.isEmpty {
                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
            } else {
                ScrollView(showsIndicators: false) {
                    if let cartItems = viewModel.cartItems?.results {
                        ForEach(cartItems.indices, id: \.self) { index in
                            let item = cartItems[index]
                            CartItemView(item: item) { item in
                                deleteItemCartAlert(cartId: item.cartId ?? "")
                            } onQuantityChange: { updatedItem, newQuantity in
                                updateCartItems(cartId: updatedItem.cartId ?? "", qty: newQuantity)
                            }
                        }
                    }

                    HStack {
                        Text(LocalizedStringKey.total)
                        Spacer()
                        HStack {
                            Text(viewModel.cartItems?.finalTotal?.toString() ?? "")
                            Text(LocalizedStringKey.sar)
                        }
                    }
                    .customFont(weight: .bold, size: 14)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 14)
                    .foregroundColor(.primaryBlack())
                    .background(Color.grayEBF0FF().cornerRadius(4))
                    .roundedBackground(cornerRadius: 4, strokeColor: .grayD8E2FF(), lineWidth: 1)

                    VStack {
                        Button {
                            appRouter.navigate(to: .checkoutView(viewModel.cartItems))
                        } label: {
                            Text(LocalizedStringKey.completeYourPurchaseNow)
                        }
                        .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))

                        Button {
                            deleteCartAlert()
                        } label: {
                            Text(LocalizedStringKey.deleteCart)
                        }
                        .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.dangerLight(), foreground: .dangerDarker(), height: 48, radius: 12))
                    }
                }
            }
        }
        .padding(16)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text(LocalizedStringKey.cart)
                    .customFont(weight: .bold, size: 18)
                    .foregroundColor(.primaryBlack())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appRouter.navigate(to: .notifications)
                } label: {
                    Image("ic_bell")
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            getCartItems()
        }
    }    
}

#Preview {
    CartView()
}

extension CartView {
    func getCartItems() {
        viewModel.getCartItems()
    }
    
    func updateCartItems(cartId: String, qty: Int) {
        viewModel.updateCartItems(cartItems: [UpdateCart(cart_id: cartId, qty: qty)], onsuccess: {
            getCartItems()
        })
    }

    func deleteCartItem(cartId: String) {
        let params: [String: Any] = ["cart_id": cartId]
        viewModel.deleteCartItem(params: params, onsuccess: {
            getCartItems()
        })
    }

    private func deleteItemCartAlert(cartId: String) {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.delete,
                                    message: LocalizedStringKey.deleteCartItemConfirmation,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.delete,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: false) {
            deleteCartItem(cartId: cartId)
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        
        appRouter.togglePopup(.alert(alertModel))
    }

    func deleteCart() {
        viewModel.deleteCart(onsuccess: {
            getCartItems()
            viewModel.cartCount {
                //
            }
        })
    }
    
    private func deleteCartAlert() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.deleteCart,
                                    message: LocalizedStringKey.deleteCartConfirmation,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.delete,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: false) {
            deleteCart()
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        
        appRouter.togglePopup(.alert(alertModel))
    }
}

