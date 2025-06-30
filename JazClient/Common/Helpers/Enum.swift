//
//  Enum.swift
//  Khawi
//
//  Created by Karim Amsha on 20.10.2023.
//

import Foundation
import SwiftUI

enum FontWeight: String {
    case regular  = "IBMPlexSansArabic-Regular"
    case medium   = "IBMPlexSansArabic-Medium"
    case light    = "IBMPlexSansArabic-Light"
    case bold     = "IBMPlexSansArabic-Bold"
    case semiBold = "IBMPlexSansArabic-SemiBold"
}

enum Language: String {
    case english
    case arabic
    
    var isRTL: Bool {
        self == .arabic
    }
}

enum UserType: String, Codable {
    case company
    case personal
    
    var value : String {
        switch self {
        case .company: return "company"
        case .personal: return "personal"
        }
    }
}

enum LoginType: String, Codable {
    case login
    case register
    case verification
}

enum MType: String, Codable {
    case photo
    case image
    case video
    case multi
    case media
    case text
    case none
    
    init(_ type: String) {
        switch type {
        case "photo" : self = .photo
        case "image" : self = .image
        case "video": self = .video
        case "multi": self = .multi
        case "media": self = .media
        case "text": self = .text
        case "none": self = .none
        default:
            self = .text
        }
    }

    var value : String {
        switch self {
        case .photo: return "photo"
        case .image: return "image"
        case .video: return "video"
        case .multi: return "multi"
        case .media: return "media"
        case .text: return "text"
        case .none: return "none"
        }
    }
}

enum MediaType {
    case multi
    case video
    case image
}

enum Page {
    case home, chat, addService, more, projects
}

enum RequestType {
    case joiningRequest
    case deliveryRequest
    
    var value : String {
        switch self {
        case .joiningRequest: return LocalizedStringKey.joiningRequest
        case .deliveryRequest: return LocalizedStringKey.deliveryRequest
        }
    }
}

enum OrderType: String, Codable {
    case new
    case finished
    case canceled
}

enum NewOrderType: String, Codable {
    case job
    case service
}

enum OfferType: String, Codable {
    case online
    case onfield
}

enum TargetType: String, Codable {
    case personal
    case company
}

enum PriceType: String, Codable {
    case hourly
    case daily
    case yearly
}

enum ExecutionType: String, Codable {
    case limited
    case unlimted
}

enum ProviderTabs: String, Codable {
    case services
    case reviews
}

enum OffersType: String, Codable, CaseIterable {
    case all = "all"
    case openedOffers = "openedOffers"
    case closedOffers = "closedOffers"
}

enum MessageType: String, Codable, CaseIterable {
    case openedMessage = "openedMessage"
    case newMessage = "newMessage"
}

enum OrderStatus: String, Codable, CaseIterable {
    case new = "new"
    case accepted = "accepted"
    case started = "started"
    case way = "way"
    case progress = "progress"
    case updated = "updated"
    case prefinished = "prefinished"
    case finished = "finished"
    case rated = "rated"
    case canceled = "canceled_by_user"

    init(_ type: String) {
        switch type {
        case "new" : self = .new
        case "accepted" : self = .accepted
        case "started" : self = .started
        case "way" : self = .way
        case "progress" : self = .progress
        case "updated": self = .updated
        case "prefinished" : self = .prefinished
        case "finished" : self = .finished
        case "rated" : self = .finished
        case let status where status.contains("canceled"): self = .canceled
        default:
            self = .accepted
        }
    }

    var value: String {
        switch self {
        case .new: return LocalizedStringKey.new
        case .accepted: return LocalizedStringKey.new
        case .started: return LocalizedStringKey.started
        case .way: return LocalizedStringKey.way
        case .progress: return LocalizedStringKey.progress
        case .updated: return LocalizedStringKey.updated
        case .prefinished: return LocalizedStringKey.unconfirmed
        case .finished: return LocalizedStringKey.finished
        case .rated: return LocalizedStringKey.finished
        case .canceled: return LocalizedStringKey.canceled
        }
    }
    
    func iconName() -> String {
        switch self {
        case .new: return "ic_peace"
        case .accepted: return "ic_peace"
        case .started: return "ic_car"
        case .way: return "ic_car"
        case .progress: return "ic_g_export"
        case .finished: return "ic_car"
        case .prefinished: return "ic_car"
        case .rated: return "ic_car"
        case .updated: return ""
        case .canceled: return ""
        }
    }

    func stepText() -> String {
        switch self {
        case .new: return "تعيين فني"
        case .accepted: return "تعيين فني"
        case .started: return "في الطريق"
        case .way: return "في الطريق"
        case .progress: return "قيد التسليم"
        case .finished: return "تم التوصيل بنجاح!"
        case .prefinished: return "تم التوصيل بنجاح!"
        case .rated: return "تم التوصيل بنجاح!"
        case .updated: return "تم التعديل"
        case .canceled: return "تم الالغاء"
        }
    }
}

