//
//  ContentView.swift
//  Wishy
//
//  Created by Karim Amsha on 23.04.2024.
//

import SwiftUI

struct ContentView: View {
    @State var isActive: Bool = false
    @EnvironmentObject var settings: UserSettings
//    @ObservedObject var monitor = Monitor()
    @ObservedObject var appRouter = AppRouter()

    var body: some View {
        VStack {
            if self.isActive {
                if settings.loggedIn {
                    AnyView(
                        withAnimation {
                            MainView()
                                .transition(.scale)
                        }
                    )
                } else {
                    AnyView(
                        WelcomeView()
                            .transition(.scale)
                    )
                }
            } else {
                // Show spalsh view
                SplashView()
            }
        }
//        .onChange(of: monitor.status) { status in
//            if status == .disconnected {
//                appRouter.togglePopupError(.alertError(LocalizedStringKey.error, LocalizedError.noInternetConnection))
//            }
//        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    // Change the state of 'isActive' to show home view
                    self.isActive = true
//                    self.settings.loggedIn = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
