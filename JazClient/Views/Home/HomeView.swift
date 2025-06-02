import SwiftUI
import FirebaseMessaging

struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject var locationManager = LocationManager.shared

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // MARK: - Slider (صورة ثابتة حالياً)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.7))
                        .frame(height: 120)
                        .padding(.horizontal)

                    // MARK: - Categories Grid
                    if let categories = viewModel.homeItems?.category, !categories.isEmpty {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories, id: \.id) { category in
                                VStack(spacing: 8) {
                                    AsyncImageView(
                                        width: 50,
                                        height: 50,
                                        cornerRadius: 10,
                                        imageURL: category.image?.toURL(),
                                        placeholder: Image(systemName: "photo"),
                                        contentMode: .fit
                                    )
                                    Text(category.localizedName)
                                        .font(.system(size: 13, weight: .medium))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity, minHeight: 90)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                                .onTapGesture {
                                    appRouter.navigate(to: .freelancerList)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - All Orders Button
                    Button(action: {
                        appRouter.navigate(to: .myOrders)
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.white)
                            Text("كل الطلبات")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.background())
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("الرئيسية")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            // إشعارات
                        }) {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                        }
                        Button(action: {
                            appRouter.navigate(to: .productsSearchView)
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .background(Color.background())
            .onAppear {
//                LocationManager.shared.getCurrentLocation { coordinate in
//                    guard let coordinate = coordinate else { return }
                    viewModel.fetchHomeItems(q: nil, lat: 18.2418308, lng: 42.4660169)
//                }
                refreshFcmToken()
            }
        }
    }
    
    func refreshFcmToken() {
        Messaging.messaging().token { token, error in
            if let token = token {
                let params: [String: Any] = [
                    "id": UserSettings.shared.id ?? "",
                    "fcmToken": token
                ]
                userViewModel.refreshFcmToken(params: params, onsuccess: {})
            }
        }
    }
}

#Preview {
    HomeView()
}
