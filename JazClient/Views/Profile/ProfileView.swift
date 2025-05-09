//
//  ProfileView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject private var authViewModel = AuthViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Card
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary())
                            .frame(height: 80)
                        HStack {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("قد سعيد")
                                    .foregroundColor(.white)
                                    .bold()
                                Text("100 مشروع مكتمل")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                            Spacer()
                            Image("profile")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal)

                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding(8)
                    }
                    .padding(.horizontal)

                    // Settings List
                    VStack(spacing: 0) {
                        settingsRow(title: "أرباحي", icon: "bag") {
                            appRouter.navigate(to: .earningsView)
                        }

                        settingsRow(title: "الإشعارات", icon: "bell") {
                            appRouter.navigate(to: .notificationsSettings)
                        }

                        settingsRow(title: "إعدادات الحساب", icon: "gearshape") {
                            appRouter.navigate(to: .accountSettings)
                        }

                        settingsRow(title: "المساعدة", icon: "questionmark.bubble") {
                            appRouter.navigate(to: .editProfile)
                        }
                        settingsRow(title: "تسجيل الخروج", icon: "rectangle.portrait.and.arrow.right") {
                            appRouter.navigate(to: .editProfile)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
//        .tabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading) {
                    Text("الزيد 🚗")
                        .customFont(weight: .bold, size: 20)
                    Text("الإعدادات والتحكم بتفاصيل الحساب!")
                        .customFont(weight: .regular, size: 10)
                }
                .foregroundColor(Color.black222020())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
        .onAppear {
            getConstants()
        }
    }
    
    @ViewBuilder
    func settingsRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.left")
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle()) // لإزالة تأثير الزر الأزرق
    }
}

//// Dummy tab bar extension
//extension View {
//    func tabBar() -> some View {
//        VStack(spacing: 0) {
//            self
//            Divider()
//            HStack {
//                tabItem(title: "الرئيسية", systemImage: "house")
//                tabItem(title: "الرسائل", systemImage: "bubble.left")
//                tabItem(title: "إضافة خدمة", systemImage: "plus")
//                tabItem(title: "المشاريع", systemImage: "briefcase")
//                tabItem(title: "الزيد", systemImage: "ellipsis")
//            }
//            .padding(.vertical, 8)
//            .background(Color.white)
//        }
//    }
//
//    func tabItem(title: String, systemImage: String) -> some View {
//        VStack(spacing: 4) {
//            Image(systemName: systemImage)
//            Text(title).font(.caption2)
//        }
//        .frame(maxWidth: .infinity)
//        .foregroundColor(.black)
//    }
//}
//
#Preview {
    ProfileView()
        .environmentObject(AppRouter())
}

extension ProfileView {
    private func getConstants() {
        initialViewModel.fetchConstantsItems()
    }

    private func logout() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.logout,
                                    message: LocalizedStringKey.logoutMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.logout,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.logoutUser {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        
        appRouter.togglePopup(.alert(alertModel))
    }
    
    private func deleteAccount() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.deleteAccount,
                                    message: LocalizedStringKey.deleteAccountMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.deleteAccount,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.deleteAccount {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }
        
        appRouter.togglePopup(.alert(alertModel))
    }
}

