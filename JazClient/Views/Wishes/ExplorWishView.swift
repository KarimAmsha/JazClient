//
//  ExplorWishView.swift
//  Wishy
//
//  Created by Karim Amsha on 16.06.2024.
//

import SwiftUI

struct ExplorWishView: View {
    @EnvironmentObject var appRouter: AppRouter
    let wishId: String?
    @ObservedObject var viewModel: InitialViewModel
    @ObservedObject var cartViewModel = CartViewModel(errorHandling: ErrorHandling())
    @ObservedObject var wishesViewModel = WishesViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    if viewModel.isLoading || wishesViewModel.isLoading {
                        LoadingView()
                    }
                    
                    if cartViewModel.isLoading {
                        LoadingView()
                    }

                    // ZStack to overlay favorite button on top of the image
                    ZStack(alignment: .topTrailing) {
                        AsyncImageView(
                            width: UIScreen.main.bounds.width,
                            height: 320,
                            cornerRadius: 10,
                            imageURL: wishesViewModel.wish?.product_id?.image?.toURL(),
                            placeholder: Image(systemName: "photo"),
                            contentMode: .fill
                        )
                        .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(wishesViewModel.wish?.product_id?.name ?? "")
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.primaryBlack())

                        HStack {
                            HStack {
                                Text(String(format: "%.2f", wishesViewModel.wish?.product_id?.sale_price ?? 0))
                                Text(LocalizedStringKey.sar)
                            }
                            .customFont(weight: .semiBold, size: 14)
                            .foregroundColor(.primary())
                            
                            Spacer()
                            
                            RatingView(rating: .constant(wishesViewModel.wish?.product_id?.rate?.toInt() ?? 0))
                        }
                        
                        HStack {
                            HStack {
                                Text(wishesViewModel.wish?.all_pays?.toString() ?? "")
                                Text(LocalizedStringKey.sar)
                            }
                            Spacer()
                            HStack {
                                Text(wishesViewModel.wish?.pays?.count.toString())
                                Text("مساهم")
                            }
                        }
                        .customFont(weight: .semiBold, size: 12)
                        .foregroundColor(.primary())
                        
                        var percentage: Double {
                            wishesViewModel.wish?.all_pays?.percentage(of: wishesViewModel.wish?.total ?? 0.0) ?? 0.0
                        }

                        ProgressLineView(percentage: percentage)
                            .frame(height: 10)
                        
                        Text(wishesViewModel.wish?.product_id?.description ?? "")
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.primaryBlack())
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()

            VStack {
                CustomDivider()
                
                let isShared = wishesViewModel.wish?.isShare ?? false
                
                Button {
                    if isShared {
                        appRouter.navigate(to: .retailPaymentView(wishId ?? ""))
                    } else {
                        addToCart()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image("ic_w_gift")
                        Text(isShared ? "ساهم بقطّة منك لتحقيق أمنية!" : LocalizedStringKey.addToCart)
                    }
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
                .padding(.horizontal, 16)
            }

        }
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

                    Text(wishesViewModel.wish?.product_id?.name ?? "")
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $wishesViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            laodWishData()
        }
    }
}

#Preview {
    ExplorWishView(wishId: "", viewModel: InitialViewModel(errorHandling: ErrorHandling()))
        .environmentObject(AppState())
}

extension ExplorWishView {
    func laodWishData() {
        wishesViewModel.getWish(id: wishId ?? "")
    }
    
    func addToCart() {
        let params: [String: Any] = [
            "product_id": wishesViewModel.wish?.product_id?.id ?? "",
            "qty": 1,
        ]
        cartViewModel.addToCart(params: params, onsuccess: {
            showMessage()
        })
        cartViewModel.cartCount {
            //
        }
    }
    
    private func showMessage() {
        let alertModel = AlertModel(
            icon: "",
            title: "",
            message: LocalizedStringKey.cartMessage,
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: false,
            onOKAction: {
                appRouter.togglePopup(nil)
                appRouter.navigateBack()
                appState.currentPage = .home
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.alert(alertModel))
    }
}
