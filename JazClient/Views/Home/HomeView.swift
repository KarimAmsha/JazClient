import SwiftUI
import FirebaseMessaging

struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject var locationManager = LocationManager.shared
    @Binding var selectedTab: TabItem2

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let fixedLat = 18.2418308
    let fixedLng = 42.4660169

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background()
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    // Centered ProgressView
                    VStack {
                        Spacer()
                        ProgressView("جارٍ تحميل البيانات...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .font(.system(size: 17, weight: .semibold))
                            .padding()
                            .background(Color.white.opacity(0.94))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.05), radius: 18, x: 0, y: 6)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.07).ignoresSafeArea())
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            // --- Slider ---
                            if let sliders = viewModel.homeItems?.slider, !sliders.isEmpty {
                                TabView {
                                    ForEach(sliders) { slide in
                                        SliderView(slider: slide)
                                    }
                                }
                                .tabViewStyle(.page)
                                .frame(height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal)
                            }

                            // --- Categories ---
                            if let categories = viewModel.homeItems?.category, !categories.isEmpty {
                                LazyVGrid(columns: columns, spacing: 18) {
                                    ForEach(categories, id: \.id) { category in
                                        Button(action: {
                                            appRouter.navigate(to: .services(category.id))
                                        }) {
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
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.primary)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 94)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color.white)
                                                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.06), radius: 4, y: 2)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            } else if !viewModel.isLoading {
                                // Empty State
                                VStack(spacing: 8) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 38))
                                        .foregroundColor(.gray.opacity(0.22))
                                    Text("لا توجد خدمات متاحة حالياً")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 38)
                            }

                            // --- All Orders Button ---
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
                                .background(Color.primary())
                                .cornerRadius(13)
                                .shadow(color: Color.primary().opacity(0.13), radius: 7, y: 4)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.top, 18)
                    }
                    .refreshable {
                        viewModel.fetchHomeItems(q: nil, lat: fixedLat, lng: fixedLng)
                        // --- إذا أردت الموقع الحقيقي مستقبلاً:
                        /*
                        LocationManager.shared.getCurrentLocation { coordinate in
                            guard let coordinate = coordinate else { return }
                            viewModel.fetchHomeItems(q: nil, lat: coordinate.latitude, lng: coordinate.longitude)
                        }
                        */
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("الرئيسية")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            appRouter.navigate(to: .notifications)
                        }) {
                            Image(systemName: "bell")
                                .foregroundColor(.primary)
                        }
                        Button(action: {
                            selectedTab = .services
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchHomeItems(q: nil, lat: fixedLat, lng: fixedLng)
                // إذا أردت استخدام اللوكيشن:
                /*
                LocationManager.shared.getCurrentLocation { coordinate in
                    guard let coordinate = coordinate else { return }
                    viewModel.fetchHomeItems(q: nil, lat: coordinate.latitude, lng: coordinate.longitude)
                }
                */

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
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppRouter())
        .environmentObject(AppState())
}
