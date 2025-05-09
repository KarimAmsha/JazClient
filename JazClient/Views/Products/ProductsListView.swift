//
//  ProductsListView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct ProductsListView: View {
    @ObservedObject var viewModel: InitialViewModel
    @EnvironmentObject var appRouter: AppRouter
    @State var selectedIndex = 0
    let specialCategory: Category?
    @State var searchText = ""
    @State var selectedCategory: MainCategory?
    @State var params: [String: Any] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SearchBar(text: $searchText)
                    .onChange(of: searchText) { newValue in
                        if newValue.count >= 2 || newValue.isEmpty {
                            loadData()
                        }
                    }
                
                Button {
                    appRouter.navigate(to: .notifications)
                } label: {
                    Image("ic_bell")
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizedStringKey.publicCategories)
                    .customFont(weight: .bold, size: 16)
                    .foregroundColor(.primaryBlack())

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if let items = viewModel.mainCategoryItems {
                            ForEach(items.indices, id: \.self) { index in
                                let item = items[index]
                                MainCategoryItemView(item: item, isSelected: selectedCategory?.id == item.id) {
                                    selectedCategory = item
                                    loadData()
                                }
                            }
                        }
                    }
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

                    Text(specialCategory?.localizedName ?? "")
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
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
            getMainCategories()
            loadData()
        }
    }
}

#Preview {
    ProductsListView(viewModel: InitialViewModel(errorHandling: ErrorHandling()), specialCategory: nil)
}

extension ProductsListView {
    func getMainCategories() {
        viewModel.getMainCategories(q: nil)
    }
    
    func loadData() {
        viewModel.products.removeAll()
        params = [
            "isOffer": false,
            "category_id": selectedCategory?.id ?? "", 
            "special_id": specialCategory?.id ?? "",
            "q": searchText,
            "from_user": false,
        ]
        viewModel.getProducts(page: 0, limit: 10, params: params)
    }
    
    func loadMore() {
        viewModel.loadMoreProducts(limit: 10, params: params)
    }
}


