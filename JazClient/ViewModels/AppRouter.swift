//
//  AppRouter.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

final class AppRouter: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case profile
        case editProfile
        case changePassword
        case changePhoneNumber
        case contactUs
        case rewards
        case paymentSuccess
        case constant(ConstantItem)
        case myOrders
        case orderDetails(String)
        case upcomingReminders
        case productsListView(Category?)
        case productDetails(String?)
        case selectedGiftView
        case friendWishes(User)
        case friendWishesListView
        case friendWishesDetailsView(String?)
        case retailFriendWishesView
        case retailPaymentView(String)
        case addressBook
        case addAddressBook
        case editAddressBook(AddressItem)
        case addressBookDetails(AddressItem)
        case notifications
        case checkoutView(CartItems?)
        case productsSearchView
        case wishesView
        case userProducts(String)
        case addUserProduct
        case VIPGiftView(CategoryType)
        case userWishes(String, String)
        case wishCheckOut(String)
        case walletView
        case explorWishView(String)
        case myWishView(String)
        case addReview(String)
        case deliveryDetails
        case earningsView
        case notificationsSettings
        case accountSettings
        case freelancerList
        case freelancerProfile
        case serviceDetails
        case chat(chatId: String, currentUserId: String)
        case services(String?)
        case addOrder(selectedCategory: Category?, selectedSubCategory: SubCategory?)
        case checkout(orderData: OrderData)
    }
    
    public enum Popup: Hashable {
        case cancelOrder(AlertModel)
        case alert(AlertModel)
        case inputAlert(AlertModelWithInput)
    }

    public enum AppPopup: Hashable {
        case alertError(String, String)
        case alertSuccess(String, String)
        case alertInfo(String, String)
    }

    @Published var navPath = NavigationPath()
    @Published var activePopup: Popup? = nil
    @Published var appPopup: AppPopup? = nil

    func navigate(to destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        if !navPath.isEmpty {
            navPath.removeLast()
        }
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
    
    func togglePopup(_ popup: Popup?) {
        activePopup = popup
    }
        
    func toggleAppPopup(_ popup: AppPopup?) {
        appPopup = popup
    }
    
    func dismissPopup() {
        activePopup = nil
    }

    func dismissAppPopup() {
        appPopup = nil
    }
}

