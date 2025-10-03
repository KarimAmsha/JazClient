import SwiftUI
import CoreLocation
import PopupView
import MoyasarSdk
import PassKit

enum MoyasarEnvironment {
    case test, production

    var apiKey: String {
        switch self {
        case .test:
            return "pk_test_jgJzVgzn4VX3W1bCkdGMr3hosY68uqykTc4DyTvw"
        case .production:
            return "pk_live_UdFp95AdrJMXDixLqnUKWAa3AfD4QJBv6aT6Zfw2"
        }
    }
}

struct CheckoutView: View {
    let orderData: OrderData

    @EnvironmentObject var appRouter: AppRouter
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var couponCode: String = ""
    @State private var selectedPaymentType: PaymentType? = nil
    @State private var couponMessage: String? = nil
    @State private var loadingMessage: String? = nil
    @State private var showPaymentError = false

    // Apple Pay handler/state
    @State private var applePayHandler: ApplePayPaymentHandler?
    @State private var isApplePayPresented = false

    // لمفتاح ميسرة
    let apiKey = MoyasarEnvironment.test.apiKey   // أو .production حسب البيئة

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
    @State private var showCardSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                couponSection
                Divider().padding(.vertical, 4)
                summarySection
                Divider().padding(.vertical, 4)
                paymentSection
                Divider().padding(.vertical, 4)
                if orderViewModel.isLoading {
                    LoadingView()
                }
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
                        handleBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .customFont(weight: .bold, size: 18)
                            .foregroundColor(.black)
                    }
                    VStack(alignment: .leading) {
                        Text("الدفع")
                            .customFont(weight: .bold, size: 18)
                        Text("اختر طريقة الدفع المناسبة لك")
                            .foregroundColor(.gray)
                            .customFont(weight: .regular, size: 14)
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
            orderViewModel.isLoading ? AnyView(
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
                message: (orderViewModel.errorMessage?.decodedFromURLEncoding())
                    ?? "حدث خطأ أثناء الدفع. حاول مرة أخرى.",
                onClose: { showPaymentError = false }
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8) // مسافة إضافية داخلية
        } customize: {
            $0
                // Floater مع مسافة رأسية ليبتعد عن الـ Home Indicator
                .type(.floater(verticalPadding: 24))
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.48))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .sheet(isPresented: $showCardSheet) {
            ZStack(alignment: .top) {
                // الخلفية مع ظل خفيف
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // شريط علوي احترافي
                    HStack {
                        Text("إدخال بيانات البطاقة")
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: { showCardSheet = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 28, weight: .semibold))
                                .padding(4)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        Color(.systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .black.opacity(0.07), radius: 5, y: 2)
                    )

                    Divider().padding(.horizontal, 12)

                    // محتوى البطاقة
                    VStack(spacing: 0) {
                        CreditCardView(request: createPaymentRequest()) { result in
                            handleMoyasarResult(result)
                            showCardSheet = false
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 28)
                        Spacer()
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 6)
                )
                .padding(.top, 18)
            }
            .presentationDetents([.fraction(0.72), .large]) // إذا متاح في نسختك
        }
        .onDisappear {
            // في حال غادرت الشاشة و Apple Pay لا يزال معروضاً، اغلقه
            if isApplePayPresented {
                applePayHandler?.cancel()
            }
        }
    }

    // MARK: - Moyasar Integration

    func createPaymentRequest() -> PaymentRequest {
        do {
            return try PaymentRequest(
                apiKey: apiKey,
                amount: Int(totalAmount * 100), // بالهللات
                currency: "SAR",
                description: "طلب خدمة",
                metadata: [:]
            )
        } catch {
            fatalError("فشل في إنشاء PaymentRequest: \(error.localizedDescription)")
        }
    }

    func handleMoyasarResult(_ result: PaymentResult) {
        switch result {
        case let .completed(payment):
            if payment.status == .paid {
                // نجح الدفع بالبطاقة
                addOrder(paymentType: .moyasarCard)
            } else {
                // 🔥 هنا التصحيح
                var errorMsg = "فشل الدفع"
                switch payment.source {
                case .creditCard(let source):
                    errorMsg = source.message ?? "فشل الدفع"
                case .applePay(let source):
                    errorMsg = source.message ?? "فشل الدفع"
                case .stcPay(let source):
                    errorMsg = "فشل الدفع عبر STC Pay"
                default:
                    break
                }
                orderViewModel.errorMessage = errorMsg.decodedFromURLEncoding()
                showPaymentError = true
            }
        case .failed(let error):
            orderViewModel.errorMessage = "فشل الدفع: \(error.localizedDescription)".decodedFromURLEncoding()
            showPaymentError = true
        case .canceled:
            orderViewModel.errorMessage = "تم إلغاء عملية الدفع"
            showPaymentError = true
        default:
            break
        }
    }

    func startApplePay() {
        let handler = ApplePayPaymentHandler(paymentRequest: createPaymentRequest())
        self.applePayHandler = handler

        handler.onSuccess = {
            // نجح الدفع عبر أبل باي
            addOrder(paymentType: .moyasarApplePay)
        }
        handler.onFailure = { errorMsg in
            orderViewModel.errorMessage = errorMsg.decodedFromURLEncoding()
            showPaymentError = true
        }
        handler.onPresent = {
            isApplePayPresented = true
        }
        handler.onDismiss = {
            isApplePayPresented = false
        }
        handler.present()
    }

    private var couponSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TextField("كوبون الخصم", text: $couponCode)
                    .padding(.horizontal, 14)
                    .frame(height: 48)
                    .background(Color.gray.opacity(0.07))
                    .cornerRadius(10)
                    .customFont(weight: .medium, size: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.16), lineWidth: 1)
                    )
                Button(action: checkCoupon) {
                    Text("فحص")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .customFont(weight: .semiBold, size: 16)
                }
                .frame(width: 80, height: 48)
                .background(Color.primary())
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.blue.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .frame(height: 48)
            .clipped()
            if let message = couponMessage {
                Text(message)
                    .customFont(weight: .regular, size: 13)
                    .foregroundColor(discountValue > 0 ? .green : .red)
                    .padding(.top, 2)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("البيانات المالية")
                .customFont(weight: .bold, size: 18)
            financialRow(title: "المبلغ قبل الضريبة", value: totalBeforeDiscount)
            financialRow(title: "قيمة الخصم", value: discountValue)
            financialRow(title: "مبلغ الضريبة", value: taxAmount)
            financialRow(title: "المبلغ الاجمالي", value: totalAmount, isBold: true)
        }
    }

    func financialRow(title: String, value: Double, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .customFont(weight: .regular, size: 14)
            Spacer()
            Text("\(value, specifier: "%.2f") SAR")
                .customFont(weight: isBold ? .bold : .regular, size: 14)
                .foregroundColor(isBold ? .black : .primary)
        }
        .padding(.vertical, 4)
    }

    private var payBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("المجموع")
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(totalAmount, specifier: "%.2f") SAR")
                    .customFont(weight: .bold, size: 16)
            }
            Button(action: payNow) {
                Text("ادفع الآن")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPaymentType == nil ? Color.gray : Color.primary())
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .customFont(weight: .bold, size: 16)
            }
            .disabled(selectedPaymentType == nil || orderViewModel.isLoading)
        }
        .padding(.top)
    }

    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("طريقة الدفع")
                .customFont(weight: .bold, size: 18)
            LazyVStack(spacing: 14) {
                ForEach([PaymentType.cash, PaymentType.moyasarCard, PaymentType.moyasarApplePay], id: \.self) { method in
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
                        .customFont(weight: .bold, size: 17)
                        .foregroundColor(.primary)
                    Text(method.subtitle)
                        .customFont(weight: .medium, size: 14)
                        .foregroundColor(.gray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primary())
                        .font(.system(size: 28))
                }
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

    func checkCoupon() {
        orderViewModel.errorMessage = nil
        guard !couponCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            couponMessage = "يرجى إدخال كود الكوبون"
            return
        }
        orderViewModel.errorMessage = "جارٍ التحقق من الكوبون..."
        orderViewModel.isLoading = true
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
            orderViewModel.isLoading = false
        }
    }

    func payNow() {
        guard let paymentMethod = selectedPaymentType else { return }
        switch paymentMethod {
        case .cash:
            addOrder(paymentType: .cash)
        case .moyasarCard:
            showCardSheet = true
        case .moyasarApplePay:
            startApplePay()
        }
    }
    
    func addOrder(paymentType: PaymentType) {
        orderViewModel.errorMessage = nil
        print("addOrder CALLED")
        let params = orderData.toJson(
            couponCode: couponCode,
            paymentType: paymentType.apiValue
        )
        print("params ready:", params)
        orderViewModel.sendRawJsonRequest(
            urlString: "https://jazapp-63bc0a074b4f.herokuapp.com/api/mobile/order/add",
            body: params,
            onsuccess: { response in
                // فك الاستجابة JSON
                if let data = response.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? Bool,
                   let message = json["message"] as? String {

                    if status {
                        // العملية نجحت فعلاً
                        print("Order Success:", message)
                        appRouter.navigate(to: .paymentSuccess)
                    } else {
                        // العملية فشلت
                        print("Order Failed:", message)
                        orderViewModel.errorMessage = message // أو showValidationError/message toast
                    }
                } else {
                    // لو فشل فك JSON
                    orderViewModel.errorMessage = "استجابة غير مفهومة من السيرفر"
                }
            },
            onerror: { errorMsg in
                print("حدث خطأ: \(errorMsg)")
                orderViewModel.errorMessage = "حدث خطأ: \(errorMsg)"
            }
        )
    }

    // MARK: - Back handling when Apple Pay is presented
    private func handleBack() {
        if isApplePayPresented {
            // اغلق Apple Pay أولاً ثم ارجع
            applePayHandler?.cancel { 
                appRouter.navigateBack()
            }
        } else {
            appRouter.navigateBack()
        }
    }
}

