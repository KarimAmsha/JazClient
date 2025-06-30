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
                        // عنوان الشاشة
                        VStack(alignment: .center, spacing: 6) {
                            Text("تفاصيل الطلب")
                                .font(.system(size: 24, weight: .bold))
                            Text("استعرض تفاصيل طلبك وحالته")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

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
                        if let address = order.address, let lat = order.lat, let lng = order.lng {
                            OrderLocationSection(address: address, lat: lat, lng: lng)
                        }

                        // تفاصيل أخرى (أرقام/كود/الخ)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                infoBox(icon: "clock", title: "وقت التنفيذ", value: order.dt_date ?? "--")
                                infoBox(icon: "number", title: "كود الطلب", value: order.orderNo ?? "--")
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)

                        // زر المحادثة مع مزود الخدمة
                        if let provider = order.provider, let providerId = provider.id {
                            Button(action: {
                                let myId = UserSettings.shared.id ?? ""
                                let chatId = Utilities.makeChatId(currentUserId: myId, otherUserId: providerId)
                                appRouter.navigate(to: .chat(chatId: chatId, currentUserId: myId))
                            }) {
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
                            .padding(.top, 10)
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
            viewModel.getOrderDetails(orderId: orderID) { }
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
        VStack(alignment: .trailing, spacing: 0) {
            Text("حالة الطلب")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)
            ForEach(steps.indices, id: \.self) { i in
                let step = steps[i]
                HStack(spacing: 8) {
                    if let emoji = step.emoji, step.isActive {
                        Text(emoji)
                            .font(.system(size: 18))
                    }
                    Text(step.label)
                        .fontWeight(step.isActive ? .bold : .regular)
                        .foregroundColor(step.isActive ? step.color : .gray.opacity(0.7))
                    Image(systemName: step.icon)
                        .foregroundColor(step.isActive ? step.color : .gray.opacity(0.6))
                    Spacer()
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
