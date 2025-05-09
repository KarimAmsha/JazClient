//
//  OrderDetailsView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI
import MapKit

struct OrderDetailsView: View {
    let items = Array(1...5)
    @State private var quantities: [Int] = Array(repeating: 1, count: 10)
    @State private var quantity: Int = 1
    @State var selectedItems: [String] = Array(repeating: "", count: 10)
    @EnvironmentObject var appRouter: AppRouter
    @State private var orderStatus: OrderStatus = .accepted
    let orderID: String
    @StateObject private var viewModel = OrderViewModel(errorHandling: ErrorHandling())

    var isSelected: Bool {
        selectedItems.contains { $0 == "" }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    LoadingView()
                }

                ScrollView(showsIndicators: false) {
                    if let items = viewModel.orderDetailsItem?.items?.items {
                        ForEach(items.indices, id: \.self) { index in
                            let item = items[index]
                            
                            HStack {
                                AsyncImageView(
                                    width: 60,
                                    height: 60,
                                    cornerRadius: 10,
                                    imageURL: item.image?.toURL(),
                                    placeholder: Image(systemName: "photo"),
                                    contentMode: .fill
                                )
                                

                                VStack(alignment: .leading) {
                                    Text(item.name ?? "")
                                    
                                    if let variationName = item.variation_name, !variationName.isEmpty {
                                        Text("النوع: \(variationName)")
                                            .customFont(weight: .regular, size: 14)
                                            .foregroundColor(.gray)
                                    }

                                    HStack {
                                        Text(LocalizedStringKey.quantity)
                                        Text(item.qty?.toString() ?? "")
                                    }
                                }
                                
                                Spacer()
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(String(format: "%.2f", item.sale_price ?? 0))
                                        Text(LocalizedStringKey.sar)
                                    }
                                }
                            }
                            .customFont(weight: .bold, size: 14)
                            .foregroundColor(.primaryBlack())
                        }
                    }
                    
                    CustomDivider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(viewModel.orderDetailsItem?.items?.formattedCreateDate ?? "")
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.primaryBlack())
                            
                            Spacer()
                            
                            Text(viewModel.orderDetailsItem?.items?.orderStatus?.value ?? "")
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.orangeF7941D())
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orangeF7941D().opacity(0.2).clipShape(Capsule()))
                        }
                    }
                    
                    CustomDivider()
                    
                    if let orderStatus = viewModel.orderDetailsItem?.items?.orderStatus {
                        OrderTimelineView(
                            orderStatus: orderStatus,
                            formattedCreateDate: viewModel.orderDetailsItem?.items?.formattedCreateDate ?? ""
                        )
                    }
                    
                    CustomDivider()

                    if let orderDetailsItem = viewModel.orderDetailsItem {
                        OrderDetailsSummarySection(item: orderDetailsItem)
                    }
                    
                    CustomDivider()

                    if let orderDetails = viewModel.orderDetailsItem?.items {
                        OrderDetailsLocationSection(orderDetails: orderDetails)
                    }

                    CustomDivider()

                    if let orderType = viewModel.orderDetailsItem?.items?.orderType {
                        OrderDetailsTypeSection(orderType: orderType)
                    }

                    Spacer()
                }
                
                VStack {
                    CustomDivider()
                    HStack {
                        HStack(spacing: 16) {
                            if viewModel.orderDetailsItem?.items?.orderStatus == .new || viewModel.orderDetailsItem?.items?.orderStatus == .accepted {
                                // Cancel Order Button
                                Button(action: {
                                    presentCancellationReasonPopup(status: .canceled)
                                }) {
                                    Text(LocalizedStringKey.cancelOrder)
                                }
                                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .regular, background: .orangeFCE5E5(), foreground: .redE50000(), height: 48, radius: 8))
                            }

                            if viewModel.orderDetailsItem?.items?.orderStatus == .finished {
                                // Review Order Button
                                Button(action: {
                                    if let orderId = viewModel.orderDetailsItem?.items?.id {
                                        appRouter.navigate(to: .addReview(orderId))
                                    }
                                }) {
                                    Text(LocalizedStringKey.addReview)
                                }
                                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .green0C9D61(), foreground: .white, height: 48, radius: 8))
                            }
