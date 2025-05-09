//
//  NotificationsSettingsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @EnvironmentObject var appRouter: AppRouter

    @AppStorage("showNewOffers") private var showNewOffers: Bool = true
    @AppStorage("showProjectUpdates") private var showProjectUpdates: Bool = true
    @AppStorage("showClientRatings") private var showClientRatings: Bool = true
    @AppStorage("showPromotionalAds") private var showPromotionalAds: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    Toggle(isOn: $showNewOffers) {
                        Text("العروض الجديدة")
                    }

                    Toggle(isOn: $showProjectUpdates) {
                        Text("تحديثات المشاريع الحالية")
                    }

                    Toggle(isOn: $showClientRatings) {
                        Text("التقييمات من العملاء")
                    }

                    Toggle(isOn: $showPromotionalAds) {
                        Text("الاعلانات الترويجية من المنصة")
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    Button(action: {
                        appRouter.navigateBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading) {
                        Text("الإشعارات")
                            .customFont(weight: .bold, size: 20)
                        Text("قم بالتحكم بالإشعارات الواردة لك!")
                            .customFont(weight: .regular, size: 10)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationsSettingsView()
        .environmentObject(AppRouter())
}
