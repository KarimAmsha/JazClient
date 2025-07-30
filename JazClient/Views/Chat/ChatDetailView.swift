//
//  ChatDetailView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel: ChatViewModel

    @State private var otherUserId: String?
    @State private var receiverId: String?

    init(chatId: String, currentUserId: String, receiverId: String?) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId, currentUserId: currentUserId, receiverId: receiverId))
        _receiverId = State(initialValue: receiverId)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages, id: \.id) { msg in
                        let isSender = msg.senderId == viewModel.currentUserId
                        let receiverUser = !isSender ? viewModel.users[msg.senderId ?? ""] : nil

                        ChatBubble(
                            text: msg.message ?? "",
                            isSender: isSender,
                            receiverImageURL: receiverUser?.profileImageURL
                        )
                        .onAppear {
                            if let senderId = msg.senderId, !isSender {
                                viewModel.fetchUserIfNeeded(for: senderId)
                            }
                        }
                    }

                    if viewModel.isOtherUserTyping {
                        HStack {
                            Text("يكتب الآن...")
                                .customFont(weight: .regular, size: 14)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }

            ChatInputBar(text: $viewModel.messageText) {
                viewModel.sendMessage()
            }
            .onChange(of: viewModel.messageText) { _ in
                viewModel.startTyping()
            }
        }
        .onAppear {
            let id = getOtherUserId()
            otherUserId = id
            if let otherId = id {
                viewModel.fetchUserIfNeeded(for: otherId)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color.background())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                chatTopBar
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
        }
    }

    private var chatTopBar: some View {
        HStack(spacing: 8) {
            Button(action: {
                appRouter.navigateBack()
            }) {
                Image(systemName: "chevron.backward")
                    .foregroundColor(.black)
            }

            if let otherId = otherUserId {
                let otherUser = viewModel.users[otherId]

                HStack {
                    if let user = otherUser {
                        if let url = user.profileImageURL {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName)
                                .customFont(weight: .bold, size: 16)
                            Text(viewModel.isOtherUserTyping ? "يكتب الآن..." : "متاح الآن")
                                .customFont(weight: .regular, size: 14)
                                .foregroundColor(viewModel.isOtherUserTyping ? .orange : .green)
                        }
                    } else {
                        ProgressView()
                            .frame(width: 36, height: 36)
                            .padding(.trailing, 4)
                        Text("جاري التحميل ...")
                            .customFont(weight: .bold, size: 16)
                    }
                }
            }
        }
    }

    private func getOtherUserId() -> String? {
        guard let otherId = receiverId, !otherId.isEmpty, otherId != viewModel.currentUserId else {
            return nil
        }
        return otherId
    }
}


#Preview {
    ChatDetailView(chatId: "", currentUserId: "", receiverId: "")
        .environmentObject(AppState())
}
