//
//  LanguageManager.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Locale = LanguageManager.loadSavedLanguage()

    var isRTL: Bool {
        return currentLanguage.language.languageCode?.identifier == "ar"
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language.locale
        UserDefaults.standard.set(language.rawValue, forKey: "SelectedLanguage")

        // Notify observers about the language change
        objectWillChange.send()

//        // Restart the app
//        restartApp()
    }
    
    private func restartApp() {
        // Terminate the app
        exit(0)
    }

    func currentLanguageKey() -> String {
        return isRTL ? "ar" : "en"
    }

    private static func loadSavedLanguage() -> Locale {
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "SelectedLanguage") {
            return Locale(identifier: savedLanguageCode)
        } else {
            return Locale(identifier: "ar") // Default language
        }
    }
}

enum AppLanguage: String {
    case english = "en"
    case arabic = "ar"

    var locale: Locale {
        return Locale(identifier: self.rawValue)
    }
}
