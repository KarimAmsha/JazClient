import Foundation
import Alamofire

// Function to get the user's preferred language code
func getUserPreferredLanguageCode() -> String? {
    return Locale.preferredLanguages.first?.components(separatedBy: "-").first
}

enum APIEndpoint {
    case getWelcome
    case getConstants
    case getConstantDetails(_id: String)
    case register(params: [String: Any])
    case verify(params: [String: Any])
    case resend(params: [String: Any])
//    case updateUserDataWithImage(params: [String: Any], imageFiles: [(Data, String)]?, token: String)
    case updateUserDataWithImage(params: [String: Any], imageData: Data?, token: String)
    case updateUserData(params: [String: Any], token: String)
    case getUserProfile(token: String)
    case logout(userID: String)
    case addOrder(params: [String: Any], token: String)
    case addOfferToOrder(orderId: String, params: [String: Any], token: String)
    case updateOfferStatus(orderId: String, params: [String: Any], token: String)
    case updateOrderStatus(orderId: String, params: [String: Any], token: String)
    case map(params: [String: Any], token: String)
    case getOrders(status: String?, page: Int?, limit: Int?, token: String)
    case getOrderDetails(orderId: String, token: String)
    case addReview(orderID: String, params: [String: Any], token: String)
    case getNotifications(page: Int?, limit: Int?, token: String)
    case deleteNotification(id: String, token: String)
    case getWallet(page: Int?, limit: Int?, token: String)
    case addBalanceToWallet(params: [String: Any], token: String)
    case addComplain(params: [String: Any], token: String)
    case createReferal(token: String)
    case checkCoupon(params: [String: Any], token: String)
    case getCategories(q: String?)
    case addAddress(params: [String: Any], token: String)
    case updateAddress(params: [String: Any], token: String)
    case deleteAddress(id: String, token: String)
    case getAddressByType(type: String, token: String)
    case getAddressList(token: String)
    case getTotalPrices(params: [String: Any], token: String)
    case getRates(page: Int?, limit: Int?, id: String, token: String)
    case getAppConstants
    case getHome(q: String?, lat: Double, lng: Double)
    case guest
    case deleteAccount(id: String, token: String)
    case getContact
    case tamaraCheckout(params: [String: Any], token: String)
    case checkPlace(params: [String: Any], token: String)
    case checkPoint(params: [String: Any], token: String)
    case rechangePoint(params: [String: Any], token: String)
    case getProducts(page: Int?, limit: Int?, params: [String: Any], token: String)
    case getProductDetails(id: String, token: String)
    case addToCart(params: [String: Any], token: String)
    case getCartItems(token: String)
    case updateCartItems(params: [String: Any], token: String)
    case deleteCart(token: String)
    case deleteCartItem(params: [String: Any], token: String)
    case cartCount(token: String)
    case cartTotal(token: String)
    case addToFavorite(params: [String: Any], token: String)
    case getFavorite(page: Int?, limit: Int?, token: String)
    case getWishGroups(page: Int?, limit: Int?, user_id: String?, token: String)
    case getGroup(id: String, token: String)
    case addGroup(params: [String: Any], token: String)
    case editGroup(id: String, params: [String: Any], token: String)
    case deleteGroup(id: String, params: [String: Any], token: String)
    case addFriend(params: [String: Any], token: String)
    case getFriends(page: Int?, limit: Int?, token: String)
    case explore(page: Int?, limit: Int?, token: String)
    case reminder(page: Int?, limit: Int?, token: String)
    case addReminder(params: [String: Any], token: String)
    case deleteReminder(id: String, params: [String: Any], token: String)
    case addUserProduct(params: [String: Any], token: String)
    case addVIP(params: [String: Any], token: String)
    case addWish(params: [String: Any], token: String)
    case getUserWishes(page: Int?, limit: Int?, params: [String: Any], token: String)
    case payWish(id: String, params: [String: Any], token: String)
    case getWish(id: String, token: String)
    case checkCartCoupun(params: [String: Any], token: String)
    case addOrderWish(params: [String: Any], token: String)
    case refreshFcmToken(params: [String: Any], token: String)

    // Define the base API URL
    private static let baseURL = Constants.baseURL
    
