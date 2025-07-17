import SwiftUI
import MapKit

struct OrderDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    let orderID: String

    @State private var showCancelSheet = false
    @State private var showRateSheet = false
    @State private var cancelNote: String = ""

    var body: some View {
        VStack(spacing: 0) {
            if let order = viewModel.orderBody {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        // سير حالة الطلب (timeline)
                        OrderStatusStepperView(status: OrderStatus(order.status ?? "new"))

                        // بيانات الخدمة الرئيسية
                        VStack(spacing: 6) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(order.category_id?.title ?? "")
                                        Text("-")
                                        Text(order.sub_category_id?.title ?? "")
                                    }
                                    .customFont(weight: .medium, size: 15)
                                    .foregroundColor(.black121212())
                                    
                                    if let date = order.formattedCreateDate {
                                        Text(date)
                                            .customFont(weight: .light, size: 12)
                                            .foregroundColor(.grayA1A1A1())
                                    }
                                    if let orderNo = order.order_no {
                                        Text("رقم الطلب: #\(orderNo)")
                                            .customFont(weight: .regular, size: 12)
                                            .foregroundColor(.grayA1A1A1())
                                    }
                                }
                                Spacer()
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .resizable()
                                    .frame(width: 34, height: 34)
                                    .foregroundColor(.primary())
                                    .background(Color.backgroundFEF3DE())
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.vertical, 8)
                        }
                        .background(Color.white)
                        .cornerRadius(14)

                        // تفاصيل إضافية
                        if let notes = order.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 5) {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.primary())
                                    Text("تفاصيل إضافية للطلب")
                                        .customFont(weight: .medium, size: 14)
                                        .foregroundColor(.primaryDark())
                                    Spacer()
                                }
                                Text(notes)
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black121212())
                                    .padding(.vertical, 4)
                            }
                            .padding(12)
                            .background(Color.backgroundFEF3DE())
                            .cornerRadius(10)
                        }

                        // الموقع الجغرافي
                        if let address = order.address?.address, let lat = order.lat, let lng = order.lng {
                            OrderLocationSection(address: address, lat: lat, lng: lng)
                        }

                        // تفاصيل أخرى (أرقام/كود/الخ)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                infoBox(icon: "clock", title: "وقت التنفيذ", value: order.formattedOrderDate ?? "--")
                                infoBox(icon: "number", title: "كود الطلب", value: order.order_no ?? "--")
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)

                        // زر المحادثة مع مزود الخدمة
                        let validOrderStatuses: [OrderStatus] = [.accepted, .way, .started, .finished]
                        if let provider = order.provider,
                           let providerId = provider.id,
                           providerId != UserSettings.shared.id,
                           validOrderStatuses.contains(OrderStatus(order.status ?? "new")) {
                            ProviderCardWithChatButtonView(
                                provider: provider,
                                orderStatus: OrderStatus(order.status ?? ""),
                                onChat: {
                                    let myId = UserSettings.shared.id ?? ""
                                    let chatId = Utilities.makeChatId(currentUserId: myId, otherUserId: providerId)
                                    appRouter.navigate(to: .chat(chatId: chatId, currentUserId: myId, receiverId: providerId))
                                }
                            )
                        }

                        // جدول الأسعار
                        OrderPriceTableView(order: order)

                        if (order.new_total ?? 0) > 0 || (order.new_tax ?? 0) > 0 {
                            OrderNewTotalsTableView(order: order)
                        }

                        // جدول الخدمات المضافة (extra)
                        if let extraServices = order.extra, !extraServices.isEmpty {
                            ExtraServicesSection(extraServices: extraServices)
                        }

                        // زر إلغاء الطلب
                        if order.orderStatus == .new {
                            Button(action: { showCancelSheet = true }) {
                                Text("إلغاء الطلب")
                                    .customFont(weight: .medium, size: 15)
                                    .foregroundColor(.dangerNormal())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.dangerLight())
                                    .cornerRadius(14)
                            }
                            .padding(.top, 5)
                        }

                        // زر تقييم الخدمة
                        if order.orderStatus == .finished {
                            Button(action: { showRateSheet = true }) {
                                Text("تقييم الخدمة")
                                    .customFont(weight: .medium, size: 15)
                                    .foregroundColor(.successNormal())
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.successLight())
                                    .cornerRadius(14)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            } else if viewModel.isLoading {
                ProgressView("جاري التحميل ...")
                    .customFont(weight: .medium, size: 15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                DefaultEmptyView(title: "لا يوجد بيانات")
            }
        }
        .background(Color.background().ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button { appRouter.navigateBack() } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.primaryDark())
                    }
                    Text("تفاصيل الطلب")
                        .customFont(weight: .semiBold, size: 18)
                        .foregroundColor(.primaryDark())
                }
            }
        }
        .onAppear {
            viewModel.getOrderDetails(orderId: orderID) {
                viewModel.startListeningOrderRealtime(orderId: orderID)
            }
        }
        .onDisappear {
            viewModel.stopListeningOrderRealtime()
        }
        .sheet(isPresented: $showCancelSheet) {
            CancelOrderSheet(
                note: $cancelNote,
                onConfirm: {
                    viewModel.updateOrderStatus(
                        orderId: orderID,
                        params: [
                            "status": "canceled_by_user",
                            "canceled_note": cancelNote
                        ]
                    ) {
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showCancelSheet = false
                        cancelNote = ""
                    }
                },
                onCancel: {
                    showCancelSheet = false
                    cancelNote = ""
                }
            )
            // هنا تحدد حجم الشيت
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(22) // زوايا دائرية للشيت
            .interactiveDismissDisabled(false) // اسمح بالإغلاق بالسحب
        }
        .sheet(isPresented: $showRateSheet) {
            RateOrderSheet(
                orderId: orderID,
                onRate: { rating, comment in
                    // كود التقييم هنا
                    let params: [String: Any] = [
                        "rate_from_user": "\(rating)",
                        "note_from_user": comment
                    ]
                    viewModel.addReview(orderID: orderID, params: params) { _ in
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showRateSheet = false
                    }
                },
                onCancel: {
                    showRateSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(22)
        }
    }

    func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.primary())
                Text(title)
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.gray737373())
            }
            Text(value)
                .customFont(weight: .medium, size: 13)
                .foregroundColor(.black131313())
        }
        .frame(maxWidth: .infinity)
    }

    func canChat(status: String?) -> Bool {
        guard let status = status else { return false }
        // عدّل الحالات حسب المنظومة لديك
        let allowed: [OrderStatus] = [.accepted, .way, .started, .finished]
        return allowed.contains(OrderStatus(status))
    }
}

