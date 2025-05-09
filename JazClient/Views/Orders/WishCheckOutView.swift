//
//  WishCheckOutView.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI
import PopupView
import MapKit

struct WishCheckOutView: View {
    @State private var payCash: Bool = false
    @State private var payOnline: Bool = false
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var isShowingAddress = false
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @State private var addressTitle = ""
    @State private var streetName = ""
    @State private var buildingNo = ""
    @State private var floorNo = ""
    @State private var flatNo = ""
    @State private var servicePlace: PlaceType = .home
    @State private var locations: [Mark] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 24.7136,
            longitude: 46.6753
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 5,
            longitudeDelta: 5
        )
    )
    @State private var isShowingMap = false
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @StateObject private var cartViewModel = CartViewModel(errorHandling: ErrorHandling())
    let wishId: String?
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @StateObject var wishViewModel = WishesViewModel(errorHandling: ErrorHandling())
    @State var currentUserLocation: AddressItem?
    @StateObject private var locationManager2 = LocationManager2()
    @State private var selectedPurchaseType: PurchaseType = .myself
    @State private var isAddressBook = false
    @State private var coupon: String = ""
    @State private var notes: String = LocalizedStringKey.notes
    @State var placeholderString = LocalizedStringKey.notes

    @State private var selectedAddress: AddressItem? {
        didSet {
            // Update the region and other address-related fields when a new address is selected
            if let selectedAddress = selectedAddress {
                streetName = selectedAddress.streetName ?? ""
                floorNo = selectedAddress.floorNo ?? ""
                buildingNo = selectedAddress.buildingNo ?? ""
                flatNo = selectedAddress.flatNo ?? ""
                
                // Update the region based on the selected address coordinates
                region.center = CLLocationCoordinate2D(latitude: selectedAddress.lat ?? 0, longitude: selectedAddress.lng ?? 0)
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                // Append a new Mark with the selected address coordinates and title
                let newLocation = Mark(
                    title: selectedAddress.title ?? "",
                    coordinate: CLLocationCoordinate2D(latitude: selectedAddress.lat ?? 0, longitude: selectedAddress.lng ?? 0),
                    show: true,
                    imageName: "ic_logo",
                    isUserLocation: false
                )

                locations.removeAll()
                locations.append(newLocation)
            }
        }
    }
        
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
//                    CouponCheckSection(coupon: $coupon) {
//                        // Action to perform when check coupon button is tapped
//                        checkCartCoupun()
//                    }

                    WishProductSummarySection(product: wishViewModel.wish?.product_id)
                    
                    AddressSelectionView(addressTitle: $addressTitle, streetName: $streetName, isShowingMap: $isShowingMap, servicePlace: $servicePlace, locations: $locations, region: $region, isShowingAddress: $isShowingAddress, userLocation: $userLocation, purchaseType: $selectedPurchaseType)
                        .disabled(orderViewModel.isLoading)

                    NotesView(notes: $notes, placeholder: placeholderString)
                        .disabled(orderViewModel.isLoading)

//                    PaymentInformationSection(payCash: $payCash, payOnline: $payOnline)
                    
//                    PurchaseTypeSection(purchaseType: $selectedPurchaseType)

//                    if let cartTotal = cartViewModel.cartTotal {
//                        OrderSummarySection(cartTotal: cartTotal)
//                    }
                }
                .padding()
            }
            
            VStack {
                if orderViewModel.isLoading {
                    LoadingView()
                }
                
                Button(action: {
                    // Place order logic
                    addOrder()
                }) {
                    HStack {
                        Text("اطلب الان")
                    }
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
                .disabled(orderViewModel.isLoading)
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text(LocalizedStringKey.payment)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .popup(isPresented: $isShowingAddress) {
            let model = CustomModel(
                title: LocalizedStringKey.addressBook,
                content: "",
                items: userViewModel.addressBook ?? [],
                onSelect: { item in
                    DispatchQueue.main.async {
                        selectedAddress = item
                        addressTitle = item.title ?? ""
                        
                        isShowingAddress = false
                    }
            })
            
            AddressListView(customModel: model, currentUserLocation: $currentUserLocation, isAddressBook: $isAddressBook)

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
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            MessageAlertObserverView(
                message: $cartViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onChange(of: locationManager2.location) { value in
            if let location = locationManager2.location {
                print("New Location: \(location)")
                currentUserLocation = AddressItem(
                    streetName: "",
                    floorNo: "",
                    buildingNo: "",
                    flatNo: "",
                    type: "موقعي الحالي",
                    createAt: "",
                    id: "",
                    title: "موقعي الحالي",
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude,
                    address: locationManager2.address,
                    userId: "",
                    discount: 0
                )
            }
        }
        .onAppear {
            wishViewModel.getWish(id: wishId ?? "")
            userViewModel.getAddressByType(type: servicePlace.rawValue)
            cartViewModel.cartTotal {
                //
            }
            locationManager2.startUpdatingLocation()
        }
    }
}

extension WishCheckOutView {
    func addOrder() {
        // Check if the selected address is valid based on the purchase type
        guard let selectedAddress = selectedAddress else {
            orderViewModel.errorMessage = "الرجاء اختيار عنوان"
            return
        }

        let currentDate = Date()
        let formattedDate = currentDate.formattedDateString()
        let formattedTime = currentDate.formattedTimeString()

        var params: [String: Any] = [
            "couponCode": "",
            "PaymentType": "wish",
            "dt_date": formattedDate,
            "dt_time": formattedTime,
            "address": selectedAddress.address ?? "",
            "lat": selectedAddress.lat ?? 0.0,
            "lng": selectedAddress.lng ?? 0.0,
            "is_address_book": isAddressBook,
            "OrderType": 3,
            "wish_id": wishId ?? "",
            "notes": notes,
        ]
        
        if isAddressBook {
            params["address_book"] = selectedAddress.id ?? ""
        }
        
        wishViewModel.addOrderWish(params: params) {
            appRouter.navigate(to: .paymentSuccess)
        }
    }
    
    func checkCartCoupun() {
        let params: [String: Any] = [
            "coupon": $coupon,
            "is_address_book": isAddressBook,
            "address_book": isAddressBook ? selectedAddress?.id ?? "" : "",
            "lat": selectedAddress?.lat ?? 0.0,
            "lng": selectedAddress?.lng ?? 0.0,
        ]

        cartViewModel.checkCartCoupun(params: params)
    }
}

struct WishProductSummarySection: View {
    let product: Products?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.productSummary)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            if let product = product {
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.name ?? "")
                        HStack {
                            Text(LocalizedStringKey.quantity)
                            Text("1")
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Text(String(format: "%.2f", product.sale_price ?? 0))
                            Text(LocalizedStringKey.sar)
                        }
                    }
                }
                .customFont(weight: .regular, size: 15)
                .foregroundColor(.black121212())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

