import SwiftUI
import CoreLocation
import PopupView
import MoyasarSdk

struct CheckoutView: View {
    let orderData: OrderData

    @EnvironmentObject var appRouter: AppRouter
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var couponCode: String = ""
    @State private var selectedPaymentType: PaymentType? = nil
    @State private var couponMessage: String? = nil
    @State private var isLoading = false
    @State private var loadingMessage: String? = nil
    @State private var showPaymentError = false

    var service: SelectedServiceItem { orderData.services.first! }
    var address: AddressItem? { orderData.address }
    var userLocation: CLLocationCoordinate2D? { orderData.userLocation?.coordinate }
    var notes: String { orderData.notes ?? "" }
    var date: String { orderData.date ?? "" }
    var time: String { orderData.time ?? "" }

    var totalBeforeDiscount: Double {
        orderViewModel.coupon?.total_before_tax ?? (service.service.price ?? 0) * Double(service.quantity)
    }
    var discountValue: Double {
        orderViewModel.coupon?.discount ?? 0
    }
    var taxAmount: Double {
        orderViewModel.coupon?.total_tax ?? (totalBeforeDiscount * 0.15)
    }
    var totalAmount: Double {
        orderViewModel.coupon?.final_total ?? max(0, totalBeforeDiscount - discountValue + taxAmount)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                couponSection
                Divider().padding(.vertical, 4)
                summarySection
                Divider().padding(.vertical, 4)
                paymentSection
                Divider().padding(.vertical, 4)
                payBar
            }
            .padding()
        }
        .background(Color.background())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        appRouter.navigateBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading) {
                        Text("الدفع")
                            .font(.title2.bold())
                        Text("اختر طريقة الدفع المناسبة لك")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            isLoading ? AnyView(
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView(loadingMessage ?? "جاري التحميل...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            ) : AnyView(EmptyView())
        )
        .popup(isPresented: $showPaymentError) {
            PaymentErrorPopup(
                message: orderViewModel.errorMessage ?? "حدث خطأ أثناء الدفع. حاول مرة أخرى.",
                onClose: { showPaymentError = false }
            )
            .padding(.horizontal, 20)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.48))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
    }

    // MARK: - Coupon Section
    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TextField("كوبون الخصم", text: $couponCode)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.gray.opacity(0.07))
                    .cornerRadius(10)
                    .font(.system(size: 16, weight: .medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.16), lineWidth: 1)
                    )
                Button(action: checkCoupon) {
                    Text("فحص")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(width: 80, height: 48)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.blue.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .frame(height: 48)
            .clipped()
            if let message = couponMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(discountValue > 0 ? .green : .red)
                    .padding(.top, 2)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("البيانات المالية")
                .font(.headline)
            financialRow(title: "المبلغ قبل الضريبة", value: totalBeforeDiscount)
            financialRow(title: "قيمة الخصم", value: discountValue)
            financialRow(title: "مبلغ الضريبة", value: taxAmount)
            financialRow(title: "المبلغ الاجمالي", value: totalAmount, isBold: true)
        }
    }

    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("طريقة الدفع").font(.headline)
            LazyVStack(spacing: 14) {
                ForEach(PaymentType.allCases) { method in
                    paymentCard(method: method)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func paymentCard(method: PaymentType) -> some View {
        let isSelected = selectedPaymentType == method
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedPaymentType = method
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: method.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(.trailing, 2)
                VStack(alignment: .leading, spacing: 5) {
                    Text(method.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Text(method.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .transition(.scale)
                            .font(.system(size: 28))
                    }
                }
                .frame(width: 32, height: 32)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(method.cardColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.19), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.13) : Color.clear, radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var payBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("المجموع")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(totalAmount, specifier: "%.2f") SAR")
                    .fontWeight(.bold)
            }
            Button(action: payNow) {
                Text("ادفع الآن")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPaymentType == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selectedPaymentType == nil || isLoading)
        }
        .padding(.top)
    }

    func financialRow(title: String, value: Double, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .font(.subheadline)
            Spacer()
            Text("\(value, specifier: "%.2f") SAR")
                .font(.subheadline)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundColor(isBold ? .black : .primary)
        }
        .padding(.vertical, 4)
    }

    func checkCoupon() {
        guard !couponCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            couponMessage = "يرجى إدخال كود الكوبون"
            return
        }
        loadingMessage = "جارٍ التحقق من الكوبون..."
        isLoading = true
        orderViewModel.checkCoupon(params: [
            "coupun": couponCode,
            "extra": [
                [
                    "service_id": service.service.id,
                    "qty": service.quantity
                ]
            ]
        ]) {
            couponMessage = orderViewModel.coupon != nil ? "تم تطبيق الكوبون!" : "كوبون غير صالح"
            isLoading = false
        }
    }

    func payNow() {
        guard let paymentMethod = selectedPaymentType else { return }
        switch paymentMethod {
        case .cash:
            addOrder(paymentType: .cash)
        case .moyasar:
            startMoyasarPayment(amount: totalAmount)
        }
    }

    func startMoyasarPayment(amount: Double) {
        // ضع هنا كود تكامل Moyasar المناسب حسب الـ SDK أو WebView الخاص بك
        loadingMessage = "جاري معالجة الدفع..."
        isLoading = true
        // عند النجاح:
        // addOrder(paymentType: .moyasar)
        // عند الفشل:
        // showPaymentError = true
        // orderViewModel.errorMessage = "تعذر معالجة الدفع"
        // isLoading = false
    }

    func addOrder(paymentType: PaymentType) {
        let params = orderData.toJson(
            couponCode: couponCode,
            paymentType: paymentType.rawValue
        )
        orderViewModel.addOrder(params: params) { id, msg in
            if id.isEmpty {
                orderViewModel.errorMessage = msg
                showPaymentError = true
            } else {
                appRouter.navigate(to: .paymentSuccess)
            }
        }
    }
}

