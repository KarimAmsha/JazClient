//
//  HomeView.swift
//  Wishy
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI
import SkeletonUI
import RefreshableScrollView
import FirebaseMessaging

struct HomeView: View {
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter
    @State private var searchText: String = ""
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("المشاريع الفعالة")
                        .font(.system(size: 16, weight: .bold))
                    
                    GeneralCardView(
                        title: "تصميم بروشور شركة",
                        rating: 4.8,
                        reviewer: "محمد سعيد",
                        completedProjects: 100,
                        price: "$160",
                        date: "٢٧ أكتوبر 2024",
                        status: "قيد التنفيذ"
                    )
                }

                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("البحث بالتخصص")
                                .font(.system(size: 16, weight: .bold))
                                .padding(.horizontal)

                            if let categories = viewModel.homeItems?.category, categories.isEmpty {
                                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                            } else if let categories = viewModel.homeItems?.category {
                                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 2), spacing: 16) {
                                    ForEach(sampleCategories) { category in
                                        VStack {
                                            Image(category.image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                            Text(category.title)
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("+1500 فريلانسر")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        .onTapGesture {
                                            appRouter.navigate(to: .freelancerList)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(minHeight: geometry.size.height)
        }
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    AsyncImageView(
                        width: 60,
                        height: 60,
                        cornerRadius: 10,
                        imageURL: UserSettings.shared.user?.image?.toURL(),
                        placeholder: Image(systemName: "person.fill"),
                        contentMode: .fill
                    )
                    
                    
                    VStack(alignment: .leading) {
                        Text("مرحباً أحمد! 👋")
                            .customFont(weight: .bold, size: 20)
                        Text("UXUI Designer")
                            .customFont(weight: .regular, size: 10)
                    }
                    .foregroundColor(Color.black222020())
                }
            }
        }
        .onAppear {
            getHome()
            viewModel.fetchContactItems()
            refreshFcmToken()
        }
    }
    
    func openWhatsApp() {
        let phoneNumber = viewModel.whatsAppContactItem?.Data ?? ""
        
        if let url = URL(string: "https://wa.me/\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    HomeView()
}

extension HomeView {
    func getHome() {
        viewModel.fetchHomeItems()
    }
}

extension HomeView {
    func refreshFcmToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
            } else if let token = token {
                let params: [String: Any] = [
                    "id": UserSettings.shared.id ?? "",
                    "fcmToken": token
                ]
                userViewModel.refreshFcmToken(params: params, onsuccess: {
                    
                })
            }
        }
    }
}

struct Category2: Identifiable {
    let id = UUID()
    let title: String
    let image: String
}
let sampleCategories: [Category2] = [
    .init(title: "التصميم", image: "design_image"),
    .init(title: "المجال المالي", image: "finance_image"),
    .init(title: "المجال الطبي", image: "medical_image"),
    .init(title: "التدريس", image: "teaching_image")
]
