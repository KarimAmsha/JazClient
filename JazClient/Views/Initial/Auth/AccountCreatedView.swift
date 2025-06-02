//
//  AccountCreatedView.swift
//  JazClient
//
//  Created by Karim OTHMAN on 2.06.2025.
//

import SwiftUI

struct AccountCreatedView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appRouter: AppRouter
    @Binding var loginStatus: LoginStatus

    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)
                .padding(.bottom, 10)

            Text("لقد تم إنشاء الحساب بنجاح!")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("لقد قمت بإنشاء حساب جديد والآن يمكنك البدء باستخدام التطبيق. ولكن ننصح بإكمال معلومات الملف الشخصي الخاص لتحسين تجربتك كمستخدم!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    // Action: Go to complete profile
                    loginStatus = .completeProfile(appState.token)
                }) {
                    Text("اكمال الملف الشخصي")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }

                Button(action: {
                    appState.currentPage = .home
                    UserSettings.shared.loggedIn = true
                }) {
                    Text("تصفح الخدمات!")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 40)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AccountCreatedView(loginStatus: .constant(.login))
        .environmentObject(AppState())
        .environmentObject(UserSettings())
        .environmentObject(AppRouter())
}
