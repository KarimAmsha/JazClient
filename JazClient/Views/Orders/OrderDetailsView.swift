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

                        // معلومات الطلب الأساسية
                        VStack(spacing: 6) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(order.title ?? "خدمة")
                                        .font(.title3.bold())
                                        .foregroundColor(.blue)
                                    if let date = order.dt_date {
                                        Text(date)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    if let id = order.id {
                                        Text("رقم الطلب: #\(id)").font(.caption).foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .resizable()
                                    .frame(width: 38, height: 38)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.vertical, 8)
                        }
                        .background(Color.white)
                        .cornerRadius(12)

                        // تفاصيل إضافية
                        if let notes = order.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 5) {
                                    Image(systemName: "doc.text")
                                    Text("تفاصيل إضافية للطلب")
                                        .font(.headline)
                                }
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 4)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(10)
                        }

                        // الموقع الجغرافي (الخريطة الصغيرة + الزر)
                        if let address = order.address?.streetName, let lat = order.lat, let lng = order.lng {
                            OrderLocationSection(address: address, lat: lat, lng: lng)
                        }

                        // تفاصيل أخرى (أرقام/كود/الخ)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                infoBox(icon: "clock", title: "وقت التنفيذ", value: order.dt_date ?? "--")
                                infoBox(icon: "number", title: "كود الطلب", value: order.order_no ?? "--")
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)

                        // زر المحادثة مع مزود الخدمة
                        if let provider = order.provider,
                           let providerId = provider.id,
                           providerId != UserSettings.shared.id {
                            ProviderCardWithChatButtonView(
                                provider: provider,
                                orderStatus: OrderStatus(order.status ?? "new"),
                                onChat: {
                                    let myId = UserSettings.shared.id ?? ""
                                    let chatId = Utilities.makeChatId(currentUserId: myId, otherUserId: providerId)
                                    appRouter.navigate(to: .chat(chatId: chatId, currentUserId: myId))
                                }
                            )
                        }

                        // جدول الأسعار
                        OrderPriceTableView(order: order)

                        if order.new_total != nil || order.new_tax != nil {
                            OrderNewTotalsTableView(order: order)
                        }

                        // جدول الخدمات المضافة (extra)
                        if let extraServices = order.extra, !extraServices.isEmpty {
                            ExtraServicesSection(extraServices: extraServices)
                        }

                        // ضمن OrderDetailsView أو في قسم الإجراءات (مثلاً مع زر التقييم/المحادثة)
                        if OrderStatus(order.status ?? "new") == .accepted {
                            Button(action: {
                                showCancelSheet = true
                            }) {
                                Text("إلغاء الطلب")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.red)
                                    .background(Color.red.opacity(0.08))
                                    .cornerRadius(14)
                            }
                            .padding(.top, 5)
                        }

                        // زر تقييم الخدمة
                        if OrderStatus(order.status ?? "new") == .finished {
                            Button(action: { showRateSheet = true }) {
                                Text("تقييم الخدمة")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.green)
                                    .background(Color.green.opacity(0.09))
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                DefaultEmptyView(title: "لا يوجد بيانات")
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    Text("تفاصيل الطلب")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            print("nnnn \(orderID)")
            viewModel.getOrderDetails(orderId: orderID) {
                print("viewModel \(viewModel.orderBody)")
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
                            "status": "canceled",
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
        }
        .sheet(isPresented: $showRateSheet) {
            RateOrderSheet(
                orderId: orderID,
                onRate: { rating, comment in
                    let params: [String: Any] = [
                        "rate_from_user": "\(rating)",
                        "note_from_user": comment
                    ]
                    viewModel.addReview(orderID: orderID, params: params) { _ in
                        viewModel.getOrderDetails(orderId: orderID) {}
                        showRateSheet = false
                    }
                },
                onCancel: { showRateSheet = false }
            )
        }
    }

    func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
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

// MARK: - سير حالة الطلب
struct OrderStatusStepperView: View {
    let status: OrderStatus
    var steps: [(icon: String, label: String, isActive: Bool, color: Color, emoji: String?)] {
        [
            (
                "handshake", "تعيين الفني", status == .accepted, .orange, "🤝"
            ),
            (
                "car", "في الطريق", status == .way || status == .started || status == .finished, .gray, "🚗"
            ),
            (
                "hammer", "قيد التنفيذ", status == .started || status == .finished, .gray, "🛠️"
            ),
            (
                "checkmark.seal", "تم التنفيذ بنجاح!", status == .finished, .green, "✅"
            ),
        ]
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("حالة الطلب")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(steps.indices, id: \.self) { i in
                let step = steps[i]
                HStack(spacing: 8) {
                    VStack {
                        Circle()
                            .fill(step.isActive ? step.color : Color.gray.opacity(0.35))
                            .frame(width: 12, height: 12)
                        if i < steps.count-1 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.19))
                                .frame(width: 2, height: 32)
                        }
                    }

