import SwiftUI
import PopupView

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: UserSettings
    @State var showAddOrder = false
    @State private var path = NavigationPath()
    @ObservedObject var appRouter = AppRouter()
    @ObservedObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject var cartViewModel = CartViewModel(errorHandling: ErrorHandling())
    @State private var selectedTab: TabItem2 = .home

    var body: some View {
        NavigationStack(path: $appRouter.navPath) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.clear)
                    .background(.white)
                VStack(spacing: 0) {
                    Spacer()
                    mainTabContent
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color.background())
            .edgesIgnoringSafeArea(.bottom)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color.background(), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(appRouter)
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                navigationDestinationView(for: destination)
            }
            .popup(isPresented: Binding<Bool>(
                get: { appRouter.activePopup != nil },
                set: { _ in appRouter.togglePopup(nil) })
            ) {
                popupView
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .closeOnTap(false)
                    .backgroundColor(Color.black.opacity(0.80))
                    .isOpaque(true)
                    .useKeyboardSafeArea(true)
            }
            .popup(isPresented: Binding<Bool>(
                get: { appRouter.appPopup != nil },
                set: { _ in appRouter.toggleAppPopup(nil) })
            ) {
                appPopupView
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .animation(.spring())
                    .closeOnTapOutside(true)
                    .closeOnTap(false)
                    .backgroundColor(Color.black.opacity(0.80))
                    .isOpaque(true)
                    .useKeyboardSafeArea(true)
            }
        }
        .accentColor(.black)
        .environmentObject(appRouter)
    }
}

// MARK: - Main Tab Content

extension MainView {
    @ViewBuilder
    var mainTabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(selectedTab: $selectedTab)
        case .services:
            ServicesView(viewModel: viewModel, selectedCategoryId: nil)
        case .jaz:
            AddOrderView(
                viewModel: viewModel,
                userViewModel: UserViewModel(errorHandling: ErrorHandling()),
                locationManager: LocationManager.shared,
                selectedCategory: nil,
                selectedSubCategory: nil,
                cameFromMain: true
            )
        case .orders:
            MyOrdersView()
        case .profile:
            if settings.id == nil {
                CustomeEmptyView()
            } else {
                ProfileView()
            }
        }
    }
}

// MARK: - Navigation Destination Routing

extension MainView {
    @ViewBuilder
    func navigationDestinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        // Account Section
        case .profile: ProfileView()
        case .editProfile: EditProfileView()
        case .changePassword: EmptyView()
        case .changePhoneNumber: EmptyView()
        // More Section
        case .contactUs: ContactUsView()
        case .rewards: EmptyView()
        case .notifications: NotificationsView()
        case .walletView: WalletView()
        // Orders
        case .myOrders: MyOrdersView()
        case .orderDetails(let orderID): OrderDetailsView(orderID: orderID)
        // Products
        case .productsListView(let specialCategory): ProductsListView(viewModel: viewModel, specialCategory: specialCategory)
        case .productDetails(let id): ProductDetailsView(viewModel: viewModel, productId: id)
        // Services
        case .services(let selectedCategoryId): ServicesView(viewModel: viewModel, selectedCategoryId: selectedCategoryId)
        case .serviceDetails: ServiceDetailsView()
        // Other Sections
        case .paymentSuccess: SuccessView()
        case .constant(let item): ConstantView(item: .constant(item))
        // Add more cases as needed...
        case .addOrder(let selectedCategory, let selectedSubCategory):
            AddOrderView(
                viewModel: viewModel,
                userViewModel: UserViewModel(errorHandling: ErrorHandling()),
                locationManager: LocationManager.shared,
                selectedCategory: selectedCategory,
                selectedSubCategory: selectedSubCategory,
                cameFromMain: false
            )
        case .checkout(let orderData):
            CheckoutView(orderData: orderData)
        case .addressBook:
            AddressBookView()
        case .addAddressBook:
            AddAddressView()
        case .editAddressBook(let item):
            EditAddressView(addressItem: item)
        case .addressBookDetails(let item):
            AddressDetailsView(addressItem: item)
        default: EmptyView()
        }
    }
}

// MARK: - Popup Helpers

extension MainView {
    @ViewBuilder
    var popupView: some View {
        if let popup = appRouter.activePopup {
            switch popup {
            case .cancelOrder(let alertModel):
                AlertView(alertModel: alertModel)
            case .alert(let alertModel):
                AlertView(alertModel: alertModel)
            case .inputAlert(let alertModelWithInput):
                InputAlertView(alertModel: alertModelWithInput)
            }
        }
    }

    @ViewBuilder
    var appPopupView: some View {
        if let popup = appRouter.appPopup {
            switch popup {
            case .alertError(let title, let message):
                GeneralAlertToastView(title: title, message: message, type: .error)
            case .alertSuccess(let title, let message):
                GeneralAlertToastView(title: title, message: message, type: .success)
            case .alertInfo(let title, let message):
                GeneralAlertToastView(title: title, message: message, type: .info)
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(UserSettings())
        .environmentObject(AppState())
}
