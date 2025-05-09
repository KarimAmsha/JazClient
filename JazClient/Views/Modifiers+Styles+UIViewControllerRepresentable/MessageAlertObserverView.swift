//
//  MessageAlertObserverView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct MessageAlertObserverView: View {
    @Binding var message: String?
    var alertType: Binding<AlertType>
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        Color.clear
            .onChange(of: message) { newValue in
                if let newValue = newValue {
                    switch alertType.wrappedValue {
                    case .success:
                        appRouter.toggleAppPopup(.alertSuccess("", newValue))
                    case .error:
                        appRouter.toggleAppPopup(.alertError("", newValue))
                    case .info:
                        appRouter.toggleAppPopup(.alertInfo("", newValue))
                    }
                }
            }
    }
}
