//
//  SuccessView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct SuccessView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image("ic_success")
            Text(LocalizedStringKey.successPaymentTitle)
                .customFont(weight: .bold, size: 18)
                .foregroundColor(.black1F1F1F())

//            VStack {
//                Text(LocalizedStringKey.successPaymentMsg)
//                    .customFont(weight: .regular, size: 14)
//                
//                Text("Ahmed M Y Al-Azaiza!")
//                    .customFont(weight: .semiBold, size: 16)
//            }
//            .foregroundColor(.primaryBlack())

            VStack {
                Button {
                    withAnimation {
                        appRouter.navigateBack()
                        appState.currentPage = .home
                    }
                } label: {
                    Text(LocalizedStringKey.backToHome)
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))

                Button {
                    withAnimation {
                        appRouter.navigateBack()
                        appState.currentPage = .orders
                    }
                } label: {
                    Text(LocalizedStringKey.discoverCategories)
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryLight(), foreground: .primary(), height: 48, radius: 12))
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text(LocalizedStringKey.successPayment)
                    .customFont(weight: .bold, size: 18)
                    .foregroundColor(.primaryBlack())
            }       
        }
    }
}

#Preview {
    SuccessView()
        .environmentObject(AppState())
}
