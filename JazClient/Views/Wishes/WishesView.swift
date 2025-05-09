//
//  WishesView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI
import PopupView

struct WishesView: View {
    let items = Array(1...10)
    @State private var selectedIndex = 0
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = WishesViewModel(errorHandling: ErrorHandling())
    let userId = UserSettings.shared.id ?? ""
    @State var showingCreateView = false
    @State var showingEditView = false
    @State var selectedItem: Group?
    @State var name = ""
    @State var showingAddFriendView = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedIndex = 0
                }) {
                    Text(LocalizedStringKey.myWishesLists)
                        .padding()
                        .customFont(weight: selectedIndex == 0 ? .semiBold : .regular, size: 14)
                        .cornerRadius(8)
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: selectedIndex == 0 ? Color.primaryGradientColor() : Color.grayGradientColor(), foreground: selectedIndex == 0 ? .white : .primaryBlack(), height: 37, radius: 12))

                Button(action: {
                    selectedIndex = 1
                }) {
                    Text(LocalizedStringKey.friendsWishes)
                        .padding()
                        .customFont(weight: selectedIndex == 1 ? .semiBold : .regular, size: 14)
                        .cornerRadius(8)
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: selectedIndex == 1 ? Color.primaryGradientColor() : Color.grayGradientColor(), foreground: selectedIndex == 1 ? .white : .primaryBlack(), height: 37, radius: 12))
            }
            
            if selectedIndex == 0 {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 16)], spacing: 8) {
                        ForEach(viewModel.groups, id: \.self) { item in
                            VStack(spacing: 8) {
                                HStack {
                                    Button(action: {
                                        showingEditView.toggle()
                                        name = item.name ?? ""
                                        selectedItem = item
                                    }) {
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .background(Color.white.cornerRadius(8))
                                    }

                                    Button(action: {
                                        showAlertMessage(item: item)
                                    }) {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.red)
                                            .padding(10)
                                            .background(Color.white.cornerRadius(8))
                                    }

                                    Spacer()
                                }

                                if let items = item.items, !items.isEmpty {
                                    LazyHStack(spacing: 8) {
                                        ForEach(items.prefix(4), id: \.self) { product in
                                            if let imageURLString = product.image, let imageURL = URL(string: imageURLString) {

                                                AsyncImageView(
                                                    width: 65,
                                                    height: 65,
                                                    cornerRadius: 10,
                                                    imageURL: imageURL,
                                                    placeholder: Image(systemName: "photo"),
                                                    contentMode: .fill
                                                )
                                                .cornerRadius(4)
                                                .padding(6)
                                            }
                                        }
                                    }
                                    .frame(height: 80) // Adjust height as necessary
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                        .padding(6)
                                }

                                VStack {
                                    Text(item.name ?? "")
                                        .customFont(weight: .bold, size: 14)
                                        .foregroundColor(.primaryBlack())

                                    Text(item.formattedCreateDate ?? "")
                                        .customFont(weight: .bold, size: 14)
                                        .foregroundColor(.primary())
                                }
                                .padding()
                            }
                            .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
                            .onTapGesture {
                                appRouter.navigate(to: .userWishes(userId, item.id ?? ""))
                            }
                        }
                        
                        Button {
                            showingCreateView.toggle()
                        } label: {
                            VStack(alignment: .center) {
                                Spacer()
                                Text(LocalizedStringKey.newGroup)
                                    .customFont(weight: .bold, size: 15)
                                HStack {
                                    Spacer()
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                    Text(LocalizedStringKey.clickToCreateNewGroup)
                                        .customFont(weight: .medium, size: 15)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .foregroundColor(Color.primary())
                            .padding()
                        }
                        .background(Color.primaryLightHover().cornerRadius(10))
                        .padding(6)
                        .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
                    }
                    
                    if viewModel.shouldLoadMoreData {
                        Color.clear.onAppear {
                            loadMore()
                        }
                    }
                    
                    if viewModel.isFetchingMoreData {
                        LoadingView()
                    }
                    
                    Spacer()
                }
            } else {
                VStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.friends, id: \.self) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    AsyncImageView(
                                        width: 35,
                                        height: 35,
                                        cornerRadius: 17.5,
                                        imageURL: item.friend_id?.image?.toURL(),
                                        placeholder: Image(systemName: "photo.circle"),
                                        contentMode: .fill
                                    )

                                    VStack(alignment: .leading) {
                                        Text(item.friend_id?.full_name ?? "")
                                            .customFont(weight: .semiBold, size: 12)
                                            .foregroundColor(.primaryBlack())

//                                        Text("3 قوائم")
//                                            .customFont(weight: .semiBold, size: 10)
//                                            .foregroundColor(.gray595959())
                                    }
                                    
                                    Spacer()

                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.black292D32())
                                }
                                .padding(.vertical, 8)
                                
                                CustomDivider()
                            }
                            .onTapGesture {
                                if let user = item.friend_id {
                                    appRouter.navigate(to: .friendWishes(user))
                                }
                            }
                        }
                        
                        if viewModel.shouldLoadMoreData {
                            Color.clear.onAppear {
                                loadMoreFriends()
                            }
                        }
                        
                        if viewModel.isFetchingMoreData {
                            LoadingView()
                        }
                        
                        Spacer()

                    }
                    
                    Button {
                        showingAddFriendView.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Text(LocalizedStringKey.friendMsg)
                            Spacer()
                        }
                        .customFont(weight: .bold, size: 14)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 14)
                        .foregroundColor(.primaryBlack())
                        .background(Color.grayEBF0FF().cornerRadius(4))
                        .roundedBackground(cornerRadius: 4, strokeColor: .grayD8E2FF(), lineWidth: 1)
                    }
                }
            }
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text(LocalizedStringKey.myWishes)
                        .customFont(weight: .bold, size: 18)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .popup(isPresented: $showingCreateView) {
            AddGroupView { name, type in
                createGroup(name: name, type: type)
            } onClose: {
                showingCreateView.toggle()
            }

        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .popup(isPresented: $showingEditView) {
            EditGroupView(name: $name) {
                editGroup(id: selectedItem?.id ?? "", name: name)
            } onClose: {
                showingEditView.toggle()
            }
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .popup(isPresented: $showingAddFriendView) {
            AddFriendView { phone in
                addFriend(phone: phone)
            } onClose: {
                showingAddFriendView.toggle()
            }
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            loadData()
            loadFriends()
        }
    }
}