// زر أبل باي جاهز
struct ApplePayButton: UIViewRepresentable {
    var action: UIAction
    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .black)
        button.addAction(action, for: .touchUpInside)
        return button
    }
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
}

public enum ApiResult<Value> {
    case success(Value)
    case error(Error)
}

class ApplePayPaymentHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
    var applePayService: ApplePayService?
    var paymentRequest: PaymentRequest
    var onSuccess: (() -> Void)?
    var onFailure: ((String) -> Void)?
    var onPresent: (() -> Void)?
    var onDismiss: (() -> Void)?

    private(set) var controller: PKPaymentAuthorizationController?

    init(paymentRequest: PaymentRequest) {
        self.paymentRequest = paymentRequest
        do {
            applePayService = try ApplePayService(apiKey: paymentRequest.apiKey)
        } catch {
            print("ApplePayService init error: \(error)")
        }
    }
    
    func present() {
        let items = [
            PKPaymentSummaryItem(label: "Moyasar", amount: NSDecimalNumber(value: Double(paymentRequest.amount) / 100), type: .final)
        ]
        let request = PKPaymentRequest()
        request.paymentSummaryItems = items
        request.merchantIdentifier = "merchant.jaz.com.jazclient" // غير هذا بالمعرف الخاص بك
        request.countryCode = "SA"
        request.currencyCode = "SAR"
        request.supportedNetworks = [.amex, .mada, .masterCard, .visa]
        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]

        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        self.controller = controller
        controller.present { [weak self] presented in
            if presented {
                self?.onPresent?()
            }
        }
    }

    func cancel(completion: (() -> Void)? = nil) {
        guard let controller = controller else {
            completion?()
            return
        }
        controller.dismiss { [weak self] in
            self?.onDismiss?()
            self?.controller = nil
            completion?()
        }
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        guard let service = applePayService else {
            completion(.init(status: .failure, errors: nil))
            self.onFailure?("Apple Pay Service غير متوفر")
            return
        }
        // إذا كانت مكتبتك Moyasar لا تدعم async/await، استخدم handler/closure:
        do {
            try service.authorizePayment(request: paymentRequest, token: payment.token) { result in
                switch result {
                case .success(let paymentResult):
                    switch paymentResult.status {
                    case .paid:
                        completion(.init(status: .success, errors: nil))
                        self.onSuccess?()
                    default:
                        completion(.init(status: .failure, errors: nil))
                        // قد يكون الـ source نوعه مختلف حسب حالة الدفع
                        var msg = "فشل الدفع"
                        switch paymentResult.source {
                        case .creditCard(let src):
                            msg = src.message ?? "فشل الدفع"
                        case .applePay(let src):
                            msg = src.message ?? "فشل الدفع"
                        case .stcPay:
                            msg = "فشل الدفع عبر STC Pay"
                        default:
                            break
                        }
                        self.onFailure?(msg)
                    }
                case .error(let error):
                    completion(.init(status: .failure, errors: [error]))
                    self.onFailure?(error.localizedDescription)
                }
            }
        } catch {
            completion(.init(status: .failure, errors: [error]))
            self.onFailure?(error.localizedDescription)
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
        onDismiss?()
        self.controller = nil
    }
}