import SwiftUI

enum OrderStep: Int, CaseIterable {
    case accepted = 0
    case way
    case started
    case finished

    var icon: String {
        switch self {
        case .accepted: return "handshake"
        case .way: return "car"
        case .started: return "hammer"
        case .finished: return "checkmark.seal"
        }
    }
    var label: String {
        switch self {
        case .accepted: return "تعيين الفني"
        case .way: return "في الطريق"
        case .started: return "قيد التنفيذ"
        case .finished: return "تم التنفيذ بنجاح!"
        }
    }
    var color: Color {
        switch self {
        case .accepted: return .primary()
        case .way: return .blue0094FF()
        case .started: return .orangeF7941D()
        case .finished: return .successNormal()
        }
    }
    var emoji: String {
        switch self {
        case .accepted: return "🤝"
        case .way: return "🚗"
        case .started: return "🛠️"
        case .finished: return "✅"
        }
    }
}

func currentStep(for status: OrderStatus) -> Int {
    switch status {
    case .accepted: return 0
    case .way: return 1
    case .started: return 2
    case .finished: return 3
    // إذا عندك حالات إضافية (معدّل/مؤكد/الخ) اضفها هنا حسب ترتيب الفلو
    default: return 0
    }
}

struct OrderStatusStepperView: View {
    let status: OrderStatus

    var body: some View {
        let current = currentStep(for: status)

        VStack(alignment: .leading, spacing: 0) {
            Text("حالة الطلب")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            HStack(alignment: .center, spacing: 10) {
                // عمود النقاط والخط
                VStack {
                    ForEach(OrderStep.allCases.indices, id: \.self) { i in
                        VStack(spacing: 0) {
                            Circle()
                                .fill(i <= current ? OrderStep.allCases[i].color : Color.grayE6E6E6())
                                .frame(width: 13, height: 13)
                            if i < OrderStep.allCases.count - 1 {
                                Rectangle()
                                    .fill(Color.grayEFEFEF())
                                    .frame(width: 2, height: 32)
                                    .padding(.vertical, 0)
                            }
                        }
                        .frame(width: 13) // تثبيت العرض للمحاذاة
                    }
                }

                // عمود الكلام والرمز
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(OrderStep.allCases.indices, id: \.self) { i in
                        let step = OrderStep.allCases[i]
                        let isActive = i <= current
                        HStack(spacing: 5) {
                            if isActive {
                                Text(step.emoji)
                                    .font(.system(size: 18))
                            } else {
                                Image(systemName: step.icon)
                                    .foregroundColor(.grayA1A1A1())
                            }
                            Text(step.label)
                                .customFont(weight: isActive ? .semiBold : .regular, size: 14)
                                .foregroundColor(isActive ? step.color : .grayA1A1A1())
                        }
                    }
                }
                .padding(.leading, 4)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Color.backgroundFEF3DE())
            .cornerRadius(14)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color.backgroundFEF3DE())
        .cornerRadius(14)
    }
}