                    Image(systemName: step.icon)
                        .foregroundColor(step.isActive ? step.color : .gray.opacity(0.6))

                    if let emoji = step.emoji, step.isActive {
                        Text(emoji)
                            .font(.system(size: 18))
                    }
                    Text(step.label)
                        .fontWeight(step.isActive ? .bold : .regular)
                        .foregroundColor(step.isActive ? step.color : .gray.opacity(0.7))
                    Spacer()
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
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
                    .foregroundColor(.blue)
                Text("الموقع الجغرافي")
                    .font(.headline)
                Spacer()
                Button(action: { showFullMap = true }) {
                    HStack(spacing: 3) {
                        Image(systemName: "map")
                        Text("عرض على الخريطة")
                    }
                    .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
            }

            Text(address)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .padding(.bottom, 4)

            // خريطة صغيرة
            Map(coordinateRegion: $region, annotationItems: [OrderMapPin(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))]) { pin in
                MapMarker(coordinate: pin.coordinate, tint: .red)
            }
            .frame(height: 100)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
            )
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
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
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("العنوان:")
                                    .font(.headline)
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
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

struct RateOrderSheet: View {
    let orderId: String
    var onRate: (Int, String) -> Void
    var onCancel: () -> Void

    @State private var rating: Int = 5
    @State private var comment: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("قيّم الطلب")
                    .font(.headline)
                    .padding(.top, 12)
                // نجوم التقييم
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                            .onTapGesture { rating = star }
                    }
                }
                // حقل التعليق
                TextField("أضف تعليقًا (اختياري)", text: $comment)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 4)
                HStack {
                    Button("إلغاء", action: onCancel)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    Button("إرسال التقييم") {
                        onRate(rating, comment)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }
            }
            .padding()
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
            VStack(spacing: 22) {
                Text("سبب إلغاء الطلب")
                    .font(.headline)
                    .padding(.top, 12)
                TextField("اكتب سبب الإلغاء هنا...", text: $note)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 4)
                HStack {
                    Button("إلغاء", action: onCancel)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    Button("تأكيد الإلغاء", action: onConfirm)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                        .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct ProviderCardWithChatButtonView: View {
    let provider: User // موديل المزود
    let orderStatus: OrderStatus
    let onChat: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // --- كارد بيانات المزود ---
            HStack(spacing: 14) {
                // صورة المزود
                if let urlString = provider.image, let url = URL(string: urlString) {
                    AsyncImage(url: url) { img in
                        img.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray.opacity(0.7))
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.full_name ?? "مزود الخدمة")
                        .font(.headline)
                    if let phone = provider.phone_number {
                        Text(phone)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    if let rate = provider.rate {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 13))
                            Text(String(format: "%.1f", rate))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.09), lineWidth: 1)
            )

            // --- زر المحادثة ---
            if orderStatus == .accepted || orderStatus == .way || orderStatus == .started || orderStatus == .finished {
                Button(action: onChat) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("محادثة مع مزود الخدمة")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.blue.opacity(0.09))
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
                .font(.headline)
                .padding(.bottom, 4)
            if let price = order.price {
                row("السعر الأساسي:", String(format: "%.2f ر.س", price))
            }
            if let tax = order.tax {
                row("الضريبة:", String(format: "%.2f ر.س", tax))
            }
            if let discount = order.totalDiscount, discount > 0 {
                row("الخصم:", String(format: "-%.2f ر.س", discount), .green)
            }
            Divider()
            row(
                "الإجمالي النهائي:",
                String(format: "%.2f ر.س", order.netTotal ?? order.total ?? order.price ?? 0),
                .blue,
                true
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 12)
    }

    private func row(_ title: String, _ value: String, _ color: Color = .primary, _ bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(bold ? .bold : .regular)
        }
        .font(.body)
    }
}

struct OrderNewTotalsTableView: View {
    let order: OrderBody

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("المجاميع الجديدة (بعد التحديث/التعديل)")
                .font(.headline)
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
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 12)
    }

    private func row(_ title: String, _ value: String, _ color: Color = .primary, _ bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(bold ? .bold : .regular)
        }
        .font(.body)
    }
}

struct ExtraServicesSection: View {
    let extraServices: [SubCategory]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("الخدمات المضافة")
                .font(.headline)
                .padding(.bottom, 4)
            ForEach(extraServices) { service in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(service.title ?? "خدمة إضافية")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    if let price = service.price {
                        Text("سعر الخدمة: \(String(format: "%.2f", price)) ر.س")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.white)
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
