//
//  UserWishesView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct UserWishesView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = WishesViewModel(errorHandling: ErrorHandling())
    let userId: String?
    let group_id: String?
    @State var params: [String: Any] = [:]
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if viewModel.wishes.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.wishes, id: \.self) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    AsyncImageView(
                                        width: 150,
                                        height: 150,
                                        cornerRadius: 10,
                                        imageURL: item.product_id?.image?.toURL(),
                                        placeholder: Image(systemName: "photo"),
                                        contentMode: .fill
                                    )
                                    .cornerRadius(4)
                                    .padding(.horizontal, 6)
                                    
                                    Text(item.product_id?.name ?? "" )
                                        .customFont(weight: .bold, size: 16)
                                        .foregroundColor(.primaryBlack())
                                        .padding(.horizontal, 6)
                                    
                                    VStack(spacing: 4) {
                                        RatingView(rating: .constant(item.product_id?.rate?.toInt() ?? 0))
                                        HStack {
                                            Text(String(format: "%.2f", item.product_id?.sale_price ?? 0))
                                            Text(LocalizedStringKey.sar)
                                        }
                                        .customFont(weight: .semiBold, size: 14)
                                        .foregroundColor(.primary())
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 16)
                                }
                                .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
                                .onTapGesture {
                                    if userId == UserSettings.shared.id {
                                        appRouter.navigate(to: .myWishView(item.id ?? ""))
                                    } else {
                                        appRouter.navigate(to: .friendWishesDetailsView(item.id ?? ""))
                                    }
                                }
                            }
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
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }
                    
                    Text(LocalizedStringKey.wishes)
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
            loadData()
        }
    }
}

#Preview {
    UserWishesView(userId: "", group_id: "")
}

extension UserWishesView {
    func loadData() {
        viewModel.wishes.removeAll()
        params = ["user_id": userId ?? "",
                 "group_id": group_id ?? "",
                 "isShare": true,
        ]
        viewModel.getUserWishes(page: 0, limit: 10, params: params)
    }
    
    func loadMore() {
        viewModel.loadMoreWishs(limit: 10, params: params)
    }
}