struct OrderLocationSection: View {
    let address: String
    let lat: Double
    let lng: Double
    @State private var region: MKCoordinateRegion
    @State private var showFullMap = false

    init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.primary())
                Text("الموقع الجغرافي")
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
                Spacer()
                Button(action: { showFullMap = true }) {
                    HStack(spacing: 3) {
                        Image(systemName: "map")
                        Text("عرض على الخريطة")
                            .customFont(weight: .medium, size: 12)
                    }
                    .foregroundColor(.blue0094FF())
                }
                .buttonStyle(.plain)
            }

            Text(address)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.grayA1A1A1())
                .lineLimit(2)
                .padding(.bottom, 2)

            // خريطة صغيرة
            Map(coordinateRegion: $region, annotationItems: [OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .dangerNormal())
            }
            .frame(height: 100)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.grayE6E6E6(), lineWidth: 1)
            )
        }
        .padding(12)
        .background(Color.backgroundFEF3DE())
        .cornerRadius(14)
        .sheet(isPresented: $showFullMap) {
            FullScreenMapView(address: address, lat: lat, lng: lng)
        }
    }

    struct OrderMapPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
}

// شاشة الخريطة الكاملة
struct FullScreenMapView: View {
    let address: String
    let lat: Double
    let lng: Double
    @Environment(\.dismiss) var dismiss

    @State private var region: MKCoordinateRegion

    init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Map(coordinateRegion: $region, annotationItems: [
                    OrderLocationSection.OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                ]) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .dangerNormal())
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("العنوان:")
                                    .customFont(weight: .medium, size: 14)
                                    .foregroundColor(.primaryDark())
                                Text(address)
                                    .customFont(weight: .regular, size: 13)
                                    .foregroundColor(.grayA1A1A1())
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.grayA1A1A1())
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 14)
                )
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProviderCardWithChatButtonView: View {
    let provider: User
    let orderStatus: OrderStatus
    let onChat: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // كارد بيانات المزود
            HStack(spacing: 14) {
                if let urlString = provider.image, let url = URL(string: urlString) {
                    AsyncImage(url: url) { img in
                        img.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.grayA1A1A1())
                    }
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.grayA1A1A1())
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.full_name ?? "مزود الخدمة")
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.primaryDark())
                    if let phone = provider.phone_number {
                        Text(phone)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.grayA1A1A1())
                    }
                    if let rate = provider.rate {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellowFFB020())
                                .font(.system(size: 13))
                            Text(String(format: "%.1f", rate))
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.grayA1A1A1())
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.backgroundFEF3DE())
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary().opacity(0.10), lineWidth: 1)
            )

            // زر المحادثة
            if [.accepted, .way, .started, .finished].contains(orderStatus) {
                Button(action: onChat) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("محادثة مع مزود الخدمة")
                            .customFont(weight: .medium, size: 14)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary())
                    .background(Color.primaryLight())
                    .cornerRadius(14)
                }
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
        .transition(.opacity)
    }
}

struct OrderPriceTableView: View {
    let order: OrderBody

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("تفاصيل الأسعار")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .padding(.bottom, 4)
            if let price = order.price {
                row("السعر الأساسي:", String(format: "%.2f ر.س", price))
            }
            if let tax = order.tax {
                row("الضريبة:", String(format: "%.2f ر.س", tax))
            }
            if let discount = order.totalDiscount, discount > 0 {
                row("الخصم:", String(format: "-%.2f ر.س", discount), .successNormal())
            }
            Divider()
            row(
                "الإجمالي النهائي:",
                String(format: "%.2f ر.س", order.netTotal ?? order.total ?? order.price ?? 0),
                .primary(),
                true
            )
        }
        .padding()
        .background(Color.backgroundFEF3DE())
        .cornerRadius(12)
        .padding(.top, 12)
    }

    private func row(_ title: String, _ value: String, _ color: Color = .primaryDark(), _ bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.primaryDark())
            Spacer()
            Text(value)
                .customFont(weight: bold ? .semiBold : .medium, size: 13)
                .foregroundColor(color)
        }
    }
}

