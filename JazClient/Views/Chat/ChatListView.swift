import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel: ChatListViewModel

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: ChatListViewModel(userId: userId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.chats, id: \.id) { chat in
                    ChatListRow(
                        chat: chat,
                        myId: viewModel.userId,
                        appRouter: appRouter,
                        getUser: viewModel.getUser(for:)
                    )
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

#Preview {
    ChatListView(userId: "")
        .environmentObject(AppState())
}

struct ChatListRow: View {
    let chat: FirebaseChat
    let myId: String
    let appRouter: AppRouter
    let getUser: (String) -> FirebaseUser? // جلب بيانات الطرف الآخر

    var body: some View {
        Button {
            appRouter.navigate(to: .chat(chatId: chat.id ?? "", currentUserId: myId))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // الطرف الآخر (الذي ليس أنت)
                let otherId = (chat.senderId == myId ? chat.receiverId : chat.senderId) ?? ""
                let otherUser = getUser(otherId)

                if let url = otherUser?.profileImageURL {
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

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(otherUser?.displayName ?? "مستخدم")
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
