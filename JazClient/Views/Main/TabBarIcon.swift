//
//  TabBarIcon.swift
//  Wishy
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI

struct TabBarIcon: View {
    
    @StateObject var appState: AppState
    let assignedPage: Page
    @ObservedObject private var settings = UserSettings()

    let width, height: CGFloat
    let iconName, tabName: String
    @State var count: Int?
    let isNotified: Bool?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if isNotified ?? false && count != 0 {
                    Text(count?.toString() ?? "")
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .padding(.leading, 20)
                        .padding(.bottom, 60)
                }
                
                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(appState.currentPage == assignedPage ? .primary() : .gray6C7278())
                        .frame(width: 28, height: 28)
                    
                    Text(tabName)
                        .customFont(weight: appState.currentPage == assignedPage ? .bold : .regular, size: 12)
                        .foregroundColor(appState.currentPage == assignedPage ? .primary() : .primaryBlack())
                }
            }
        }
        .onTapGesture {
            appState.currentPage = assignedPage
        }
    }
}

#Preview {
    TabBarIcon(appState: AppState(), assignedPage: .home, width: 38, height: 38, iconName: "ic_home", tabName: LocalizedStringKey.home, count: 0, isNotified: false)
}

