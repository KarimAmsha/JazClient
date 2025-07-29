//
//  SMSVerificationView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import Combine
import PopupView

struct SMSVerificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: UserSettings
    @State private var passCodeFilled = false
    @Environment(\.presentationMode) var presentationMode
    @State private var totalSeconds = 59
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var minutes: Int { totalSeconds / 60 }
    var seconds: Int { totalSeconds % 60 }

    var id: String
    var mobile: String

    @State var code = ""
    @FocusState private var focusedField: Int?

    @StateObject private var viewModel = AuthViewModel(errorHandling: ErrorHandling())
    private let errorHandling = ErrorHandling()
    @Binding var loginStatus: LoginStatus
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("👋")
                    Text("ادخل رمز التحقق!")
                        .customFont(weight: .medium, size: 16)
                        .foregroundColor(.primaryBlack())
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("قم بادخال رمز التفعيل المرسل الى رقم هاتفك")
                    .customFont(weight: .regular, size: 14)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)

                Text(mobile)
                    .font(.headline)
            }

            OtpFormFieldView(combinedPins: $code)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(viewModel.isLoading)
                .environment(\.layoutDirection, .leftToRight)

            Spacer()

            Button {
                verify()
            } label: {
                Text("تسجيل الدخول")
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            .disabled(viewModel.isLoading)

            HStack(spacing: 100) {
                Text("0:\(seconds) - لم تستلم رمزًا؟")
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.grayA4ACAD())

                Button("طلب رمز جديد") {
                    resendCode()
                }
                .buttonStyle(CustomButtonStyle(fontSize: 14, fontWeight: .bold, background: .primaryLight(), foreground: .primaryBlack()))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(24)
        .dismissKeyboardOnTap()
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .onReceive(timer) { _ in
            if totalSeconds > 0 {
                totalSeconds -= 1
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }

    private func verify() {
        let params = [
            "id": appState.userId,
            "verify_code": code,
            "phone_number": appState.phoneNumber,
            "by": appState.referalUrl?.lastPathComponent ?? ""
        ] as [String : Any]

        viewModel.verify(params: params) { profileCompleted, token in
            if profileCompleted {
                settings.loggedIn = true
            } else {
                loginStatus = .accountCreated
            }
        }
    }

    private func resendCode() {
        let params = ["id": appState.userId] as [String : Any]
        viewModel.resend(params: params) {}
    }
}

#Preview {
    SMSVerificationView(id: "", mobile: "", loginStatus: .constant(.verification))
        .environmentObject(AppState())
        .environmentObject(UserSettings())
}
