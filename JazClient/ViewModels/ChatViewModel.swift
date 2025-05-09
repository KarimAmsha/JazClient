//
//  ChatViewModel.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

//  ChatViewModel.swift
//  FreelanceApp
//  Created by Karim OTHMAN on 8.05.2025.

import SwiftUI
import FirebaseDatabase

class ChatViewModel: ObservableObject {
    @Published var messages: [FirebaseMessage] = []
    @Published var chat: FirebaseChat?
    @Published var messageText: String = ""
    @Published var isOtherUserTyping: Bool = false

    private var dbRef = Database.database().reference()
    private var chatId: String
    let currentUserId: String
    private var listenerHandle: DatabaseHandle?
    private let userService = FirebaseUserService()
    private let pushService = PushNotificationService()
    private var typingTimer: Timer?

    init(chatId: String, currentUserId: String) {
        self.chatId = chatId
        self.currentUserId = currentUserId

        #if DEBUG
        if chatId == "debug" {
            self.messages = [
                FirebaseMessage(id: "1", message: "أهلاً، هذا مثال!", messageDate: Int(Date().timeIntervalSince1970 - 100), senderId: "user2"),
                FirebaseMessage(id: "2", message: "تجريب الرسائل", messageDate: Int(Date().timeIntervalSince1970 - 60), senderId: "user1")
            ]
            self.chat = FirebaseChat(id: chatId, chatEnabled: true, lastMessage: "تجريب الرسائل", lastMessageDate: Int(Date().timeIntervalSince1970 - 60), orderId: "ORD_TEST", senderId: "user1", receiverId: "user2", messagesList: nil)
            return
        }
        #endif

        observeMessages()
    }

    deinit {
        if let handle = listenerHandle {
            dbRef.child("messages").child(chatId).child("messagesList").removeObserver(withHandle: handle)
        }
        dbRef.child("typingStatus").child(chatId).child(currentUserId).removeValue()
    }

    private func observeMessages() {
        listenerHandle = dbRef.child("messages").child(chatId).child("messagesList")
            .observe(.value) { snapshot in
                var tempMessages: [FirebaseMessage] = []

                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any] {
                        let message = FirebaseMessage(
                            id: dict["id"] as? String,
                            message: dict["message"] as? String,
                            messageDate: dict["messageDate"] as? Int,
                            senderId: dict["senderId"] as? String
                        )
                        tempMessages.append(message)
                    }
                }

                DispatchQueue.main.async {
                    self.messages = tempMessages.sorted { ($0.messageDate ?? 0) < ($1.messageDate ?? 0) }
                }
            }

        dbRef.child("messages").child(chatId).observeSingleEvent(of: .value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let chat = FirebaseChat(
                    id: snapshot.key,
                    chatEnabled: dict["chatEnabled"] as? Bool,
                    lastMessage: dict["lastMessage"] as? String,
                    lastMessageDate: dict["lastMessageDate"] as? Int,
                    orderId: dict["orderId"] as? String,
                    senderId: dict["senderId"] as? String,
                    receiverId: dict["receiverId"] as? String,
                    messagesList: nil
                )
                DispatchQueue.main.async {
                    self.chat = chat
                    self.observeTypingStatus()
                }
            }
        }
    }

    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let chat = chat else { return }

        let timestamp = Int(Date().timeIntervalSince1970)
        let newMessageRef = dbRef.child("messages").child(chatId).child("messagesList").childByAutoId()
        let messageId = newMessageRef.key ?? UUID().uuidString

        let messageData: [String: Any] = [
            "id": messageId,
            "message": messageText,
            "messageDate": timestamp,
            "senderId": currentUserId
        ]

        newMessageRef.setValue(messageData)

        dbRef.child("messages").child(chatId).updateChildValues([
            "lastMessage": messageText,
            "lastMessageDate": timestamp
        ])

        let receiverId = chat.senderId == currentUserId ? chat.receiverId : chat.senderId

        if let receiverId = receiverId {
            userService.fetchUser(userId: receiverId) { user in
                if let token = user?.fcmToken {
                    self.pushService.sendPush(
                        to: token,
                        title: "رسالة جديدة",
                        body: self.messageText
                    )
                }
            }
        }

        messageText = ""
        stopTyping()
    }

    func startTyping() {
        dbRef.child("typingStatus").child(chatId).child(currentUserId).setValue(true)
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.stopTyping()
        }
    }

    func stopTyping() {
        dbRef.child("typingStatus").child(chatId).child(currentUserId).setValue(false)
    }

    private func observeTypingStatus() {
        guard let chat = chat else { return }
        let otherUserId = chat.senderId == currentUserId ? chat.receiverId : chat.senderId

        if let otherUserId = otherUserId {
            dbRef.child("typingStatus").child(chatId).child(otherUserId)
                .observe(.value) { snapshot in
                    let isTyping = snapshot.value as? Bool ?? false
                    DispatchQueue.main.async {
                        self.isOtherUserTyping = isTyping
                    }
                }
        }
    }
}

class MockChatViewModel: ChatViewModel {
    init() {
        super.init(chatId: "mock_chat_id", currentUserId: "user1")
        self.messages = [
            FirebaseMessage(id: "1", message: "مرحبا، كيف فيني أساعدك؟", messageDate: Int(Date().timeIntervalSince1970 - 300), senderId: "user2"),
            FirebaseMessage(id: "2", message: "عندي استفسار عن الخدمة اللي بتقدمها", messageDate: Int(Date().timeIntervalSince1970 - 200), senderId: "user1"),
            FirebaseMessage(id: "3", message: "تفضل، احكيلي التفاصيل", messageDate: Int(Date().timeIntervalSince1970 - 100), senderId: "user2")
        ]
        self.chat = FirebaseChat(
            id: "mock_chat_id",
            chatEnabled: true,
            lastMessage: "تفضل، احكيلي التفاصيل",
            lastMessageDate: Int(Date().timeIntervalSince1970 - 100),
            orderId: "ORD999",
            senderId: "user1",
            receiverId: "user2",
            messagesList: nil
        )
        self.isOtherUserTyping = true
    }
}
