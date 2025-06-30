//
//  ContactUsView.swift
//  Jaz Client
//
//  Created by Karim Amsha on 25.11.2023.
//

import SwiftUI
import PopupView
import MapKit

struct ContactUsView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @StateObject private var viewModel = UserViewModel(errorHandling: ErrorHandling())
    @State private var description: String = LocalizedStringKey.problemDetails
    @State var placeholderString = LocalizedStringKey.problemDetails
    @FocusState private var keyIsFocused: Bool
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.fullName)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            CustomTextField(text: $name, placeholder: LocalizedStringKey.fullName, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .roundedBackground(cornerRadius: 12, strokeColor: .primary(), lineWidth: 1)
                                .disabled(viewModel.isLoading)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.email)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            CustomTextField(text: $email, placeholder: LocalizedStringKey.email, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .keyboardType(.emailAddress)
                                .roundedBackground(cornerRadius: 12, strokeColor: .primary(), lineWidth: 1)
                                .disabled(viewModel.isLoading)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.phoneNumber)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            CustomTextField(text: $phone, placeholder: LocalizedStringKey.phoneNumber, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .keyboardType(.phonePad)
                                .roundedBackground(cornerRadius: 12, strokeColor: .primary(), lineWidth: 1)
                                .disabled(viewModel.isLoading)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.messageContent)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            
                            TextEditor(text: self.$description)
                                .foregroundColor(self.description == placeholderString ? .gray : .black)
                                .customFont(weight: .regular, size: 14)
                                .onTapGesture {
                                    if self.description == placeholderString {
                                        self.description = ""
                                    }
                                }
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(height: 204)
                                .background(Color.clear)
                                .roundedBackground(cornerRadius: 12, strokeColor: .primary(), lineWidth: 1)
                        }

                        Spacer()

                        if !initialViewModel.appContactItem.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("طرق التواصل:")
                                    .customFont(weight: .bold, size: 16)
                                    .foregroundColor(.black1F1F1F())

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(initialViewModel.appContactItem, id: \.self) { contact in
                                        VStack(alignment: .center, spacing: 8) {
                                            Image(systemName: iconName(for: contact.Name ?? ""))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.primary())

                                            Button(action: {
                                                openContactAction(contact)
                                            }) {
                                                Text(contact.Name ?? "")
                                                    .customFont(weight: .regular, size: 14)
                                                    .foregroundColor(.primary())
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                                    }
                                }
                            }
                        }

                        if viewModel.isLoading {
                            LoadingView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
                
                Button {
                    addComplain()
                } label: {
                    Text(LocalizedStringKey.send)
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .primary(), foreground: .white, height: 48, radius: 8))
                .disabled(viewModel.isLoading)
            }
        }
        .padding(24)
        .dismissKeyboardOnTap()
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
                            .padding(12)
                            .background(Color.white.clipShape(Circle()))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.contactUs)
                            .customFont(weight: .bold, size: 20)
                        Text(LocalizedStringKey.contactUsHint)
                            .customFont(weight: .regular, size: 10)
                    }
                    .foregroundColor(Color.black222020())
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            initialViewModel.fetchContactItems()
        }
    }
    
    func iconName(for name: String) -> String {
        switch name.lowercased() {
        case "فيس بوك", "facebook":
            return "f.square.fill"
        case "تويتر", "twitter":
            return "xmark.circle.fill"
        case "انستجرام", "instagram":
            return "camera.circle.fill"
        case "الايميل", "email":
            return "envelope.fill"
        case "رقم التواصل", "phone":
            return "phone.fill"
        case "واتساب", "whatsapp":
            return "message.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    func openContactAction(_ contact: Contact) {
        guard let data = contact.Data else { return }

        let name = contact.Name?.lowercased() ?? ""

        if name.contains("واتس") || name.contains("whatsapp") {
            let phone = data.filter("0123456789".contains)
            if let url = URL(string: "https://wa.me/\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if name.contains("ايميل") || name.contains("email") {
            if let url = URL(string: "mailto:\(data)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if name.contains("رقم") || name.contains("phone") || data.allSatisfy("0123456789+".contains) {
            let phone = data.filter("0123456789".contains)
            if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } else if data.contains("http"), let url = URL(string: data) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContactUsView()
        .environmentObject(UserSettings())
}

extension ContactUsView {
    func addComplain() {
        let params: [String: Any] = [
            "details": description,
            "full_name": name,
            "email": email,
            "phone_number": phone
        ]
        
        viewModel.addComplain(params: params) { message in
            showMessage(message: message)
        }
    }
    
    private func showMessage(message: String) {
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
