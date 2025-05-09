//
//  ChatListView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel: ChatListViewModel

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: ChatListViewModel(userId: userId))
    }
    
    init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }


    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.chats, id: \.id) { chat in
                    Button {
                        appRouter.navigate(to: .chatDetail(chat.id ?? ""))
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            // صورة المستخدم
                            if let url = viewModel.getUserImageURL(for: chat) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 44, height: 44)
                            }

                            // نص المحادثة
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(viewModel.getUserName(for: chat))
                                        .font(.system(size: 14, weight: .semibold))

                                    Spacer()

                                    Text(chat.lastMessageDateFormatted)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Text(chat.lastMessage ?? "")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)

                                Text("مشروع: \(chat.orderId ?? "بدون")")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading) {
                    Text("الرسائل 💬")
                        .customFont(weight: .bold, size: 20)
                    Text("التواصل مع عملائك")
                        .customFont(weight: .regular, size: 10)
                }
                .foregroundColor(Color.black222020())
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
    }
}

//#Preview {
//    ChatListView(userId: "")
//        .environmentObject(AppState())
//}

#Preview {
    ChatListView(viewModel: MockChatListViewModel(userId: "user1"))
        .environmentObject(AppRouter())
}

