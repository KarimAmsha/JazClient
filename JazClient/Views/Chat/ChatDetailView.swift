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
    
    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages, id: \.id) { msg in
                        ChatBubble(text: msg.message ?? "", isSender: msg.senderId == viewModel.currentUserId)
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

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.chat?.senderId == viewModel.currentUserId ? "العميل" : "مقدم الخدمة")
                    .customFont(weight: .bold, size: 16)
                Text(viewModel.isOtherUserTyping ? "يكتب الآن..." : "متاح الآن")
                    .font(.caption)
                    .foregroundColor(viewModel.isOtherUserTyping ? .orange : .green)
            }
        }
    }
}

//#Preview {
//    ChatDetailView(chatId: "", currentUserId: "")
//        .environmentObject(AppState())
//}

#Preview {
    ChatDetailView(viewModel: MockChatViewModel())
        .environmentObject(AppRouter())
        .environmentObject(UserSettings())
}