//                            
//                            if viewModel.order?.orderStatus == .updated {
//                                // Update Order Button
//                                Button(action: {
//                                    isShowingPaymentMethods.toggle()
//                                }) {
//                                    Text(LocalizedStringKey.payNow)
//                                }
//                                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .green0C9D61(), foreground: .white, height: 48, radius: 8))
//                            }
                        }
                        .customFont(weight: .bold, size: 14)
                    }
                    .padding(24)
                    .background(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: -3)
                    )
                }
                .opacity(viewModel.orderDetailsItem?.items?.orderStatus == .new || viewModel.orderDetailsItem?.items?.orderStatus == .accepted || viewModel.orderDetailsItem?.items?.orderStatus == .updated || viewModel.orderDetailsItem?.items?.orderStatus == .finished ? 1 : 0)
            }
        }
        .padding(16)
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

                    Text(LocalizedStringKey.orderDetails)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onAppear {
            getOrderDetails()
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
    
    func color(forOrderStatuses targetStatuses: [OrderStatus], currentStatus: OrderStatus) -> Color {
        return targetStatuses.contains(currentStatus) ? .orangeD67200() : .grayD2D2D2()
    }
    
    func imageColor(forOrderStatuses targetStatuses: [OrderStatus], currentStatus: OrderStatus) -> Color {
        return targetStatuses.contains(currentStatus) ? .orangeD67200() : .grayA5A5A5()
    }

    func colorText(forOrderStatuses targetStatuses: [OrderStatus], currentStatus: OrderStatus) -> Color {
        return targetStatuses.contains(currentStatus) ? .black1C1C28() : .grayA5A5A5()
    }
}

#Preview {
    OrderDetailsView(orderID: "")
}

extension OrderDetailsView {
    func getOrderDetails() {
        viewModel.getOrderDetails(orderId: orderID) {
        }
    }

    private func canelOrder() {
        let alertModel = AlertModel(
            icon: "ic_failed",
            title: LocalizedStringKey.cancelationTitle,
            message: LocalizedStringKey.cancelationMessage,
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.wantCompleteOrder,
            cancelTitle: LocalizedStringKey.iWantCancel,
            hidesIcon: false,
            hidesCancel: false,
            onOKAction: {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    presentCancellationReasonPopup(status: .canceled)
                }
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.cancelOrder(alertModel)) // Present the cancellation popup
    }
    
    private func updateOrderStatus(status: OrderStatus, canceledNote: String = "") {
        let params: [String: Any] = [
            "status": status.rawValue,
            "canceled_note": canceledNote,
        ]
        
        viewModel.updateOrderStatus(orderId: orderID, params: params, onsuccess: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                getOrderDetails()
            })
        })
    }

    private func presentCancellationReasonPopup(status: OrderStatus) {
        let alertModel = AlertModelWithInput(
            title: LocalizedStringKey.logout,
            content: LocalizedStringKey.description,
            hideCancelButton: false,
            onOKAction: { content in
                updateOrderStatus(status: status, canceledNote: content)
                appRouter.dismissPopup()
            },
            onCancelAction: {
                appRouter.dismissPopup()
            }
        )
        
        appRouter.togglePopup(.inputAlert(alertModel))
    }
}

struct OrderDetailsSummarySection: View {
    let item: OrderDetailsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.orderSummary)
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            if let tax = item.tax {
                orderSummaryRow(title: LocalizedStringKey.tax, amount: tax)
            }
            
//            if let deliveryCost = cartTotal.deliveryCost {
//                orderSummaryRow(title: LocalizedStringKey.cartTotalDeliveryCost, amount: deliveryCost)
//            }
            
//            if let expressCost = cartTotal.expressCost {
//                orderSummaryRow(title: LocalizedStringKey.cartTotalExpressCost, amount: expressCost)
//            }
            
            if let totalPrice = item.totalPrice {
                orderSummaryRow(title: LocalizedStringKey.price, amount: totalPrice)
            }
            
//            if let totalDiscount = cartTotal.total_discount {
//                orderSummaryRow(title: LocalizedStringKey.cartTotalTotalDiscount, amount: totalDiscount)
//            }
            
            if let finalTotal = item.finalTotal {
                orderSummaryRow(title: LocalizedStringKey.total, amount: finalTotal)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func orderSummaryRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(LocalizedStringKey.sar) \(amount, specifier: "%.2f")")
                .environment(\.locale, .init(identifier: "en_US"))
        }
        .customFont(weight: title == LocalizedStringKey.total ? .bold : .regular, size: 15)
        .foregroundColor(.black121212())
    }
}

