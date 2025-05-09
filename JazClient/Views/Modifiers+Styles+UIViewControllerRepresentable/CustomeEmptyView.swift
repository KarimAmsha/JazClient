//
//  CustomeEmptyView.swift
//  Wishy
//
//  Created by Karim Amsha on 19.06.2024.
//

import SwiftUI

struct CustomeEmptyView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("ic_logo")
                
                Text(LocalizedStringKey.pleaseLogin)
                    .customFont(weight: .bold, size: 18)
                    .foregroundColor(.black121212())

                Button {
                    settings.logout()
                    appState.currentPage = .home
                } label: {
                    HStack {
                        Text(LocalizedStringKey.goToLogin)
                    }
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .primary1(), foreground: .white, height: 48, radius: 8))
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    CustomeEmptyView()
        .environmentObject(UserSettings())
        .environmentObject(AppState())
}