// عدّل Enum PaymentType حسب مشروعك:
enum PaymentType: String, CaseIterable, Identifiable {
    case cash = "كاش"
    case moyasarCard = "بطاقة بنكية"
    case moyasarApplePay = "Apple Pay"
    var id: String { rawValue }

    // للـ API: 1 كاش، 2 أونلاين
    var apiValue: Int {
        switch self {
        case .cash:
            return 1
        case .moyasarCard, .moyasarApplePay:
            return 2
        }
    }

    // للـ UI
    var iconName: String {
        switch self {
        case .cash: return "banknote"
        case .moyasarCard: return "creditcard.fill"
        case .moyasarApplePay: return "apple.logo"
        }
    }
    var displayName: String {
        switch self {
        case .cash: return "الدفع كاش"
        case .moyasarCard: return "بطاقة بنكية (مدى/فيزا/ماستر)"
        case .moyasarApplePay: return "Apple Pay"
        }
    }
    var subtitle: String {
        switch self {
        case .cash: return "ادفع عند الاستلام"
        case .moyasarCard: return "كل البطاقات البنكية"
        case .moyasarApplePay: return "ادفع مباشرة عبر Apple Pay"
        }
    }
    var cardColor: Color {
        switch self {
        case .cash: return .gray.opacity(0.12)
        case .moyasarCard: return .primary().opacity(0.11)
        case .moyasarApplePay: return .black.opacity(0.10)
        }
    }
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

// MARK: - Helpers

extension String {
    /// يحاول فك ترميز رسائل تأتي URL-encoded من مزود الدفع.
    func decodedFromURLEncoding() -> String {
        let spaced = self.replacingOccurrences(of: "+", with: " ")
        return spaced.removingPercentEncoding ?? spaced
    }
}