struct OrderDetailsLocationSection: View {
    @State private var isShowingMap = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    let orderDetails: OrderDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(LocalizedStringKey.geographicalLocation)
                    .customFont(weight: .bold, size: 16)
                    .foregroundColor(.black222020())

                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(orderDetails.address ?? "")
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.black222020())

                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [orderAnnotation]) { location in
                        MapAnnotation(
                            coordinate: location.coordinate,
                            anchorPoint: CGPoint(x: 0.5, y: 0.7)
                        ) {
                            VStack {
                                Text("موقع الطلب")
                                    .customFont(weight: .bold, size: 14)
                                    .foregroundColor(.black131313())
                                Image("ic_pin")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .disabled(true)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "square.arrowtriangle.4.outward")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    isShowingMap = true
                                }
                        }
                    }
                    .padding(10)
                }
                .frame(height: 94)
                .cornerRadius(8)
            }
        }
        .padding()
        .sheet(isPresented: $isShowingMap) {
            ShowOrderOnMapView(region: $region, latitude: orderDetails.lat ?? 0.0, longitude: orderDetails.lng ?? 0.0, isShowingMap: $isShowingMap)
        }
        .onAppear {
            updateRegion()
        }
    }

    private var orderAnnotation: OrderLocationAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: orderDetails.lat ?? 0.0, longitude: orderDetails.lng ?? 0.0)
        return OrderLocationAnnotation(title: "موقع الطلب", coordinate: coordinate)
    }
    
    private func updateRegion() {
        let latitude = orderDetails.lat ?? 24.7136 // default to Riyadh if not available
        let longitude = orderDetails.lng ?? 46.6753 // default to Riyadh if not available
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}

struct OrderLocationAnnotation: Identifiable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
}

struct OrderDetailsTypeSection: View {
    let orderType: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedStringKey.orderType)
                .customFont(weight: .bold, size: 16)
                .foregroundColor(.black222020())
            
            HStack {
                if let orderType = orderType {
                    switch orderType {
                    case 1:
                        Text("امنية لي")
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.black222020())
                    case 2:
                        Text("هدية لصديقي")
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.black222020())
                    case 3:
                        Text("هدية نظام قطة من اصدقائي")
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.black222020())
                    default:
                        Text("نوع غير معروف")
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.black222020())
                    }
                } else {
                    Text("نوع غير معروف")
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black222020())
                }

                Spacer()
            }
        }
        .padding()
    }
}

struct OrderTimelineView: View {
    let orderStatus: OrderStatus
    let formattedCreateDate: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -4) {
                createTimelineStep(
                    status: .accepted,
                    title: "تم استلام الطلب",
                    description: "لقد تم استلام طلبك بتاريخ \(formattedCreateDate)"
                )
                
                createTimelineLine(isActive: isStepActive(for: .started))
                
                createTimelineStep(
                    status: .started,
                    title: "تم تأكيد طلبك",
                    description: "لقد تم بتأكيد طلبك ---"
                )
                
                createTimelineLine(isActive: isStepActive(for: .way))
                
                createTimelineStep(
                    status: .way,
                    title: "خرج للتوصيل",
                    description: "لقد خرج طلبك للتوصيل ---"
                )
                
                createTimelineLine(isActive: isStepActive(for: .progress))
                
                createTimelineStep(
                    status: .progress,
                    title: "تم التسليم بنجاح!",
                    description: "لقد تم تسليم طلبك بنجاح ---"
                )
            }
            
            Spacer()
        }
    }

    private func createTimelineStep(status: OrderStatus, title: String, description: String) -> some View {
        HStack {
            Image(getImageName(for: status))
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(isStepActive(for: status) ? .primary() : .gray)
            VStack(alignment: .leading) {
                Text(title)
                Text(description)
            }
            .customFont(weight: .bold, size: 12)
            .foregroundColor(isStepActive(for: status) ? .black1C1C28() : .grayA5A5A5())
        }
        .padding(.leading, 13)
    }

    private func createTimelineLine(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? Color.orangeCA5D08() : Color.orangeF6E5D0())
            .frame(width: 5, height: 40)
            .cornerRadius(2)
            .padding(.leading, 20)
    }

    private func getImageName(for status: OrderStatus) -> String {
        return isStepActive(for: status) ? "ic_circle_fill" : "ic_circle"
    }

    private func isStepActive(for status: OrderStatus) -> Bool {
        let statusSequence: [OrderStatus] = [
            .accepted, .started, .way, .progress, .updated, .prefinished, .finished
        ]
        
        guard let currentIndex = statusSequence.firstIndex(of: orderStatus),
              let stepIndex = statusSequence.firstIndex(of: status) else {
            return false
        }
        
        return currentIndex >= stepIndex
    }
}