    // Computed property to get the full URL for each endpoint
    var fullURL: String {
        return APIEndpoint.baseURL + path
    }

    var path: String {
        switch self {
        case .getWelcome:
            return "/mobile/constant/welcome"
        case .getConstants:
            return "/mobile/constant/static"
        case .getConstantDetails(let _id):
            return "/mobile/constant/static/\(_id)"
        case .register:
            return "/mobile/user/create_login"
        case .verify:
            return "/mobile/user/verify"
        case .resend:
            return "/mobile/user/resend"
        case .updateUserDataWithImage:
            return "/mobile/user/update-profile"
        case .updateUserData:
            return "/mobile/user/update-profile"
        case .getUserProfile:
            return "/mobile/user/get-user"
        case .logout(let userID):
            return "/mobile/user/logout/\(userID)"
        case .addOrder:
            return "/mobile/order/add"
        case .addOfferToOrder(orderId: let orderId, _ , _):
            return "/mobile/order/offer/\(orderId)"
        case .updateOfferStatus(orderId: let orderId, _, _):
            return "/mobile/order/offer/update/\(orderId)"
        case .updateOrderStatus(orderId: let orderId, _, _):
            return "/mobile/order/update/\(orderId)"
        case .map(let params, _):
            if !params.isEmpty {
                var url = "/mobile/order/map?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/order/map"
            }
        case .getOrders(status: let status, page: let page, limit: let limit, _):
            var params: [String: Any] = [:]

            if let status = status {
                params["status"] = status

            }
            if let page = page {
                params["page"] = page

            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/order/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/order/get"
            }
        case .getOrderDetails(orderId: let orderId, _):
            return "/mobile/order/single/\(orderId)"
        case .addReview(orderID: let orderID, _, _):
            return "/mobile/order/rate/\(orderID)"
        case .getNotifications(page: let page, limit: let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page

            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/notification/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/notification/get"
            }
        case .deleteNotification(id: let id, _):
            return "/mobile/notification/delete/\(id)"
        case .getWallet(page: let page, limit: let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/transaction/list?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/transaction/list"
            }
        case .addBalanceToWallet:
            return "/mobile/user/wallet"
        case .addComplain:
            return "/mobile/constant/add-complain"
        case .createReferal:
            return "/mobile/user/referal"
        case .checkCoupon:
            return "/mobile/check/coupon"
        case .getCategories(let q):
            var params: [String: Any] = [:]

            if let q = q {
                params["q"] = q
            }
            if !params.isEmpty {
                var url = "/mobile/constant/category?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/constant/category"
            }
        case .addAddress:
            return "/mobile/user/add_address"
        case .updateAddress:
            return "/mobile/user/update_address"
        case .deleteAddress:
            return "/mobile/user/delete_address"
        case .getAddressByType(let type, _):
            return "/mobile/user/get_address/\(type)"
        case .getAddressList:
            return "/mobile/user/get_address"
        case .getTotalPrices:
            return "/mobile/order/totals"
        case .getRates(_, _, let id, _):
            return "/mobile/rates/\(id)"
        case .getAppConstants:
            return "/mobile/constant/get"
        case .getHome(let q, let lat, let lng):
            var params: [String: Any] = [:]

            if let q = q {
                params["q"] = q

            }
            params["lat"] = lat
            params["lng"] = lng
            if !params.isEmpty {
                var url = "/mobile/home/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/home/get"
            }
        case .guest:
            return "/mobile/guest/token"
        case .deleteAccount(let id, _):
            return "/mobile/delete/\(id)"
        case .getContact:
            return "/mobile/constant/contact_options"
        case .tamaraCheckout:
            return "/mobile/checkout"
        case .checkPlace:
            return "/mobile/check/place"
        case .checkPoint:
            return "/mobile/point/check"
        case .rechangePoint:
            return "/mobile/user/rechange"
        case .getProducts(let page, let limit, let params, _):
            var params = params
            
            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/product/list?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/product/list"
            }
        case .getProductDetails(let id, _):
            let url = "/mobile/products/details/\(id)"
            return url
        case .addToCart:
            return "/mobile/cart/add"
        case .getCartItems:
            return "/mobile/cart/get"
        case .updateCartItems:
            return "/mobile/cart/update"
        case .deleteCart:
            return "/mobile/cart/delete-cart"
        case .deleteCartItem(let params, _):
            let params = params
            
            if !params.isEmpty {
                var url = "/mobile/cart/delete?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/cart/delete"
            }
        case .cartCount:
            return "/mobile/cart/count"
        case .cartTotal:
            return "/mobile/cart/total"
        case .addToFavorite:
            return "/mobile/favorite/add"
        case .getFavorite(let page, let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/favorite/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/favorite/get"
            }
        case .getWishGroups(let page, let limit, let user_id, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }
            if let user_id = user_id {
                params["user_id"] = user_id
            }

            if !params.isEmpty {
                var url = "/mobile/wish_group/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/wish_group/get"
            }
        case .getGroup(let id, _):
            return "/mobile/wish_group/get/\(id)"
        case .addGroup:
            return "/mobile/wish_group/add"
        case .editGroup(let id, _, _):
            return "/mobile/wish_group/edit/\(id)"
        case .deleteGroup(let id, _, _):
            return "/mobile/wish_group/delete/\(id)"
        case .getWishGroups(let page, let limit, let user_id, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }
            if let user_id = user_id {
                params["user_id"] = user_id
            }

            if !params.isEmpty {
                var url = "/mobile/wish_group/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/wish_group/get"
            }
        case .addFriend:
            return "/mobile/friend/add"
        case .getFriends(let page, let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/friend/list?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/friend/list"
            }
        case .explore(let page, let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/wish/explore?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/wish/explore"
            }
        case .reminder(let page, let limit, _):
            var params: [String: Any] = [:]

            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/reminder/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/reminder/get"
            }
        case .addReminder:
            return "/mobile/reminder/add"
        case .deleteReminder(let id, _, _):
            return "/mobile/reminder/delete/\(id)"
        case .addUserProduct:
            return "/mobile/form/product"
        case .addVIP:
            return "/mobile/form/vip"
        case .addWish:
            return "/mobile/wish/add"
        case .getUserWishes(let page, let limit, let params, _):
            var params = params
            
