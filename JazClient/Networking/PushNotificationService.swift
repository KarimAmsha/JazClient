//
//  PushNotificationService.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation

class PushNotificationService {
    private let serverKey = "YOUR_FCM_SERVER_KEY" // ضع السيرفر كي هنا
    private let fcmURL = URL(string: "https://fcm.googleapis.com/fcm/send")!

    func sendPush(to token: String, title: String, body: String) {
        let message: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "sound": "default"
            ],
            "data": [
                "click_action": "FLUTTER_NOTIFICATION_CLICK"
            ]
        ]

        var request = URLRequest(url: fcmURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: message, options: [])
        } catch {
            print("❌ Failed to encode FCM message: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Push failed: \(error.localizedDescription)")
            } else {
                print("✅ Push sent to \(token)")
            }
        }.resume()
    }
}
