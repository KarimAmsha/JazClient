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
        VStack {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    if viewModel.isLoading {
                        LoadingView()
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            if let addressBook = viewModel.addressBook, addressBook.isEmpty {
                                DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                            } else {
                                List {
                                    ForEach(viewModel.addressBook ?? [], id: \.id) { item in
                                        AddressRowView(item: item)
                                            .onTapGesture {
                                                appRouter.navigate(to: .addressBookDetails(item))
                                            }
                                            .swipeActions {
                                                Button {
                                                    showAlertDeleteMessage(item: item)
                                                } label: {
                                                    Label(LocalizedStringKey.delete, systemImage: "trash")
                                                }
                                                .tint(.red)
                                            }
                                            .listRowSeparator(.hidden)
                                    }
                                }
                                .listStyle(.plain)
                                .listRowInsets(EdgeInsets())
                                .scrollIndicators(.hidden)
                                .environment(\.layoutDirection, .leftToRight)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height)
                        .background(Color.white.cornerRadius(8))
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 24)
                .edgesIgnoringSafeArea(.bottom)
            }

            Spacer()

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
        .background(Color.background())
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
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    deleteAddress(item: item)
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
    
    private func deleteAddress(item: AddressItem) {
        viewModel.deleteAddress(id: item.id ?? "") { message in
            showSuccessMessage(message: message)
            getAddressList()
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
                appRouter.navigateBack()
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
