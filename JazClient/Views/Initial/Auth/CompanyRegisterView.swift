import SwiftUI

struct CompanyRegisterView: View {
    // MARK: - Properties

    @State private var phoneNumber: String = ""
    @State private var companyName: String = ""
    @State private var email: String = ""
    @FocusState private var focusedField: Field?

    @StateObject private var authVM = AuthViewModel(errorHandling: ErrorHandling())
    @ObservedObject private var locationManager = LocationManager.shared

    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccess = false

    enum Field { case phone, name, email }

    // MARK: - Main View

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // --- Header with Close Button ---
                HStack {
                    Text("تسجيل شركة جديدة")
                        .customFont(weight: .semiBold, size: 19)
                        .foregroundColor(.primaryDark())
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Color.gray.opacity(0.13))
                            .clipShape(Circle())
                    }
                }
                .padding(10)

                Divider()
                    .padding(.bottom, 6)

                // --- Content ScrollView ---
                ScrollView {
                    VStack(spacing: 22) {
                        companyNameField
                        phoneNumberField
                        emailField
                        locationSection

                        if let error = authVM.errorMessage, !error.isEmpty {
                            Text(error)
                                .customFont(weight: .regular, size: 13)
                                .foregroundColor(.dangerNormal())
                                .padding(.top, 2)
                        }

                        Button(action: submit) {
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Text("تسجيل الشركة")
                                    .customFont(weight: .medium, size: 16)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isFormValid ? Color.primary() : Color.grayDCDCDC())
                        .cornerRadius(14)
                        .disabled(!isFormValid || authVM.isLoading)
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 30)
                }
            }

            if showSuccess {
                MaterialSuccessAlert(
                    title: "تم التسجيل بنجاح!",
                    message: "تمت إضافة الشركة إلى النظام بنجاح.",
                    buttonTitle: "موافق"
                ) {
                    showSuccess = false
                    presentationMode.wrappedValue.dismiss()
                }
                .zIndex(999)
            }
        }
        .background(Color(.systemGroupedBackground))
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(22)
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            locationManager.requestLocationIfNeeded()
        }
    }

    // MARK: - Subviews

    private var companyNameField: some View {
        formField(
            title: "اسم الشركة",
            systemIcon: "building.2.crop.circle",
            text: $companyName,
            field: .name
        )
    }

    private var phoneNumberField: some View {
        formField(
            title: "رقم الجوال",
            systemIcon: "phone.fill",
            text: $phoneNumber,
            keyboardType: .numberPad,
            field: .phone
        )
    }

    private var emailField: some View {
        formField(
            title: "البريد الإلكتروني",
            systemIcon: "envelope.fill",
            text: $email,
            keyboardType: .emailAddress,
            field: .email
        )
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.primary())
                Text("الموقع الجغرافي")
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Latitude")
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.grayA1A1A1())
                    Text(locationManager.userLocation?.latitude.formatted() ?? "جارٍ التحديد...")
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                }
                VStack(alignment: .leading) {
                    Text("Longitude")
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.grayA1A1A1())
                    Text(locationManager.userLocation?.longitude.formatted() ?? "جارٍ التحديد...")
                        .customFont(weight: .regular, size: 14)
                        .foregroundColor(.black121212())
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("العنوان")
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.grayA1A1A1())
                Text(locationManager.address.isEmpty ? "جارٍ تحديد العنوان..." : locationManager.address)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.black121212())
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(10)
        .background(Color.grayEFEFEF())
        .cornerRadius(12)
        .onAppear {
            locationManager.requestLocationIfNeeded()
        }
    }

    // MARK: - Helpers

    func formField(title: String, systemIcon: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: systemIcon)
                    .foregroundColor(.primary())
                Text(title)
                    .customFont(weight: .medium, size: 14)
                    .foregroundColor(.primaryDark())
            }
            TextField(title, text: text)
                .customFont(weight: .regular, size: 14)
                .foregroundColor(.black121212())
                .padding(10)
                .background(Color.grayF5F5F5())
                .cornerRadius(10)
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
        }
    }

    var isFormValid: Bool {
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !companyName.trimmingCharacters(in: .whitespaces).isEmpty &&
        locationManager.userLocation != nil &&
        !locationManager.address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        phoneNumber.count >= 9
    }

    func submit() {
        guard isFormValid else {
            authVM.errorMessage = "يرجى تعبئة جميع الحقول بشكل صحيح"
            return
        }
        authVM.errorMessage = nil

        guard let loc = locationManager.userLocation else {
            authVM.errorMessage = "فشل في تحديد الموقع"
            return
        }

        let params: [String: Any] = [
            "phone_number": phoneNumber,
            "company_name": companyName,
            "lat": loc.latitude,
            "lng": loc.longitude,
            "address": locationManager.address,
            "email": email
        ]

        authVM.registerCompany(params: params) { _ in
            showSuccess = true
        } onerror: { errMsg in
            authVM.errorMessage = errMsg
        }
    }
}

#Preview {
    CompanyRegisterView()
}

struct MaterialSuccessAlert: View {
    var title: String = "تم التسجيل بنجاح!"
    var message: String = "تمت إضافة الشركة إلى النظام بنجاح. يمكنك الآن تسجيل الدخول أو العودة للصفحة السابقة."
    var buttonTitle: String = "حسنًا"
    var onClose: (() -> Void)?

    @State private var showCheck = false

    var body: some View {
        ZStack {
            // الخلفية الشفافة
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { onClose?() }

            // الكارد
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 74, height: 74)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundColor(.green)
                        .frame(width: 64, height: 64)
                        .scaleEffect(showCheck ? 1 : 0.3)
                        .opacity(showCheck ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.58), value: showCheck)
                }
                .padding(.top, 4)

                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                Button(action: { onClose?() }) {
                    Text(buttonTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.78)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.green.opacity(0.15), radius: 7, x: 0, y: 3)
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 26)
            .padding(.horizontal, 20)
            .frame(maxWidth: 370)
            .background(
                BlurView(style: .systemMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            )
            .overlay(
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding(10)
                        .background(Color(.systemBackground).opacity(0.85))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                .padding(6),
                alignment: .topTrailing
            )
            .shadow(color: Color.black.opacity(0.13), radius: 24, x: 0, y: 18)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showCheck = true
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: showCheck)
    }
}

// دعم تأثير البلور (Blur) في كل الأنظمة
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
