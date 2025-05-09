//
//  FirebaseUserService.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import Foundation
import FirebaseDatabase

class FirebaseUserService {
    private let dbRef = Database.database().reference()

    func fetchUser(userId: String, completion: @escaping (FirebaseUser?) -> Void) {
        dbRef.child("user").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }

            let user = FirebaseUser(
                id: userId,
                fcmToken: dict["fcmToken"] as? String,
                image: dict["image"] as? String,
                lastOnline: dict["lastOnline"] as? Int,
                name: dict["name"] as? String,
                online: dict["online"] as? Bool
            )

            completion(user)
        }
    }
}
