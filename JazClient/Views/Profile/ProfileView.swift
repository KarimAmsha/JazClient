import SwiftUI
import PopupView

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject private var authViewModel = AuthViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState

    // بيانات المستخدم
    @State private var name: String = UserSettings.shared.user?.full_name ?? "اسم المستخدم"
    @State private var phone: String = UserSettings.shared.user?.phone_number ?? "--"
    @State private var imageUrl: String = UserSettings.shared.user?.image ?? ""

    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(spacing: 16) {
            // --- كارت معلومات المستخدم وزر التعديل ---
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    if !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                // أثناء التحميل
                                ProgressView()
                                    .frame(width: 54, height: 54)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 54, height: 54)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            case .failure(_):
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 54, height: 54)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 54, height: 54)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer()
                Text(phone)
                    .font(.system(size: 16, weight: .medium))
                Spacer()

                Button(action: {
                    appRouter.navigate(to: .editProfile)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("تعديل الملف")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.10))
                    .cornerRadius(18)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
            .padding(.horizontal, 8)

            // --- القائمة الرئيسية ---
            VStack(spacing: 0) {
                profileItem(title: "نبذة عن تطبيق جاز") {
                    if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .about }) {
                        appRouter.navigate(to: .constant(item))
                    }
                }
                profileItem(title: "المحفظة") { appRouter.navigate(to: .walletView) }
                Divider().padding(.leading)
                Divider().padding(.leading)
                profileItem(title: "عناويني") { appRouter.navigate(to: .addressBook) }
                Divider().padding(.leading)
                profileItem(title: "تواصل معنا") { appRouter.navigate(to: .contactUs) }
                Divider().padding(.leading)
                profileItem(title: "سياسة الاستخدام") {
                    if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .using }) {
                        appRouter.navigate(to: .constant(item))
                    }
                }
                Divider().padding(.leading)
                profileItem(title: "سياسة الخصوصية") {
                    if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .privacy }) {
                        appRouter.navigate(to: .constant(item))
                    }
                }
//                Divider().padding(.leading)
//                profileItem(title: "اللغة", icon: "globe") {
//                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 1)
            .padding(.horizontal, 8)
            .padding(.top, 6)

            // --- زر حذف الحساب في الأسفل باللون الأحمر ---
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    Text("حذف الحساب نهائيًا")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 8)
            }
            .padding(.top, 14)

            // --- زر تسجيل الخروج ---
            Button(action: {
                showLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    Text("تسجيل الخروج!")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.07))
                .cornerRadius(12)
                .padding(.horizontal, 8)
            }

            // --- رقم النسخة ---
            Text("VERSION \(Bundle.main.shortVersion)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Spacer(minLength: 16)
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Text("الصفحة الشخصية")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
        .onAppear {
            getConstants()
            name = UserSettings.shared.user?.full_name ?? "اسم المستخدم"
            phone = UserSettings.shared.user?.phone_number ?? "--"
            imageUrl = UserSettings.shared.user?.image ?? "--"
        }
        // بوب أب لتسجيل الخروج
        .popup(isPresented: $showLogoutAlert) {
            ConfirmPopup(
                title: "تسجيل الخروج",
                message: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                okTitle: "تسجيل الخروج",
                cancelTitle: "رجوع",
                okAction: logout,
                cancelAction: { showLogoutAlert = false }
            )
        }
        // بوب أب حذف الحساب
        .popup(isPresented: $showDeleteAlert) {
            ConfirmPopup(
                title: "حذف الحساب",
                message: "هل أنت متأكد أنك تريد حذف الحساب نهائيًا؟",
                okTitle: "حذف الحساب",
                cancelTitle: "رجوع",
                okAction: deleteAccount,
                cancelAction: { showDeleteAlert = false }
            )
        }
    }

    // ---- صف إعداد فردي ----
    @ViewBuilder
    func profileItem(title: String, icon: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .customFont(weight: .medium, size: 12)
                        .foregroundColor(.blue)
                }
                Text(title)
                    .foregroundColor(.black)
                    .customFont(weight: .medium, size: 16)
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func getConstants() {
        initialViewModel.fetchConstantsItems()
    }

    private func logout() {
        authViewModel.logoutUser {
            appState.currentPage = .home
        }
        showLogoutAlert = false
    }

    private func deleteAccount() {
        authViewModel.deleteAccount {
            appState.currentPage = .home
        }
        showDeleteAlert = false
    }
}

// --- PopUp تأكيد عام ---
struct ConfirmPopup: View {
    let title: String
    let message: String
    let okTitle: String
    let cancelTitle: String
    let okAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2.bold())
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            HStack {
                Button(cancelTitle, action: cancelAction)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                Button(okTitle, action: okAction)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(okTitle.contains("حذف") ? Color.red : Color.secondary())
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
        .shadow(radius: 18)
        .frame(maxWidth: 330)
    }
}

// لجلب رقم النسخة تلقائيًا (مثال: 1.5.7)
extension Bundle {
    var shortVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppRouter())
        .environmentObject(AppState())
}