enum ConstantType: String, Codable, CaseIterable {
    case privacy = "privacy"
    case terms = "terms"
    case using = "using"
    case about = "about"
}

extension OrderStatus {
    var colors: (foreground: Color, background: Color) {
        switch self {
        case .new, .accepted, .started:
            return (.blue068DA9(), .blueE6F3F6())
        case .progress, .updated, .way:
            return (.blue3A70E2(), .blueEBF0FC())
        case .prefinished, .finished, .rated:
            return (.green0C9D61(), .greenE6F5EF())
        case .canceled:
            return (.redE50000(), .orangeFCE5E5())
        }
    }
}

enum OfferStatus: String, Codable {
    case addOffer = "add_offer"
    case acceptOffer = "accept_offer"
    case rejectOffer = "reject_offer"
    case attend  = "attend"
    case notAttend  = "not_attend"
}

enum HomeType: String, Codable {
    case slider = "slider"
    case main_service = "main_service"
    case offer = "offer"
    case banner = "banner"
    case comunity  = "comunity"
    case whatsapp  = "whatsapp"
    case adv = "adv"
    case product = "product"
}

enum PopupView: Hashable {
    case error(String, String)
    case alert(AlertModel)
    case inputAlert(AlertModelWithInput)
    case dateTimePicker(DateTimeModel)
}

extension PopupView: Equatable {
    static func == (lhs: PopupView, rhs: PopupView) -> Bool {
        switch (lhs, rhs) {
        case let (.error(title1, message1), .error(title2, message2)):
            return title1 == title2 && message1 == message2
        case let (.alert(model1), .alert(model2)):
            return model1 == model2
        case let (.inputAlert(model1), .inputAlert(model2)):
            return model1 == model2
        default:
            return false
        }
    }
}

enum DateTimePickerMode {
    case date
    case time
}

enum LoginStatus: Equatable {
    case welcome
    case register
    case login
    case accountCreated
    case forgetPassword
    case changePassword
    case identityConfirmation(String)
    case verification
    case selectLocation
    case completeProfile(String)

    static func == (lhs: LoginStatus, rhs: LoginStatus) -> Bool {
        switch (lhs, rhs) {
        case (.welcome, .welcome),
             (.register, .register),
            (.login, .login),
            (.accountCreated, .accountCreated),
            (.forgetPassword, .forgetPassword),
            (.changePassword, .changePassword),
             (.verification, .verification),
             (.selectLocation, .selectLocation):
            return true

        case let (.identityConfirmation(lhsString), .identityConfirmation(rhsString)):
            // Compare identityConfirmation based on the associated String
            return lhsString == rhsString

        case let (.completeProfile(lhsString), .completeProfile(rhsString)):
            // Compare profiles based on the associated String and array of tuples
            return lhsString == rhsString 

        default:
            return false
        }
    }
}

enum PlaceType: String, Codable {
    case home
    case work
    case currentLocation

    var value : String {
        switch self {
        case .home: return LocalizedStringKey.homeAddress
        case .work: return LocalizedStringKey.work
        case .currentLocation: return LocalizedStringKey.currentLocation
        }
    }
}

// Define the enum for the 'type' property
enum TransactionType: String, Codable {
    case addition = "+"
    case subtraction = "-"
}

enum NotificationType: String, Codable {
    case orders = "1"
    case coupon = "2"
    case general = "3"
    case reminder = "4"
    case friend = "5"

    init(_ type: String) {
        switch type {
        case "1": self = .orders
        case "2": self = .coupon
        case "3": self = .general
        case "4": self = .reminder
        case "5": self = .friend
        default:
            self = .general
        }
    }
}

enum NOTIFICATION_TYPE: Int {
    case ORDERS = 1
    case COUPON = 2
    case GENERAL = 3
}

enum PaymentMethod: String, CaseIterable {
    case goSell = "ic_gosell"
    case wallet = "ic_w"
//    case cash = "ic_cash"
    case tamara = "ic_tamara"
    
    var value : String {
        switch self {
        case .goSell: return "goSell"
        case .wallet: return LocalizedStringKey.wallet
//        case .cash: return LocalizedStringKey.payCash
        case .tamara: return "tamara"
        }
    }
    
    var imageName: String {
        self.rawValue
    }
}

enum NotifiType: String, Codable {
    case reading
    case post
    case like
    case comment
    case share
    case chat
    case story
    case request
    case review
    case friends
    case other
    
    var value : String {
        switch self {
        case .reading: return "reading"
        case .post: return "post"
        case .like: return "like"
        case .comment: return "comment"
        case .share: return "share"
        case .chat: return "chat"
        case .story: return "story"
        case .request: return "request"
        case .review: return "review"
        case .friends: return "friends"
        default: return ""
        }
    }
    
    init(_ type:String) {
        switch type {
        case "reading": self = .reading
        case "post": self = .post
        case "like": self = .like
        case "comment": self = .comment
        case "share": self = .share
        case "chat": self = .chat
        case "story": self = .story
        case "request": self = .request
        case "review": self = .review
        case "friends": self = .friends
        default: self = .other
        }
    }
}

