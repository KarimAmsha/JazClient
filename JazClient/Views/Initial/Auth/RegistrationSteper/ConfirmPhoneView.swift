//
//  ConfirmPhoneView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct ConfirmPhoneView: View {
    @State var code = ""
    @FocusState private var focusedField: Int?
    @State private var totalSeconds = 59
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var minutes: Int { totalSeconds / 60 }
    var seconds: Int { totalSeconds % 60 }
    @StateObject private var viewModel = AuthViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: UserSettings
    var onComplete: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            RegistrationStepHeader(
                title: "تأكيد رقم الهاتف",
                subtitle: "قم بإدخال رمز التفعيل المرسل الى رقم هاتفك"
            )

            Text("+970 594 0700 68")
                .font(.headline)

            OtpFormFieldView(combinedPins: $code)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(viewModel.isLoading)
                .environment(\.layoutDirection, .leftToRight)

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

            Spacer()
        }
        .padding()
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
        .environment(\.layoutDirection, .rightToLeft)
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
                onComplete?()
            } else {
//                loginStatus = .profile(appState.token)
            }
        }
    }

    private func resendCode() {
        let params = ["id": appState.userId] as [String : Any]
        viewModel.resend(params: params) {}
    }
}

#Preview {
    ConfirmPhoneView()
        .environmentObject(AppState())
        .environmentObject(UserSettings())
}
