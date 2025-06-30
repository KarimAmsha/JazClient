//
//  ChatListViewModel.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

//  ChatListViewModel.swift

import SwiftUI
import FirebaseDatabase

class ChatListViewModel: ObservableObject {
    @Published var chats: [FirebaseChat] = []
    @Published var users: [String: FirebaseUser] = [:] // userId -> FirebaseUser

    private var dbRef = Database.database().reference()
    var userId: String
    private var listenerHandle: DatabaseHandle?
    private let userService = FirebaseUserService()

    init(userId: String) {
        self.userId = userId
        observeChats()
    }

    deinit {
        if let handle = listenerHandle {
            dbRef.child("messages").removeObserver(withHandle: handle)
        }
    }

    private func observeChats() {
        listenerHandle = dbRef.child("messages")
            .observe(.value) { snapshot in
                var tempChats: [FirebaseChat] = []

                for child in snapshot.children {
                    if let chatSnap = child as? DataSnapshot,
                       let dict = chatSnap.value as? [String: Any] {

                        let chat = FirebaseChat(
                            id: chatSnap.key,
                            chatEnabled: dict["chatEnabled"] as? Bool,
                            lastMessage: dict["lastMessage"] as? String,
                            lastMessageDate: dict["lastMessageDate"] as? Int64,
                            orderId: dict["orderId"] as? String,
                            senderId: dict["senderId"] as? String,
                            receiverId: dict["receiverId"] as? String,
                            messagesList: nil
                        )

                        if chat.senderId == self.userId || chat.receiverId == self.userId {
                            tempChats.append(chat)

                            // تحميل بيانات المستخدم الآخر
                            if let otherId = (chat.senderId == self.userId ? chat.receiverId : chat.senderId) {
                                self.loadUserIfNeeded(userId: otherId)
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.chats = tempChats.sorted { ($0.lastMessageDate ?? 0) > ($1.lastMessageDate ?? 0) }
                }
            }
    }

    private func loadUserIfNeeded(userId: String) {
        guard users[userId] == nil else { return }

        userService.fetchUser(userId: userId) { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.users[userId] = user
                }
            }
        }
    }

    func getUserName(for chat: FirebaseChat) -> String {
        let otherId = chat.senderId == userId ? chat.receiverId : chat.senderId
        return users[otherId ?? ""]?.displayName ?? "مستخدم"
    }

    func getUserImageURL(for chat: FirebaseChat) -> URL? {
        let otherId = chat.senderId == userId ? chat.receiverId : chat.senderId
        return users[otherId ?? ""]?.profileImageURL
    }
}

// MARK: - FirebaseChat Helper Extension

extension FirebaseChat {
    var lastMessageDateFormatted: String {
        guard let timestamp = lastMessageDate else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class MockChatListViewModel: ChatListViewModel {
    override init(userId: String) {
        super.init(userId: userId)

        self.chats = [
            FirebaseChat(
                id: "debug_1",
                chatEnabled: true,
                lastMessage: "مرحباً، متى يتم التسليم؟",
                lastMessageDate: Int64(Date().timeIntervalSince1970 - 3600),
                orderId: "ORD1001",
                senderId: "user1",
                receiverId: "user2",
                messagesList: nil
            ),
            FirebaseChat(
                id: "debug_2",
                chatEnabled: true,
                lastMessage: "تم إرسال الملف ✅",
                lastMessageDate: Int64(Date().timeIntervalSince1970 - 7200),
                orderId: "ORD1002",
                senderId: "user2",
                receiverId: "user1",
                messagesList: nil
            )
        ]

        self.users = [
            "user2": FirebaseUser(id: "user2", fcmToken: nil, image: nil, lastOnline: nil, name: "سارة", online: true)
        ]
    }
}

extension ChatListViewModel {
    func getUser(for userId: String) -> FirebaseUser? {
        guard !userId.isEmpty, userId.rangeOfCharacter(from: CharacterSet(charactersIn: ".$#[]")) == nil else { return nil }

        if let user = users[userId] {
            return user
        }
        // جلب من الداتابيز إذا لم يكن موجود
        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let user = try JSONDecoder().decode(FirebaseUser.self, from: jsonData)
                DispatchQueue.main.async {
                    self.users[userId] = user
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        return nil // أول مرة، البيانات ليست جاهزة
    }

}
