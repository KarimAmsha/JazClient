//
//  AddressBookView.swift
//  Fazaa
//
//  Created by Karim Amsha on 29.02.2024.
//

import SwiftUI

struct AddressBookView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var viewModel = UserViewModel(errorHandling: ErrorHandling())

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                LoadingView()
            }

            if let addressBook = viewModel.addressBook, addressBook.isEmpty {
                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.cornerRadius(8))
                    .padding(.horizontal, 24)
            } else {
                // اجعل List هو عنصر التمرير الوحيد
                List {
                    ForEach(viewModel.addressBook ?? [], id: \.id) { item in
                        AddressRowView(item: item)
                            .onTapGesture {
                                appRouter.navigate(to: .addressBookDetails(item))
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    showAlertDeleteMessage(item: item)
                                } label: {
                                    Label(LocalizedStringKey.delete, systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .environment(\.layoutDirection, .leftToRight)
                .background(Color.white.cornerRadius(8))
                .padding(.horizontal, 24)
            }

            // زر الإضافة العائم
            HStack {
                Spacer()
                Button(action: {
                    appRouter.navigate(to: .addAddressBook)
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.primary())
                        .clipShape(Circle())
                }
                .padding(.bottom, 24)
                .padding(.trailing, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.background().ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        withAnimation {
                            appRouter.navigateBack()
                        }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: 20, height: 15)
                            .foregroundColor(.black)
                            .padding(.vertical, 13)
                            .padding(.horizontal, 8)
                            .background(Color.white.cornerRadius(8))
                    }

                    Text(LocalizedStringKey.addressBook)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.black141F1F())
                }
            }
        }
        .onAppear {
            getAddressList()
        }
        // استقبل إشعار التحديث بعد الإضافة/التعديل
        .onReceive(NotificationCenter.default.publisher(for: .addressBookUpdated)) { _ in
            getAddressList()
        }
    }
}

#Preview {
    AddressBookView()
}

extension AddressBookView {
    private func getAddressList() {
        viewModel.getAddressList()
    }

    private func showAlertDeleteMessage(item: AddressItem) {
        let alertModel = AlertModel(
            icon: "",
            title: LocalizedStringKey.delete,
            message: LocalizedStringKey.deleteMessage,
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: false,
            onOKAction: {
                appRouter.togglePopup(nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    deleteAddress(item: item)
                }
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.alert(alertModel))
    }

    private func deleteAddress(item: AddressItem) {
        // حذف متفائل: حدّث القائمة محليًا فورًا
        if let idx = viewModel.addressBook?.firstIndex(where: { $0.id == item.id }) {
            viewModel.addressBook?.remove(at: idx)
        }

        viewModel.deleteAddress(id: item.id ?? "") { message in
            // أعد الجلب للتأكد من الاتساق
            getAddressList()
            showSuccessMessage(message: message)
        }
    }

    private func showSuccessMessage(message: String) {
        let alertModel = AlertModel(
            icon: "",
            title: "",
            message: message,
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: true,
            onOKAction: {
                appRouter.togglePopup(nil)
                // لا نعود للخلف؛ نبقى في الشاشة ليرى المستخدم أن العنصر اختفى
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.alert(alertModel))
    }
}

// إشعار مشترك لتحديث القائمة بعد إضافة/تعديل/حذف
extension Notification.Name {
    static let addressBookUpdated = Notification.Name("addressBookUpdated")
}