#Preview {
    // خدمة واحدة فقط حسب الجيسون
    let subCategory = SubCategory(
        id: "6594394a616885647682c071",
        price: 100,
        title: "خدمة التنظيف",
        description: "تنظيف عميق",
        image: nil
    )
    let selectedService = SelectedServiceItem(
        service: subCategory,
        quantity: 2,
        categoryId: "64a9938c49c9b40021aa8126",
        subCategoryId: "6594394a616885647682c071",
        categoryTitle: "خدمات عامة",
        subCategoryTitle: "تنظيف"
    )
    let address = AddressItem(
        streetName: "te",
        floorNo: "1",
        buildingNo: "2",
        flatNo: "3",
        type: "home",
        createAt: nil,
        id: "addr1",
        title: "title",
        lat: 18.2418308,
        lng: 42.4660169,
        address: "العنوان هنا",
        userId: "user1",
        discount: nil
    )
    let orderData = OrderData(
        services: [selectedService],
        address: address,
        userLocation: nil, // أو Location(lat: 18.2418308, lng: 42.4660169) لو بدك "موقعي الحالي"
        notes: "notes",
        date: "2023-01-01",
        time: "10:00"
    )
    return CheckoutView(orderData: orderData)
        .environmentObject(AppRouter())
}

struct PaymentErrorPopup: View {
    let message: String
    var onClose: () -> Void

    @State private var appear = false
    @State private var iconGlow = false
    @State private var buttonPressed = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.28))
                    .frame(width: 80, height: 80)
                    .blur(radius: iconGlow ? 16 : 4)
                    .scaleEffect(iconGlow ? 1.15 : 0.96)
                    .opacity(iconGlow ? 0.55 : 0.35)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: iconGlow)

                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.25), radius: 12, x: 0, y: 2)
            }

            Text("خطأ في الدفع")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .scaleEffect(appear ? 1 : 0.92)
                .animation(.easeOut(duration: 0.5), value: appear)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .opacity(appear ? 1 : 0)
                .animation(.easeIn(duration: 0.8).delay(0.2), value: appear)

            Button(action: {
                buttonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    buttonPressed = false
                    onClose()
                }
            }) {
                Text("حسناً")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(buttonPressed ? Color.red.opacity(0.7) : Color.red.opacity(0.90))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .scaleEffect(buttonPressed ? 0.96 : 1)
            }
            .padding()
        }
        .padding(.vertical, 34)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.97))
                .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 6)
        )
        .scaleEffect(appear ? 1 : 0.84)
        .opacity(appear ? 1 : 0)
        .animation(.spring(response: 0.48, dampingFraction: 0.85), value: appear)
        .onAppear {
            appear = true
            iconGlow = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
        }
    }
}