            if let page = page {
                params["page"] = page
            }
            if let limit = limit {
                params["limit"] = limit
            }

            if !params.isEmpty {
                var url = "/mobile/wish/get?"
                url += params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                return url
            } else {
                return "/mobile/wish/get"
            }
        case .payWish(let id, _, _):
            return "/mobile/wish/pay/\(id)"
        case .getWish(let id, _):
            return "/mobile/wish/get/\(id)"
        case .checkCartCoupun:
            return "/mobile/cart/coupon"
        case .addOrderWish:
            return "/mobile/order/add_wish"
        case .refreshFcmToken:
            return "/mobile/user/refresh-fcm-token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getWelcome, .getConstants, .getUserProfile, .getConstantDetails, .map, .getOrders, .getOrderDetails, .getNotifications, .getWallet, .getCategories, .getAddressByType, .getAddressList, .getRates, .getAppConstants, .getHome, .guest, .getContact, .getProducts, .getProductDetails, .cartCount, .getFavorite, .getWishGroups, .getGroup, .getFriends, .explore, .reminder, .getUserWishes, .getWish:
            return .get
        case .register, .verify, .resend, .updateUserDataWithImage, .updateUserData, .logout, .addOrder, .addOfferToOrder, .updateOfferStatus, .updateOrderStatus, .addReview, .deleteNotification, .addBalanceToWallet, .addComplain, .createReferal, .checkCoupon, .addAddress, .updateAddress, .deleteAddress, .getTotalPrices, .deleteAccount, .tamaraCheckout, .checkPlace, .checkPoint, .rechangePoint, .addToCart, .getCartItems, .cartTotal, .updateCartItems, .deleteCart, .deleteCartItem, .addToFavorite, .addGroup, .editGroup, .deleteGroup, .addFriend, .addReminder, .deleteReminder, .addUserProduct, .addVIP, .addWish, .payWish, .checkCartCoupun, .addOrderWish, .refreshFcmToken:
            return .post
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .getWelcome, .getConstants, .getConstantDetails, .register, .verify, .resend, .getCategories, .getAppConstants, .getHome, .guest, .getContact, .logout(_):
            var headers = HTTPHeaders()
            headers.add(name: "Accept-Language", value: getUserPreferredLanguageCode() ?? "ar")
            return headers
        case .getUserProfile(let token), .updateUserDataWithImage(_, _, let token), .updateUserData(_, let token), .addOrder(_, let token), .map(_, let token), .addOfferToOrder(_, _, let token), .updateOfferStatus(_, _, let token), .updateOrderStatus(_, _, let token), .getOrders(_, _, _, token: let token), .getOrderDetails(_, let token), .addReview(_, _, let token), .getNotifications(_, _, let token), .deleteNotification(_, let token), .getWallet(_, _, let token), .addBalanceToWallet(_, let token), .addComplain(_ , let token), .createReferal(let token), .checkCoupon(_, let token), .addAddress(_, let token), .updateAddress(_, let token), .deleteAddress(_, let token), .getAddressByType(_, let token), .getAddressList(let token), .getTotalPrices(_, let token), .getRates(_, _, _, let token), .deleteAccount(_, let token), .tamaraCheckout(_, let token), .checkPlace(_, let token), .checkPoint(_, let token), .rechangePoint(_, let token), .getProducts(_, _, _, let token), .getProductDetails(_, let token), .addToCart(params: _, let token), .getCartItems(let token), .updateCartItems(_, let token), .deleteCart(let token), .deleteCartItem(_, let token), .cartCount(let token), .cartTotal(let token), .getFavorite(_, _, let token), .addToFavorite(_, let token), .getWishGroups(_, _, _, let token), .getGroup(_, let token), .addGroup(_, let token), .editGroup(_, _, let token), .deleteGroup(_, _, let token), .addFriend(_, let token), .getFriends(_, _, let token), .explore(_, _, let token), .reminder(_, _, let token), .addReminder(_, let token), .deleteReminder(_, _, let token), .addUserProduct(_, let token), .addVIP(_, let token), .addWish(_, let token), .getUserWishes(_, _, _, let token), .payWish(_, _, let token), .getWish(_, let token), .checkCartCoupun(_, let token), .addOrderWish(_, let token), .refreshFcmToken(_, let token):
            var headers = HTTPHeaders()
            headers.add(name: "Accept-Language", value: getUserPreferredLanguageCode() ?? "ar")
            headers.add(name: "token", value: token)
            return headers
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getWelcome, .getConstants, .getConstantDetails, .getUserProfile, .logout, .map, .getOrders, .getOrderDetails, .getNotifications, .deleteNotification, .getWallet, .createReferal, .getCategories, .getAddressByType, .getAddressList, .getRates, .getAppConstants, .getHome, .guest, .deleteAccount, .getContact, .getProducts, .getProductDetails, .getCartItems, .deleteCart, .cartCount, .cartTotal, .getFavorite, .getWishGroups, .getGroup, .getFriends, .explore, .reminder, .getUserWishes, .getWish:
            return nil
        case .register(let params), .verify(let params), .resend(let params), .updateUserDataWithImage(let params, _, _), .updateUserData(let params, _), .addOrder(let params, _), .addOfferToOrder(_, let params, _), .updateOfferStatus(_, let params, _), .updateOrderStatus(_, let params, _), .addReview(_, let params, _), .addBalanceToWallet(let params, _), .addComplain(let params, _), .checkCoupon(let params, _), .addAddress(let params, _), .updateAddress(let params, _), .getTotalPrices(let params, _), .tamaraCheckout(let params, _), .checkPlace(let params, _), .checkPoint(let params, _), .rechangePoint(let params, _), .addToCart(let params, _), .updateCartItems(let params, _), .deleteCartItem(let params, _), .addToFavorite(let params, _), .addGroup(let params, _), .editGroup(_, let params, _), .deleteGroup(_, let params, _), .addFriend(let params, _), .addReminder(let params, _), .deleteReminder(_, let params, _), .addUserProduct(let params, _), .addVIP(let params, _), .addWish(let params, _), .payWish(_, let params, _), .checkCartCoupun(let params, _), .addOrderWish(let params, _), .refreshFcmToken(let params, _):
            return params
        case .deleteAddress(let id, _):
            let params: [String: Any] = ["id": id]
            return params
        }
    }
}

