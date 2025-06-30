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

    init(chatId: String, currentUserId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId, currentUserId: currentUserId))
    }
    
//    init(viewModel: ChatViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages, id: \.id) { msg in
                        let isSender = msg.senderId == viewModel.currentUserId
                        let receiverUser = !isSender ? viewModel.getUser(for: msg.senderId ?? "") : nil

                        ChatBubble(
                            text: msg.message ?? "",
                            isSender: isSender,
                            receiverImageURL: receiverUser?.profileImageURL
                        )
                    }

                    if viewModel.isOtherUserTyping {
                        HStack {
                            Text("يكتب الآن...")
                                .font(.caption)
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
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color.background())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                chatTopBar
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Image("profile_sample")
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
            
            if let otherId = getOtherUserId(),
               let otherUser = viewModel.getUser(for: otherId) {
                if let url = otherUser.profileImageURL {
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
                    Text(otherUser.displayName)
                        .customFont(weight: .bold, size: 16)
                    Text(viewModel.isOtherUserTyping ? "يكتب الآن..." : "متاح الآن")
                        .font(.caption)
                        .foregroundColor(viewModel.isOtherUserTyping ? .orange : .green)
                }
            } else {
                // Loader أو Placeholder حتى تجيب البيانات
                ProgressView()
                    .frame(width: 36, height: 36)
                    .padding(.trailing, 4)
                Text("جاري التحميل ...")
                    .customFont(weight: .bold, size: 16)
            }
        }
    }
    
    // Helper to get the other user's id
    private func getOtherUserId() -> String? {
        guard let chat = viewModel.chat else { return nil }
        let id = (chat.senderId == viewModel.currentUserId ? chat.receiverId : chat.senderId)
        return (id?.isEmpty ?? true) ? nil : id
    }
}

#Preview {
    ChatDetailView(chatId: "", currentUserId: "")
        .environmentObject(AppState())
}

//#Preview {
//    ChatDetailView(viewModel: MockChatViewModel())
//        .environmentObject(AppRouter())
//        .environmentObject(UserSettings())
//}
