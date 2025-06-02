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

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(appState.currentPage == assignedPage ? .blue : .gray6C7278())
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
    TabBarIcon(appState: AppState(), assignedPage: .home, width: 38, height: 38, iconName: "ic_home", tabName: LocalizedStringKey.home)
}

enum TabItem2 {
    case profile, orders, jaz, services, home
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem2

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    tabBarButton(image: "square.grid.2x2.fill", title: "الرئيسية", tab: .home)
                    tabBarButton(image: "headphones", title: "خدماتي", tab: .services)

                    Spacer().frame(width: 50) // space for center button
                    
                    tabBarButton(image: "shippingbox.fill", title: "طلباتي", tab: .orders)
                    tabBarButton(image: "person.fill", title: "الملف الشخصي", tab: .profile)
                }
                .padding(.horizontal, 10)
                .frame(height: 60)
//                .background(Color.white.shadow(radius: 4))

                // Center Button
                Button(action: {
                    selectedTab = .jaz
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 65, height: 65)
                            .shadow(radius: 4)

                        Text("JAZ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -30)
            }
        }
        .frame(height: 80)
    }

    func tabBarButton(image: String, title: String, tab: TabItem2) -> some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tab ? .cyan() : .gray)

                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? .cyan() : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
