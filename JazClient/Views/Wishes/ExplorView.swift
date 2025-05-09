//
//  ExplorView.swift
//  Wishy
//
//  Created by Karim Amsha on 13.06.2024.
//

import SwiftUI

struct ExplorView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = WishesViewModel(errorHandling: ErrorHandling())

    var body: some View {
        VStack {
            if viewModel.explor.isEmpty {
                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(viewModel.explor, id: \.self) { item in
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
                                appRouter.navigate(to: .explorWishView(item.id ?? ""))
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Text(LocalizedStringKey.explor)
                        .customFont(weight: .bold, size: 18)
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
    ExplorView()
}

extension ExplorView {
    func loadData() {
        viewModel.explor.removeAll()
        viewModel.getExplor(page: 0, limit: 10)
    }
    
    func loadMore() {
        viewModel.loadMoreExplor(limit: 10)
    }
}
