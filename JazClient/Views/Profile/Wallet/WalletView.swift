//
//  WalletView.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = PaymentState(errorHandling: ErrorHandling())
    @State private var showAddBalanceView = false
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack {
                            Image("ic_wallet_bg")
                                .renderingMode(.template)
                                .resizable()
                                .frame(maxWidth: .infinity)
                                .frame(height: 169)
                                .cornerRadius(16)
                                .foregroundColor(.primary())

                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey.myWallet)
                                    .customFont(weight: .bold, size: 18)
                                  .foregroundColor(Color.white)
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(LocalizedStringKey.lastTransaction)
                                            .customFont(weight: .bold, size: 14)
                                          .foregroundColor(Color.white)
                                        if let lastDate = viewModel.walletResponse?.last_date {
                                            let formattedDate = lastDate.formattedDateString(with: "yyyy-MM-dd")
                                            Text(formattedDate ?? "Invalid date")
                                                .customFont(weight: .bold, size: 14)
                                              .foregroundColor(Color.white)
                                        }
                                    }
                                    Spacer()
                                    HStack {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocalizedStringKey.totalAccount)
                                                .customFont(weight: .bold, size: 14)
                                                .foregroundColor(Color.white)
                                            Text("\(LocalizedStringKey.sar) \(viewModel.walletResponse?.total?.toString() ?? "")")
                                                .customFont(weight: .bold, size: 16)
                                                .foregroundColor(Color.white)
                                        }
                                    }
                                }
                            }
                            .padding(24)
                        }
                        
                        Text(LocalizedStringKey.finicialTransactions)
                            .customFont(weight: .bold, size: 14)
                          .foregroundColor(Color.black141F1F())
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(viewModel.walletDataItems, id: \.self) { item in
                                TransactionsRowiew(item: item)
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

                        Spacer()
                    }
                    .frame(minWidth: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                }
            }
            
            HStack {
                Button(action: {
                    withAnimation {
                        showAddBalanceView.toggle()
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .fontWeight(.bold)
                        Text(LocalizedStringKey.addAccount)
                            .customFont(weight: .bold, size: 10)
                            .foregroundColor(.white)
                    }
                    .foregroundColor(.white)
                }
                .frame(width: 68, height: 68)
                .background(Color.primary())
                .clipShape(Circle())
                .scaleEffect(showAddBalanceView ? 1.2 : 1.0)
                .padding(.top, 32)

                Spacer()
            }
        }
        .padding(24)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        withAnimation {
                            appRouter.navigateBack()
                        }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: 20, height: 15)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white.clipShape(Circle()))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.wallet)
                            .customFont(weight: .bold, size: 20)
                        Text(LocalizedStringKey.walletHit)
                            .customFont(weight: .regular, size: 10)
                    }
                    .foregroundColor(Color.black222020())
                }
            }
        }
        .navigationDestination(isPresented: $showAddBalanceView, destination: {
            AddBalanceView(showAddBalanceView: $showAddBalanceView, onsuccess: {
                
            })
        })
        .onAppear {
            loadData()
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
}

#Preview {
    WalletView()
}

extension WalletView {
    func loadData() {
        viewModel.walletDataItems.removeAll()
        viewModel.fetchWallet(page: 0, limit: 10)
    }
    
    func loadMore() {
        viewModel.loadMoreWalletItems(limit: 10)
    }
}
