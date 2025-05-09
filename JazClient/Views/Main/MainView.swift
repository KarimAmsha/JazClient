//
//  MainView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

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
    private var tabItems: [MainTabItem] {
        var items: [MainTabItem] = [
            MainTabItem(page: .home, iconSystemName: "house", title: "الرئيسية"),
            MainTabItem(page: .chat, iconSystemName: "message", title: "الرسائل", isNotified: true),
            MainTabItem(page: .projects, iconSystemName: "briefcase", title: "المشاريع"),
            MainTabItem(page: .more, iconSystemName: "line.3.horizontal", title: "المزيد")
        ]

        if settings.userRole == .provider {
            items.insert(
                MainTabItem(page: .addService, iconSystemName: "plus.circle", title: "إضافة خدمة"),
                at: 2
            )
        }

        return items
    }

    var body: some View {
        NavigationStack(path: $appRouter.navPath) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.clear)
                    .background(.white)

                VStack(spacing: 0) {
                    Spacer()
                    
                    switch appState.currentPage {
                    case .home:
                        HomeView()
                    case .chat:
//                        ChatListView(userId: UserSettings.shared.id ?? "")
                        ChatListView(viewModel: MockChatListViewModel(userId: "user1"))
                    case .projects:
                        if settings.userRole == .provider {
                            ProjectsView()
                        } else {
                            ClientProjectsView()
                        }
                    case .addService:
                        settings.id == nil ? CustomeEmptyView().eraseToAnyView() : AddServiceView().eraseToAnyView()
                    case .more:
                        settings.id == nil ? CustomeEmptyView().eraseToAnyView() : ProfileView().eraseToAnyView()
                    }

                    VStack(spacing: 0) {
                        CustomDivider()
                            .padding(.bottom)

                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ForEach(tabItems, id: \.page) { item in
                                    TabBarIcon(
                                        appState: appState,
                                        assignedPage: item.page,
                                        width: 24,
                                        height: 24,
                                        iconName: item.iconSystemName,
                                        tabName: item.title,
                                        isNotified: item.isNotified
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 25)
                            .frame(height: 60)
                            .background(Color.white)
                        }
                        .frame(height: 70)
                    }
                    .frame(height: 70)
                    .background(Color.white)
                }
            }
            .background(Color.background())
            .edgesIgnoringSafeArea(.bottom)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color.background(), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(appRouter)
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                switch destination {
                case .profile:
                    ProfileView()
                case .editProfile:
                    EditProfileView()
                case .changePassword:
                    EmptyView()
//                    ChangePasswordView()
                case .changePhoneNumber:
                    EmptyView()
//                    ChangePhoneNumberView()
                case .contactUs:
                    ContactUsView()
                case .rewards:
                    EmptyView()
//                    RewardsView()
                case .paymentSuccess:
                    SuccessView()
                case .constant(let item):
                    ConstantView(item: .constant(item))
                case .myOrders:
                    MyOrdersView()
                case .orderDetails(let orderID):
                    OrderDetailsView(orderID: orderID)
                case .upcomingReminders:
                    UpcomingRemindersView()
                case .productsListView(let specialCategory):
                    ProductsListView(viewModel: viewModel, specialCategory: specialCategory)
                case .productDetails(let id):
                    ProductDetailsView(viewModel: viewModel, productId: id)
                case .selectedGiftView:
                    SelectedGiftView()
                case .friendWishes(let user):
                    FriendWishesView(user: user)
                case .friendWishesListView:
                    FriendWishesListView()
                case .friendWishesDetailsView(let id):
                    FriendWishesDetailsView(wishId: id, viewModel: viewModel)
                case .retailFriendWishesView:
                    RetailFriendWishesView()
                case .retailPaymentView(let id):
                    RetailPaymentView(wishId: id)
                case .addressBook:
                    AddressBookView()
                case .addAddressBook:
                    AddAddressView()
                case .editAddressBook(let item):
                    EditAddressView(addressItem: item)
                case .addressBookDetails(let item):
                    AddressDetailsView(addressItem: item)
                case .notifications:
                    NotificationsView()
                case .checkoutView(let cartItems):
                    CheckoutView(cartItems: cartItems)
                case .productsSearchView:
                    ProductsSearchView(viewModel: viewModel)
                case .wishesView:
                    WishesView()
                case .userProducts(let id):
                    UserProductsView(viewModel: viewModel, id: id)
                case .addUserProduct:
                    AddUserProductView(viewModel: viewModel)
                case .VIPGiftView(let type):
                    VIPGiftView(viewModel: viewModel, categoryType: type)
                case .userWishes(let userId, let groupId):
                    UserWishesView(userId: userId, group_id: groupId)
                case .wishCheckOut(let id):
                    WishCheckOutView(wishId: id)
                case .walletView:
                    WalletView()
                case .explorWishView(let id):
                    ExplorWishView(wishId: id, viewModel: viewModel)
                case .myWishView(let id):
                    MyWishView(wishId: id, viewModel: viewModel)
                case .addReview(let id):
                    AddReviewView(orderId: id)
                case .deliveryDetails:
                    DeliveryDetailsView()
                case .earningsView:
                    EarningsView()
                case .notificationsSettings:
                    NotificationsSettingsView()
                case .accountSettings:
                    AccountSettingsView()
                case .freelancerList:
                    FreelancerListView()
                case .freelancerProfile:
                    FreelancerProfileView()
                case .serviceDetails:
                    ServiceDetailsView()
                case .chatDetail(let id):
//                    ChatDetailView(chatId: id, currentUserId: UserSettings.shared.id ?? "")
                    ChatDetailView(viewModel: MockChatViewModel())
                }
            }
            .popup(isPresented: Binding<Bool>(
                get: { appRouter.activePopup != nil },
                set: { _ in appRouter.togglePopup(nil) })
            ) {
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

#Preview {
    MainView()
        .environmentObject(UserSettings())
        .environmentObject(AppState())
}