// Localization keys
enum LocalizedStringKey {
    static let switchToEnglish = "Switch to English".localized
    static let switchToArabic = "Switch to Arabic".localized
    static let shareYourPathWithOthers = "Share your path with others".localized
    static let gettingToYourDestinationIsEasier = "Getting to your destination is easier".localized
    static let investYourCar = "Invest your car".localized
    static let descriptionKey = "Through the availability of many cars you can easily find someone who will save you the time and trouble of transportation".localized
    static let next = "Next".localized
    static let createNewAccount = "Create New Account".localized
    static let enterYourPhoneNumberToCreateNewAccount = "Enter your phone number to create new account".localized
    static let register = "Register".localized
    static let enterCodeWasSentToYourMobileNumber = "Enter code!".localized
    static let phoneNumber = "Phone Number".localized
    static let error = "Error".localized
    static let loading = "Loading".localized
    static let verifyCode = "Verify Code".localized
    static let resendCodeAfter = "Resend code after".localized
    static let personalInformation = "Personal Information".localized
    static let completeRegisteration = "Complete Registeration".localized
    static let fullName = "Full Name".localized
    static let email = "Email".localized
    static let areYouHaveCar = "Are you have a car".localized
    static let carType = "Car Type".localized
    static let carModel = "Car Model".localized
    static let carColor = "Car Color".localized
    static let carNumber = "Car Number".localized
    static let choosePhoto = "Choose Photo".localized
    static let takePhoto = "Take Photo".localized
    static let cancel = "Cancel".localized
    static let ok = "Ok".localized
    static let home = "Home".localized
    static let orders = "Orders".localized
    static let notifications = "Notifications".localized
    static let settings = "Settings".localized
    static let hello = "Hello".localized
    static let searchForPlace = "Search for place".localized
    static let joiningRequest = "Joining Request".localized
    static let deliveryRequest = "Delivery Request".localized
    static let currentOrders = "Current Orders".localized
    static let completedOrders = "Completed Orders".localized
    static let cancelledOrders = "Cancelled Orders".localized
    static let tripNumber = "Trip Number".localized
    static let from = "From".localized
    static let to = "To".localized
    static let currentOrder = "Current Order".localized
    static let news = "News".localized
    static let new = "New".localized
    static let finished = "Finished".localized
    static let canceled = "Canceled".localized
    static let openedOrder = "Opened Order".localized
    static let completed = "Completed".localized
    static let canceledOrder = "Canceled".localized
    static let showDetails = "Show Details".localized
    static let carInformation = "Car Information".localized
    static let tripDate = "Trip Date".localized
    static let dateOfTheFirstTrip = "Date Of The First Trip".localized
    static let newPassenger = "New Passenger".localized
    static let agreeOnJoining = "Agree On Joining".localized
    static let orderDetails = "Order Details".localized
    static let showOnMap = "Show On Map".localized
    static let tripDays = "Trip Day".localized
    static let driverInformations = "Driver Informations".localized
    static let personInformations = "Person Informations".localized
    static let numberOfAvailableSeats = "Number of available seats".localized
    static let numberOfRequiredSeats = "Number of required seats".localized
    static let driverNotes = "Driver Notes".localized
    static let notes = "Notes".localized
    static let joinNow = "Join Now".localized
    static let makeDeliveryOffer = "Make a delivery offer".localized
    static let deliveryOffer = "Delivery Offer".localized
    static let minPrice = "Min Price".localized
    static let maxPrice = "Max Price".localized
    static let addOptionalNotes = "Add note (Optional)".localized
    static let deliveryOfferSuccess = "Delivery offer has been successfully submitted".localized
    static let joiningSuccess = "Joining request has been successfully submitted".localized
    static let showRequestDetails = "Show Request Details".localized
    static let addReview = "Add Review".localized
    static let joinToTrip = "Join To Trip".localized
    static let selectDetination = "Select the destination on the map".localized
    static let specifyPrice = "Specify the price".localized
    static let rangeOfPrice = "The price should be between".localized
    static let isDailyTrip = "Is the trip daily?".localized
    static let tripTime = "Trip Time".localized
    static let tripPath = "Trip Path".localized
    static let startPoint = "Start Point".localized
    static let endPoint = "End Point".localized
    static let specifyStartPoint = "Specify Start Point".localized
    static let specifyEndPoint = "Specify End Point".localized
    static let specifyDestination = "Specify Destination".localized
    static let pleaseSpecifyStartPoint = "Please Specify Start Point".localized
    static let pleaseSpecifyEndPoint = "Please Specify End Point".localized
    static let destinationSelected = "Destination has been selected".localized
    static let done = "Done".localized
    static let profile = "Profile".localized
    static let saveChanges = "Save Changes".localized
    static let wallet = "Wallet".localized
    static let aboutUs = "About Us".localized
    static let contactUs = "Contact Us".localized
    static let shareApp = "Share App".localized
    static let termsConditions = "Terms And Conditions".localized
    static let logout = "Logout".localized
    static let myWallet = "My Wallet".localized
    static let lastTransaction = "Last Transaction".localized
    static let totalAccount = "Total Account".localized
    static let sar = "SAR".localized
    static let finicialTransactions = "Finicial Transactions".localized
    static let addAccount = "Add Account".localized
    static let tripTitle = "Trip Title".localized
    static let firstTripDate = "First Trip Date".localized
    static let maxPassengersNumber = "Maximum number of passengers per flight".localized
    static let submitJoinRequest = "Submit Join Request".localized
    static let joinRequestSuccess = "Joining request created successfully".localized
    static let joiningRequests = "Joining Requests".localized
    static let price = "Price".localized
    static let requestAccept = "Request Accept".localized
    static let requestReject = "Request Reject".localized
    static let passengersCount = "Passengers Count".localized
    static let agreeOn = "Agree On".localized
    static let specifyDestinationOnMap = "Specify Destination On Map".localized
    static let submitDeliveryRequest = "Submit Delivery Request".localized
    static let deliveryRequestSuccess = "Delivery request created successfully".localized
    static let yourLocation = "Your Location".localized
    static let tokenError = "Error With Token".localized
    static let logoutMessage = "Are you sure you want to sign out of your account? You can return to your account using your data at any time!".localized
    static let message = "Message".localized
    static let agreeOnTerms = "Please agree on terms and conditions".localized
    static let successfullyUpdated = "Successfully Updated".localized
    static let seats = "Seats".localized
    static let deliveryOffers = "Delivery Offers".localized
    static let accepted = "Accepted".localized
    static let accept = "Accept".localized
    static let started = "Started".localized
    static let start = "Start".localized
    static let finish = "Finish".localized
    static let canceledByDriver = "Canceled By Driver".localized
    static let canceledByUser = "Canceled By User".localized
    static let attend = "Attend".localized
    static let notAttend = "Not Attend".localized
    static let description = "Description".localized
    static let cancellationReason = "Cancellation Reason".localized
    static let send = "Send!".localized
    static let delete = "Delete".localized
    static let deleteMessage = "Are you sure you want to delete this item!..".localized
    static let orderNo = "Order No".localized
    static let payWithCard = "Pay with Card".localized
    static let payWithApplePay = "Pay with Apple Pay".localized
    static let amount = "Amount".localized
    static let exceedsLimits = "Exceeds Limits".localized
    static let acceptedOffers = "Accepted Offers".localized
    static let yourCountry = "Your country".localized
    static let coupon = "Coupon".localized
    static let inviteFriend = "Invite Friend".localized
    static let welcomeTitle1 = "Comfort and speed of completion".localized
    static let welcomeTitle2 = "Safety".localized
    static let welcomeTitle3 = "Easy and simple design".localized
    static let welcomeDesc1 = "While you are at home, you can search in your surroundings for business service providers with ease and in the fastest way".localized
    static let welcomeDesc2 = "Through the business platform, payment and transaction security is guaranteed.".localized
    static let welcomeDesc3 = "Ease of handling and simplicity of designs, enabling you to add all your information in the shortest possible time.".localized
    static let skip = "Skip".localized
    static let welcome = "Welcome".localized
    static let login = "Login".localized
    static let youDontHaveAccount = "You Don't Have Account".localized
    static let registerNow = "Register Now".localized
    static let youHaveAccount = "You Have Account".localized
    static let loginNow = "Login Now".localized
    static let codeWasSendTo = "Code Was Send To".localized
    static let youDontReceiveCode = "You Dont Receive Code".localized
    static let requestNewCode = "Request New Code".localized
    static let confirm = "Confirm".localized
    static let accountWasSuccessfullyCreated = "Account Was Successfully Created".localized
    static let accountCreatedDetails = "You have created a new account and now you can start using the application, but we recommend that you complete your profile information to improve your experience as a user!".localized
    static let completeProfile = "Complete Profile".localized
    static let browseServices = "Browse Services".localized
    static let initialData = "Initial Data".localized
    static let addressDetails = "Address Details".localized
    static let streetName = "Street Name".localized
    static let buildingNo = "Building No".localized
    static let floorNo = "Floor No".localized
    static let saveContinue = "Save & Continue".localized
    static let finishedOrders = "Finished Orders".localized
    static let canceledOrders = "Canceled Orders".localized
    static let myOrders = "My Orders".localized
    static let serviceProvider = "Service Provider".localized
    static let confirmOrder = "Confirm Order".localized
    static let addNewOrder = "Add New Order".localized
    static let initialInfo = "Initial Info".localized
    static let basicServiceType = "Basic Service Type".localized
    static let subServiceType = "Sub Service Type".localized
    static let selectService = "Click here to select service".localized
    static let date = "Date".localized
    static let time = "Time".localized
    static let servicePlace = "Service Place".localized
    static let house = "House".localized
    static let work = "Work".localized
    static let other = "Other".localized
    static let submitServiceRequest = "Submit a service request!".localized
    static let serviceRequestSuccessfullyTitle = "Your service request has been completed successfully!".localized
    static let serviceRequestSuccessfullyMessage = "We have received your request for service and we will review your request and respond to you as soon as possible. You can follow the status of the order from the home page or by clicking the next button.".localized
    static let orderPage = "Order Page".localized
    static let geographicalLocation = "Geographical location".localized
    static let orderStatus = "Order Status".localized
    static let cancelOrder = "Cancel Order".localized
    static let sure = "Yes, Sure".localized
    static let back = "Back".localized
    static let cancelationTitle = "Are you sure to cancel the order?".localized
    static let cancelationSubTitle = "Do you want to cancel your next order?".localized
    static let cancelationMessage = "Please note that after confirming the cancellation of your order, you will not be able to access it again. The money will be returned to your bank account or card within five working days".localized
    static let reviewProvider = "Review Provider".localized
    static let addComment = "Add Comment".localized
    static let sendReview = "Send Review".localized
    static let servicesList = "Services List".localized
    static let providerReviews = "Provider Reviews".localized
    static let providerServiceDetails = "Provider Service Details".localized
    static let serviceReview = "Service Review".localized
    static let myProfile = "My Profile".localized
    static let editProfile = "Edit Profile".localized
    static let aboutApp = "About App".localized
    static let openCloseNot = "Open Close Notifications".localized
    static let usePolicy = "Use Policy".localized
    static let privacyPolicy = "Privacy Policy".localized
    static let additionalDetails = "Additional Details".localized
    static let additionalDetailsHint = "Any additional details could improve the service provided to you".localized
    static let specificText = "Please enter specific text".localized
    static let editMyProfile = "Edit My Profile".localized
    static let contactUsMessage = "After sending your inquiry, we will follow up with you via the attached email to respond to your inquiry.".localized
    static let messageTitle = "Message Title".localized
    static let importantDetailsMissing = "Important details missing".localized
    static let messageContent = "Message Content".localized
    static let problemDetails = "Please enter full details of your problem here...".localized
    static let flatNo = "Flat No".localized
    static let addressBook = "Address Book".localized
    static let addAddress = "Add Address".localized
    static let name = "Name".localized
    static let homeAddress = "home".localized
    static let editAddress = "Edit Address".localized
    static let selectAddress = "Select Address".localized
    static let verify = "Verify".localized
    static let underway = "Underway".localized
    static let progress = "Progress".localized
    static let updated = "Updated".localized
    static let noOrdersFound = "No orders found".localized
    static let startOrder = "Start Order".localized
    static let finishOrder = "Finish Order".localized
    static let updateOrder = "Update Order".localized
    static let extraServices = "Extra Services".localized
    static let extra = "Extra".localized
    static let confirmationCode = "Confirmation Code".localized
    static let paymentUponCompletion = "Payment upon completion of the order".localized
    static let payNow = "Pay Now".localized
    static let discount = "Discount".localized
    static let tax = "Tax".localized
    static let total = "Total".localized
    static let totalBeforeDiscount = "Total Before Discount".localized
    static let totalBeforeTax = "Total Before Tax".localized
    static let completePayment = "Payment to complete the order".localized
    static let addressNotFound = "Address not found".localized
    static let newTax = "New Tax".localized
    static let newTotal = "New Total".localized
    static let paymentRequiredForNewServices = "Payment required for new services".localized
    static let firstWelcome = "Happy to see you again! Enter the following data correctly to access your account...".localized
    static let secondWelcome = "We are honored to have you with us! Enter the following data correctly to create a new account...".localized
    static let thirdWelcome = "Upload a clear personal photo of the owner of this account to add it to your account data...".localized
    static let confirmIdentity = "Confirm Identity".localized
    static let uploadProfilePicture = "Click to upload your profile picture".localized
    static let uploadIDPicture = "Click to upload a photo of your ID".localized
    static let hint1 = "We have sent a one-time password to verify your password change request".localized
    static let hint2 = "It is preferable that the image be clear, in a clear frame, and without adding any effects or modifications...".localized
    static let hint3 = "Completing your personal page data means increasing your chance of getting work and networking with other businesses...".localized
    static let workExperiences = "Field of work and experiences".localized
    static let personalProfile = "Personal profile".localized
    static let address = "Address".localized
    static let workField = "Work Field".localized
    static let showOptions = "Show Options".localized
    static let experiences = "Experiences".localized
    static let newExperiences = "+ Add new experience".localized
    static let dateofbirth = "Date of Birth".localized
    static let fullDescription = "Full Description".localized
    static let dmy = "Day - month - year".localized
    static let chooseLocation = "In addition to choosing the geographical location".localized
    static let hint4 = "You can choose your address by clicking here and choose your geographical location using the map...".localized
    static let country = "Country".localized
    static let city = "City".localized
    static let buildingName = "Building Name".localized
    static let offers = "Offers".localized
    static let discover = "Discover".localized
    static let messages = "Messages".localized
    static let previousOrders = "Previous Orders".localized
    static let experianceYears = "Experiance Years".localized
    static let companyRate = "Company Rate".localized
    static let offersList = "Offers List".localized
    static let browseOffers = "Browse your list of offers...".localized
    static let all = "All".localized
    static let openedOffers = "Opened Offers".localized
    static let closedOffers = "Closed Offers".localized
    static let applicationSettings = "Application Settings!".localized
    static let settingsHint = "Adjust the application settings to suit you...".localized
    static let notificationHint = "Control sending and receiving notifications from the application!".localized
    static let aboutUsHint = "Click to learn more about us and what we offer!".localized
    static let termsOfUseAndPrivacyPolicy = "Terms of use and privacy policy".localized
    static let termsOfUseAndPrivacyPolicyHint = "If you want to avoid problems with usage, click here!".localized
    static let logoutHint = "We are happy and hope to see you again soon!".localized
    static let notificationHint2 = "Browse the list of received notifications".localized
    static let changeProfilePicture = "Click to change your profile picture".localized
    static let editProfileHint = "Edit your personal account information (name, photo, etc.)".localized
    static let discoverOffers = "Discover Offers!".localized
    static let discoverOffersHint = "Explore the world of offers here...".localized
    static let searchHint = "Job title, company name, contract type".localized
    static let makeYourOffer = "Make your offer now!".localized
    static let facilityEvaluations = "Facility Evaluations".localized
    static let submitYourOffer = "Submit your offer".localized
    static let hourlyRate = "Hourly Rate".localized
    static let salary = "Salary".localized
    static let submitOffer = "Submit Offer".localized
    static let submitOfferHint = "Please note that the facility will be able to browse your profile and profile, in addition to the value of the offer you entered!".localized
    static let filterTitle = "Filter your search for offers".localized
    static let employmentApplication = "Employment Application".localized
    static let employmentApplications = "Employment Applications".localized
    static let serviceRequests = "Service Requests".localized
    static let filterSearch = "Filter your search".localized
    static let writeMessage = "Write the message here".localized
    static let companyName = "Company Name".localized
    static let support = "Support".localized
    static let addOrder = "Add Order".localized
    static let addOrderHint = "Add a order and wait for offers!".localized
    static let workField2 = "Work Field".localized
    static let orderTitle = "Order Title".localized
    static let orderDescription = "Order Description".localized
    static let postOffer = "Post Offer".localized
    static let openedMessage = "Opened Message".localized
    static let newMessage = "New Message".localized
    static let sendMessage = "Send Message".localized
    static let messageDescription = "Message Description".localized
    static let supportHint = "We are always here to hear from you!".localized
    static let changeProfileImageHint = "It is preferable that the image be clear and show the details of the logo to better identify the facility...".localized
    static let companyFile = "Company File".localized
    static let manageYourProfile = "Browse and manage your profile".localized
    static let receivedOffers = "Received Offers".localized
    static let acceptRejectOffer = "Accept Or Reject Offer".localized
    static let userType = "User Type".localized
    static let personal = "Personal".localized
    static let company = "Company".localized
    static let imagesRequired = "Images Required".localized
    static let orderType = "Order Type".localized
    static let offerType = "Offer Type".localized
    static let workType = "Work Type".localized
    static let jobOrders = "Job Orders".localized
    static let servicesOrders = "Services Orders".localized
    static let online = "Online".localized
    static let offline = "Offline".localized
    static let personal1 = "Personal1".localized
    static let company1 = "Company1".localized
    static let hourly = "Hourly".localized
    static let daily = "Daily".localized
    static let yearly = "Yearly".localized
    static let limited = "Limited".localized
    static let unlimted = "Unlimted".localized
    static let executionType = "Execution Type".localized
    static let daysNo = "Days No.".localized
    static let employeeNo = "Employee No.".localized
    static let guest = "Guest".localized
    static let password = "Password".localized
    static let forgetPassword = "Forget Password".localized
    static let restorePassword = "Restore password".localized
    static let restorePasswordMessage = "Don't worry, simple steps to recover your account password..".localized
    static let verifyPhoneNumber = "Verify Phone Number".localized
    static let areYouRememberPassword = "Are you remember Password?".localized
    static let backToLogin = "Back To Login".localized
    static let weSendMessageToYou = "We send message to You".localized
    static let createNewPassword = "Create New Password".localized
    static let createNewPasswordHint = "Amazing, now create a new password and please do not share it with anyone.".localized
    static let newPassword = "New Password".localized
    static let confirmNewPassword = "Confirm New Password".localized
    static let confirmChangePassword = "Confirm Change Password".localized
    static let selectLocationHint = "Drop a map pin to your location".localized
    static let selectThisLocation = "Select This Location".localized
    static let skipForLater = "Skip for later".localized
    static let categories = "Categories".localized
    static let completeOrder = "Complete Order".localized
    static let selectedServices = "Selected Services".localized
    static let addNewServices = "Add New Services".localized
    static let addNewLocation = "Add New Location".localized
    static let serviceLocation = "Service Location".localized
    static let attachIllustrativePictures = "Attach illustrative pictures".localized
    static let attachIllustrativePicturesHint = "Click here to attach illustrative pictures of the nature of the problem you are facing and which requires a technician to solve it!".localized
    static let moreDescriptionAboutService = "More description about the service".localized
    static let payment = "Payment".localized
    static let chooseThePaymentMethodThatSuitsYou = "Choose the payment method that suits you".localized
    static let discountCoupun = "Discount Coupun".localized
    static let paymentMethodHint = "Prices do not include spare parts!".localized
    static let paymentMethod = "Payment Method".localized
    static let paymentCompletedSuccessfully = "Payment completed successfully!".localized
    static let paymentCompletedSuccessfullyHint = "The payment process has been completed successfully and you can now follow the status of your order from the orders page.".localized
    static let backToHome = "Back To Home".localized
    static let PaymentProcessWasNotCompleted = "The payment process was not completed!".localized
    static let PaymentProcessWasNotCompletedHint = "Your payment was not completed. Please ensure that there is sufficient balance or contact the bank.".localized
    static let chooseAnotherPaymentMethod = "Choose another payment method".localized
    static let backToOrders = "Back To Orders".localized
    static let continueToOrder = "Continue To Order".localized
    static let orderDetailsHint = "Show Order details and status".localized
    static let detailsOfServiceProvision = "Details of service provision".localized
    static let contactNumber = "Contact Number".localized
    static let wantCompleteOrder = "I want to complete the order!".localized
    static let iWantCancel = "Yes, I want to cancel!".localized
    static let noDataFound = "No data found".localized
    static let profileHint = "Control your profile and data from here!".localized
    static let accountPassword = "Account Password".localized
    static let editPhoneNumber = "Edit Phone Number".localized
    static let accountPasswordHint = "Change your account password in simple and quick steps!".localized
    static let editPhoneNumberHint = "Change your phone number in simple and quick steps!".localized
    static let notificationsHint = "Control the style of receiving notifications “offers, order status, etc.”".localized
    static let contactUsHint = "If you encounter a problem during your journey through the application, we are here for you!".localized
    static let termsHint = "Please review and read the usage policy to avoid any error during your transaction!".localized
    static let privacyHint = "Please review and read the privacy policy to save your data and information!".localized
    static let currentPassword = "Current Password".localized
    static let currentPhoneNumber = "Current Phone Number".localized
    static let newPhoneNumber = "New Phone Number".localized
    static let takeAdvantageOfThePoints = "Take advantage of the points!".localized
    static let deleteAccount = "Delete Account".localized
    static let deleteAccountHint = "Tap to delete your account".localized
    static let deleteAccountQuestion = "Are you sure you want to delete your account?".localized
    static let confirmPassword = "Confirm Password".localized
    static let statistics = "Statistics".localized
    static let addressTitleRequired = "Address Title Required".localized
    static let noAddressesFound = "No Addresses Found".localized
    static let detailsOfServiceProvider = "Details Of Service Provider".localized
    static let deleteAccountMessage = "Are you sure you want to delete your account, after account deletition, you can create and login again.".localized
    static let showAll = "Show All".localized
    static let walletAmount = "Amount".localized
    static let checkCoupon = "Check Coupon".localized
    static let finicialData = "Finicial Data".localized
    static let myPoints = "My Points".localized
    static let myPointsHit = "Check your points and change it with our services".localized
    static let walletHit = "You can use wallet as payment method in the app".localized
    static let payOnline = "Pay Online".localized
    static let paymentByWallet = "Pay By Wallet".localized
    static let myLocation = "My Location".localized
    static let more = "More".localized
    static let searchForServices = "Search by name or service type ..".localized
    static let quantity = "Quantity".localized
    static let currentLocation = "Current Location".localized
    static let prefinished = "Prefinished".localized
    static let points = "Points".localized
    static let point = "Point".localized
    static let howWork = "How to work?".localized
    static let orderAndGatherPoints = "Order And Gather Points".localized
    static let orderAndGatherPointsHint = "With every completed and paid order, you will receive 3 points for every 1 riyal you spend on your order.".localized
    static let discoverProductsAndServices = "Discover Products And Services".localized
    static let discoverProductsAndServicesHint = "For every 1,500 points you get, you can get a discount on your order from selected restaurants and stores in your area.".localized
    static let readyToReplace = "Ready To Replace".localized
    static let readyToReplaceHint = "Redeem your points for discounts through the payment page when placing the order. Points will expire after 90 days.".localized
    static let payCash = "Pay Cash".localized
    static let pointsValue = "Points Value".localized
    static let pointsValueHint = "Do you want to rechange your points?".localized
    static let completeProfileMessage = "Please complete your profile to continue to add an order".localized
    static let tamaraErrorMessage = "An error occured, Please try again".localized
    static let newFinicialData = "New Finicial Data".localized
    static let discoverApp = "Discover App".localized
    static let loginRegister = "Login/ New Account".localized
    static let loginHint = "Enter required data to access your account ...".localized
    static let registerHint = "Enter your phone number to to create account ...".localized
    static let smsVerHint = "We sent code to your phone number".localized
    static let sendLoginCode = "Send login code".localized
    static let enterOTP = "Enter 'OTP' Code".localized
    static let dob = "Birth of Date".localized
    static let wishes = "Wishes".localized
    static let cart = "Cart".localized
    static let searchForProduct = "Search for product".localized
    static let publicCategories = "Public Categories".localized
    static let myWishes = "My Wishes!".localized
    static let myWishesLists = "My Wishes Lists".localized
    static let friendsWishes = "Friends Wishes".localized
    static let completeYourPurchaseNow = "Complete your purchase now!".localized
    static let successPayment = "Success Payment".localized
    static let successPaymentTitle = "Payment Was Success".localized
    static let successPaymentMsg = "You have completed your contribution to fulfilling the wish of".localized
    static let discoverCategories = "Discover Categories".localized
    static let eventReminders = "Event Reminders".localized
    static let way = "Way".localized
    static let unconfirmed = "Unconfirmed".localized
    static let upcomingReminders = "Upcoming Reminders".localized
    static let addNewReminder = "Add New Reminder".localized
    static let specialCategories = "Special Categories".localized
    static let sendGiftNow = "Send Gift Now".localized
    static let nameOfPerson = "Name of the person to whom it is sent".localized
    static let friendMsg = "Didn't find your friend? Send an invitation now!".localized
    static let friendWishes = "Friend Wishes".localized
    static let publicLists = "Public Lists".localized
    static let retailSystem = "Retail System".localized
    static let addToCart = "Add To Cart".localized
    static let deleteCart = "Delete Cart".localized
    static let deleteCartConfirmation = "Are you want to delete cart!".localized
    static let deleteCartItemConfirmation = "Are you want to delete this item from cart!".localized
    static let explor = "Explor".localized
    static let favourite = "Favourite".localized
    static let addToMyWishes = "Add To My Wishes".localized
    static let productSummary = "Product Summary".localized
    static let orderSummary = "Order Summary".localized
    static let cartTotalTax = "Tax:".localized
    static let cartTotalDeliveryCost = "Delivery Cost:".localized
    static let cartTotalExpressCost = "Express Cost:".localized
    static let cartTotalTotalPrice = "Total Price:".localized
    static let cartTotalTotalDiscount = "Total Discount:".localized
    static let cartTotalFinalTotal = "Final Total:".localized
    static let productDetails = "Product Details".localized
    static let createNewGroup = "Create New Group".localized
    static let groupName = "Group Name".localized
    static let saveGroup = "Save Group".localized
    static let newGroup = "New Group".localized
    static let clickToCreateNewGroup = "Click to create new group".localized
    static let privacy = "Privacy".localized
    static let publicGroup = "Public".localized
    static let privateGroup = "Private".localized
    static let addFriend = "Add Friend".localized
    static let add = "Add".localized
    static let reminderTitle = "Reminder Title".localized
    static let reminderDate = "Reminder Date".localized
    static let reminderBefor = "Reminder Befor".localized
    static let saveReminder = "Save Reminder".localized
    static let userProducts = "User Products".localized
    static let addUserProducts = "Add User Products".localized
    static let productTitle = "Product Title".localized
    static let productName = "Product Name".localized
    static let note = "Note".localized
    static let images = "Images".localized
    static let iban = "iban".localized
    static let addPhotos = "Add Photos".localized
    static let selectImages = "Select Images".localized
    static let events = "Events".localized
    static let needsOffer = "Needs Offer".localized
    static let submit = "Submit".localized
    static let VIPGiftEvent = "VIP Gift and Events".localized
    static let selectEvents = "Select Events".localized
    static let gender = "Gender".localized
    static let male = "Male".localized
    static let female = "Female".localized
    static let reject = "Reject".localized
    static let goToLogin = "Go To Login".localized
    static let pleaseLogin = "Please login to see the contents".localized
    static let VIPGift = "VIP Gift".localized
    static let eventsPreparing = "Events".localized
    static let estimatedAmount = "Estimated amount".localized
    static let cartMessage = "Your order has been successfully added to the cart, do you want to go to the cart?".localized
    static let payMada = "Pay Mada".localized
    static let payTamara = "Pay Tamara".localized

}

enum LocalizedError {
    static let noInternetConnection = "No internet connection. Please check your network.".localized
    static let unknownNetworkError = "An unknown network error occurred.".localized
    static let badRequest = "Bad request. Please check your input.".localized
    static let unauthorized = "Unauthorized. Please log in.".localized
    static let resourceNotFound = "Resource not found.".localized
    static let serverError = "Server error. Please try again later.".localized
    static let unknownError = "An unknown error occurred.".localized
    static let invalidData = "Invalid data received.".localized
    static let decodingError = "Decoding error".localized
    static let invalidURL = "Invalid URL".localized
    static let invalidToken = "Invalid Token".localized
    static let responseValidationFailed = "Response validation failed".localized
}
