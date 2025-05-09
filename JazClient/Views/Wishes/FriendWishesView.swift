//
//  FriendWishesView.swift
//  Wishy
//
//  Created by Karim Amsha on 1.05.2024.
//

import SwiftUI

struct FriendWishesView: View {
    @EnvironmentObject var appRouter: AppRouter
    let user: User?
    @StateObject var wishViewModel = WishesViewModel(errorHandling: ErrorHandling())
    @State var params: [String: Any] = [:]

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .center, spacing: 8) {
                        AsyncImageView(
                            width: 57,
                            height: 57,
                            cornerRadius: 8,
                            imageURL: user?.image?.toURL(),
                            placeholder: Image(systemName: "photo"),
                            contentMode: .fill
                        )

                        Text(user?.full_name ?? "")
                            .customFont(weight: .bold, size: 14)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color.primary().cornerRadius(4))
                    .padding(6)
                    .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 16)], spacing: 8) {
                            ForEach(wishViewModel.groups, id: \.self) { item in
                                VStack(spacing: 8) {
                                    if let items = item.items, !items.isEmpty {
                                        LazyHStack(spacing: 8) {
                                            ForEach(items.prefix(4), id: \.self) { product in
                                                if let imageURLString = product.image, let imageURL = URL(string: imageURLString) {

                                                    AsyncImageView(
                                                        width: 65,
                                                        height: 65,
                                                        cornerRadius: 10,
                                                        imageURL: imageURL,
                                                        placeholder: Image(systemName: "photo"),
                                                        contentMode: .fill
                                                    )
                                                    .cornerRadius(4)
                                                    .padding(6)
                                                }
                                            }
                                        }
                                        .frame(height: 80)
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                            .padding(6)
                                    }

                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text(item.name ?? "")
                                                .customFont(weight: .bold, size: 14)
                                                .foregroundColor(.primaryBlack())

                                            Text(item.formattedCreateDate ?? "")
                                                .customFont(weight: .bold, size: 14)
                                                .foregroundColor(.primary())
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                }
                                .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
                                .onTapGesture {
                                    appRouter.navigate(to: .userWishes(user?.id ?? "", item.id ?? ""))
                                }
                            }
                        }
                        
                        if wishViewModel.shouldLoadMoreData {
                            Color.clear.onAppear {
                                loadMoreGroups()
                            }
                        }
                        
                        if wishViewModel.isFetchingMoreData {
                            LoadingView()
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey.retailSystem)
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.primaryBlack())
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(wishViewModel.wishes, id: \.self) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        AsyncImageView(
                                            width: 70,
                                            height: 70,
                                            cornerRadius: 5,
                                            imageURL: item.product_id?.image?.toURL(),
                                            placeholder: Image(systemName: "photo"),
                                            contentMode: .fill
                                        )

                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(item.product_id?.name ?? "")
                                                Spacer()
                                                HStack {
                                                    Text(String(format: "%.2f", item.product_id?.sale_price ?? 0))
                                                    Text(LocalizedStringKey.sar)
                                                }
                                            }
                                            .customFont(weight: .bold, size: 16)
                                            .foregroundColor(.primaryBlack())
                                            
                                            HStack {
                                                HStack {
                                                    Text(item.all_pays?.toString() ?? "")
                                                    Text(LocalizedStringKey.sar)
                                                }
                                                Spacer()
                                                HStack {
                                                    Text(item.pays?.count.toString())
                                                    Text("مساهم")
                                                }
                                            }
                                            .customFont(weight: .semiBold, size: 12)
                                            .foregroundColor(.primary())
                                            
                                            var percentage: Double {
                                                item.all_pays?.percentage(of: item.total ?? 0.0) ?? 0.0
                                            }

                                            ProgressLineView(percentage: percentage)
                                                .frame(height: 10)
                                        }
                                    }
                                    
                                    CustomDivider()
                                }
                                .onTapGesture {
                                    appRouter.navigate(to: .retailPaymentView(item.id ?? ""))
                                }
                            }
                            
                            if wishViewModel.shouldLoadMoreData {
                                Color.clear.onAppear {
                                    loadMoreWishes()
                                }
                            }
                            
                            if wishViewModel.isFetchingMoreData {
                                LoadingView()
                            }
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
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text(LocalizedStringKey.friendWishes)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onAppear {
            loadWishData()
            loadGroupsData()
        }
    }
}

#Preview {
    FriendWishesView(user: nil)
}

extension FriendWishesView {
    func loadWishData() {
        wishViewModel.wishes.removeAll()
        params = ["user_id": user?.id ?? "",
                 "group_id": "",
                 "isShare": true,
        ]
        wishViewModel.getUserWishes(page: 0, limit: 10, params: params)
    }
    
    func loadMoreWishes() {
        wishViewModel.loadMoreWishs(limit: 10, params: params)
    }
    
    func loadGroupsData() {
        wishViewModel.groups.removeAll()
        wishViewModel.getWishGroups(page: 0, limit: 10, user_id: user?.id ?? "")
    }
    
    func loadMoreGroups() {
        wishViewModel.loadMoreGroups(limit: 10, user_id: user?.id ?? "")
    }
}
