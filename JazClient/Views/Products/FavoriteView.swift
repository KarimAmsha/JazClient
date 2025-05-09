//
//  FavoriteView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct FavoriteView: View {
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoading {
                LoadingView()
            }
            
            VStack(alignment: .center, spacing: 12) {
                ScrollView(showsIndicators: false) {
                    if viewModel.favoriteItems.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.favoriteItems, id: \.id) { favoriteItem in
                                if let product = favoriteItem.productId {
                                    ProductItemView(item: product, onSelect: {
                                        appRouter.navigate(to: .productDetails(product.id ?? ""))
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
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text(LocalizedStringKey.favourite)
                    .customFont(weight: .bold, size: 20)
                    .foregroundColor(Color.primaryBlack())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
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
            loadData()
        }
    }
}

#Preview {
    FavoriteView(viewModel: InitialViewModel(errorHandling: ErrorHandling()))
}

extension FavoriteView {
    func loadData() {
        viewModel.favoriteItems.removeAll()
        viewModel.getFavorite(page: 0, limit: 10)
    }
    
    func loadMore() {
        viewModel.loadMoreFavorite(limit: 10)
    }
}


