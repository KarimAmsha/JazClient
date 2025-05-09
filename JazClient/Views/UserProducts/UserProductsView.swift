//
//  UserProductsView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct UserProductsView: View {
    @ObservedObject var viewModel: InitialViewModel
    @EnvironmentObject var appRouter: AppRouter
    let id: String
    @State var searchText = ""
    @State var params: [String: Any] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SearchBar(text: $searchText)
                
                Button {
                    appRouter.navigate(to: .notifications)
                } label: {
                    Image("ic_bell")
                }
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
            
            VStack(alignment: .center, spacing: 12) {
                ScrollView(showsIndicators: false) {
                    if viewModel.products.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.products, id: \.id) { item in
                                ProductItemView(item: item, onSelect: {
                                    appRouter.navigate(to: .productDetails(item.id ?? ""))
                                })
                                
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
            }

            Spacer()
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

                    Text(LocalizedStringKey.userProducts)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appRouter.navigate(to: .addUserProduct)
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.primaryDark(), Color.primaryLight())
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
    UserProductsView(viewModel: InitialViewModel(errorHandling: ErrorHandling()), id: "")
}

extension UserProductsView {
    func loadData() {
        viewModel.products.removeAll()
        params = [
            "isOffer": false,
            "category_id": "",
            "special_id": id,
            "q": searchText,
            "from_user": true,
        ]
        viewModel.getProducts(page: 0, limit: 10, params: params)
    }
    
    func loadMore() {
        viewModel.loadMoreProducts(limit: 10, params: params)
    }
}


