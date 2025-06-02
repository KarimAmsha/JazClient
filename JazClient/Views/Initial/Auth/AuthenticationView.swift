//
//  AuthenticationView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var loginStatus: LoginStatus

//    init(loginStatus: Binding<LoginStatus>, router: MainRouter) {
//        _loginStatus = loginStatus
//        _router = StateObject(wrappedValue: router)
//    }

    var body: some View {
        if loginStatus == .login {
            LoginView(loginStatus: $loginStatus)
        } else if loginStatus == .register {
            RegistrationFlowView()
        } else if loginStatus == .verification {
            SMSVerificationView(id: "", mobile: "", loginStatus: $loginStatus)
        } else if loginStatus == .accountCreated {
            AccountCreatedView(loginStatus: $loginStatus)
        } else if case .completeProfile(let token) = loginStatus {
            PersonalInfoView()
        } else if loginStatus == .forgetPassword {
//            ForgetPasswordView(loginStatus: $loginStatus)
        } else if loginStatus == .changePassword {
//            CreatePasswordView(id: "", mobile: "", loginStatus: $loginStatus)
        } else if case .identityConfirmation(let token) = loginStatus {
//            IdentityConfirmationView(token: token, loginStatus: $loginStatus)
        } else if loginStatus == .selectLocation {
//            SelectLocationView(loginStatus: $loginStatus)
        }
    }
}

#Preview {
    AuthenticationView(loginStatus: .constant(.login))
}