#Preview {
    WishesView()
}

extension WishesView {
    func loadData() {
        viewModel.groups.removeAll()
        viewModel.getWishGroups(page: 0, limit: 10, user_id: userId)
    }
    
    func loadMore() {
        viewModel.loadMoreGroups(limit: 10, user_id: userId)
    }
    
    func loadFriends() {
        viewModel.friends.removeAll()
        viewModel.getFriends(page: 0, limit: 10)
    }
    
    func loadMoreFriends() {
        viewModel.loadMoreFriends(limit: 10)
    }

    func createGroup(name: String, type: String) {
        let params: [String: Any] = [
            "name": name,
            "type": type
        ]
        viewModel.createGroup(params: params) {
            loadData()
            showingCreateView.toggle()
        }
    }
    
    func editGroup(id: String, name: String) {
        let params: [String: Any] = [
            "name": name
        ]
        viewModel.editGroup(id: id, params: params, onsuccess: {
            loadData()
            showingEditView.toggle()
        })
    }

    private func showAlertMessage(item: Group) {
        let alertModel = AlertModel(
            icon: "",
            title: LocalizedStringKey.deleteMessage,
            message: "",
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: false,
            onOKAction: {
                appRouter.togglePopup(nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    deleteGroup(item: item)
                })
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.alert(alertModel))
    }
    
    private func deleteGroup(item: Group) {
        let params: [String: Any] = [
            "name": item.name ?? "",
            "type": item.type ?? ""
        ]
        viewModel.deleteGroup(id: item.id ?? "", params: params) {
            loadData()
        }
    }
    
    func addFriend(phone: String) {
        let params: [String: Any] = [
            "phone_number": phone
        ]
        viewModel.addFriend(params: params, onsuccess: {
            loadFriends()
            showingAddFriendView.toggle()
        })
    }
}