struct OrderNewTotalsTableView: View {
    let order: OrderBody

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("المجاميع الجديدة (بعد التحديث/التعديل)")
                .customFont(weight: .medium, size: 13)
                .foregroundColor(.purple)
                .padding(.bottom, 4)
            if let newTax = order.new_tax {
                row("الضريبة الجديدة:", String(format: "%.2f ر.س", newTax))
            }
            if let newTotal = order.new_total {
                row("الإجمالي الجديد:", String(format: "%.2f ر.س", newTotal), .purple, true)
            }
        }
        .padding()
        .background(Color.backgroundFEF3DE())
        .cornerRadius(12)
        .padding(.top, 12)
    }

    private func row(_ title: String, _ value: String, _ color: Color = .primaryDark(), _ bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.primaryDark())
            Spacer()
            Text(value)
                .customFont(weight: bold ? .semiBold : .medium, size: 13)
                .foregroundColor(color)
        }
    }
}

struct ExtraServicesSection: View {
    let extraServices: [SubCategory]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("الخدمات المضافة")
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.primaryDark())
                .padding(.bottom, 4)
            ForEach(extraServices) { service in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(service.title ?? "خدمة إضافية")
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.black121212())
                        Spacer()
                    }
                    if let price = service.price {
                        Text("سعر الخدمة: \(String(format: "%.2f", price)) ر.س")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.primary())
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.backgroundFEF3DE())
        .cornerRadius(12)
        .padding(.top, 8)
    }
}

#Preview {
    // مثال بيانات تجريبية
    ExtraServicesSection(extraServices: [
        SubCategory(id: "1", price: 25.0, title: "تنظيف مكيف", description: "تنظيف وتعقيم", image: nil),
        SubCategory(id: "2", price: 40.0, title: "صيانة كهرباء", description: nil, image: nil)
    ])
}

// MARK: - Preview
#Preview {
    OrderDetailsView(orderID: "order-xyz")
        .environmentObject(AppRouter())
}

struct RateOrderSheet: View {
    let orderId: String
    var onRate: (Int, String) -> Void
    var onCancel: () -> Void

    @State private var rating: Int = 5
    @State private var comment: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 22) {
                // العنوان
                Text("قيّم الطلب")
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.primaryDark())
                    .padding(.top, 10)

                // نجوم التقييم
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(star <= rating ? .yellowFFB020() : .grayDCDCDC())
                            .font(.system(size: 32))
                            .onTapGesture { rating = star }
                    }
                }
                
                // TextEditor مع placeholder يدوي
                ZStack(alignment: .topLeading) {
                    if comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("أضف تعليقًا (اختياري)")
                            .customFont(weight: .regular, size: 13)
                            .foregroundColor(.grayA1A1A1())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    TextEditor(text: $comment)
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                        .frame(minHeight: 70, maxHeight: 100)
                        .padding(4)
                        .background(Color.grayF5F5F5())
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.grayEFEFEF(), lineWidth: 1)
                        )
                }

                // الأزرار
                HStack(spacing: 14) {
                    Button("إلغاء", action: onCancel)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.dangerNormal())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dangerLight())
                        .cornerRadius(10)

                    Button("إرسال التقييم") {
                        onRate(rating, comment)
                    }
                    .customFont(weight: .medium, size: 15)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.successNormal())
                    .cornerRadius(10)
                }
                .padding(.bottom, 6)
                Spacer(minLength: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .navigationBarHidden(true)
        }
    }
}

struct CancelOrderSheet: View {
    @Binding var note: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // العنوان
                Text("سبب إلغاء الطلب")
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.dangerNormal())
                    .padding(.top, 10)
                
                // TextEditor مع placeholder يدوي
                ZStack(alignment: .topLeading) {
                    if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("اكتب سبب الإلغاء هنا...")
                            .customFont(weight: .regular, size: 13)
                            .foregroundColor(.grayA1A1A1())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                    }
                    TextEditor(text: $note)
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                        .frame(minHeight: 90, maxHeight: 120)
                        .padding(4)
                        .background(Color.grayF5F5F5())
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.grayEFEFEF(), lineWidth: 1)
                        )
                }
                .padding(.top, 6)
                
                // الأزرار
                HStack(spacing: 14) {
                    Button("إلغاء", action: onCancel)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.primaryDark())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.grayEFEFEF())
                        .cornerRadius(10)
                    
                    Button("تأكيد الإلغاء", action: onConfirm)
                        .customFont(weight: .medium, size: 15)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.dangerNormal())
                        .cornerRadius(10)
                        .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding(.bottom, 6)
                
                Spacer(minLength: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .navigationBarHidden(true)
        }
    }
}
