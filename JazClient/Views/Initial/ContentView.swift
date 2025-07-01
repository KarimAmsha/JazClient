//
//  ContentView.swift
//  Wishy
//
//  Created by Karim Amsha on 23.04.2024.
//

import SwiftUI

//
//  ContentView.swift
//  Wishy
//
//  Created by Karim Amsha on 23.04.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive: Bool = false
    @State private var isUnderMaintenance: Bool = false
    @State private var maintenanceMessage: String = ""
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var settings: UserSettings
    @ObservedObject var appRouter = AppRouter()
    
    var body: some View {
        VStack {
            if !isActive {
                SplashView()
            } else if isUnderMaintenance {
                MaintenanceView(message: maintenanceMessage)
            } else {
                if settings.loggedIn {
                    MainView()
                        .environmentObject(appRouter)
                        .transition(.scale)
                } else {
                    WelcomeView()
                        .transition(.scale)
                }
            }
        }
        .onAppear {
            initialViewModel.fetchAppConstantsItems { items in
                // فحص حالة الصيانة من الكود
                if let maint = items.first(where: { $0.code == "MAINTANCE" }),
                   let value = maint.value,
                   value == "نعم" || value.lowercased() == "yes"
                {
                    isUnderMaintenance = true
                    maintenanceMessage = maint.name ?? "التطبيق تحت الصيانة، يرجى المحاولة لاحقًا"
                }
                // إظهار الشاشة بعد السبلاش
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
}

#Preview {
    ContentView()
}

struct MaintenanceView: View {
    let message: String

    var body: some View {
        ZStack {
            Color.primary().opacity(0.12) // غيّرها للون المناسب لتطبيقك لو عندك custom
                .ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Image("ic_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(.bottom, 8)
                Text(message)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 30)
                Spacer()
                Text("نعتذر عن الإزعاج ونأمل العودة قريباً 🙏")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 36)
            }
        }
    }
}

#Preview {
    MaintenanceView(message: "التطبيق تحت الصيانة، يرجى المحاولة لاحقًا.\nسنعود للعمل قريبًا 🙏")
}
