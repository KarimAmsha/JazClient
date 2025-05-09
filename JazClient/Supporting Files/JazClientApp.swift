//
//  JazClientApp.swift
//  JazClientApp
//
//  Created by Karim Amsha on 23.04.2024.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import FirebaseCrashlytics
import goSellSDK

@main
struct JazClientApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var languageManager = LanguageManager()
    @StateObject var appState = AppState()
    @StateObject private var authViewModel = AuthViewModel(errorHandling: ErrorHandling())
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject private var settings = UserSettings.shared
//    @StateObject private var notificationHandler = NotificationHandler()
//    @StateObject private var chatHelper = ChatHelper()

    init() {
        UserDefaults.standard.set([languageManager.currentLanguage.identifier], forKey: "AppleLanguages")
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
                .environment(\.locale, languageManager.currentLanguage)
                .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
                .environmentObject(appState)
                .environmentObject(authViewModel)
                .environmentObject(settings)
//                .environmentObject(notificationHandler)
//                .environmentObject(chatHelper)
                .preferredColorScheme(.light)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GoSellSDK.secretKey = SecretKey(sandbox:    "sk_test_YJlOMLfZPekucyKhnwSDUzog",
                                        production:    "sk_live_zqam2B5Xng8jrhPGpN4dK7Qe")

        configureNotifications(application)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        return true
    }

    func configureNotifications(_ application:UIApplication){
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {(granted, error) in })
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    //Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
//            NotificationHandler.shared.handleRemoteNotification(userInfo: userInfo)
            completionHandler()
        }
    }
}

extension AppDelegate : MessagingDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NotificationHandler.shared.handleRemoteNotification(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }


    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print(fcmToken)
    }

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        Messaging.messaging().isAutoInitEnabled = true
    }
}

