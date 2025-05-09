//
//  PersonalInfoView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import PopupView
import MapKit

struct PersonalInfoView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var appRouter: AppRouter
    @State private var name = ""
    @State private var email = ""
    @StateObject private var viewModel = UserViewModel(errorHandling: ErrorHandling())
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 24.7136,
            longitude: 46.6753
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 5,
            longitudeDelta: 5
        )
    )
    @State private var description: String = LocalizedStringKey.specificText
    @State var placeholderString = LocalizedStringKey.specificText
    @State private var isFloatingPickerPresented = false
    @StateObject var mediaPickerViewModel = MediaPickerViewModel()
    @FocusState private var keyIsFocused: Bool
    @State private var isShowingDatePicker = false
    @State private var dateStr: String = ""
    @State private var date: Date = Date()

    private var isImageSelected: Bool {
        mediaPickerViewModel.selectedImage != nil
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .center, spacing: 8) {
                            profileImageView()
                                .shadow(color: .primary().opacity(0.16), radius: 2.5, x: 0, y: 5)
                            
                            Button {
                                isFloatingPickerPresented.toggle()
                            } label: {
                                Text(LocalizedStringKey.uploadProfilePicture)
                            }
                            .buttonStyle(PrimaryButton(fontSize: 12, fontWeight: .medium, background: .primaryLightActive(), foreground: .primary(), height: 44, radius: 12))
                            .disabled(viewModel.isLoading)

                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(Color.primaryLightHover().cornerRadius(4))
                        .padding(6)
                        .background(Color.primaryLight().cornerRadius(4))

                        Text(LocalizedStringKey.personalInformation)
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.primaryBlack())

                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey.fullName)
                                .customFont(weight: .medium, size: 12)

                            TextField(LocalizedStringKey.fullName, text: $name)
                                .placeholder(when: name.isEmpty) {
                                    Text(LocalizedStringKey.fullName)
                                        .foregroundColor(.gray999999())
                                }
                                .focused($keyIsFocused)
                                .customFont(weight: .regular, size: 14)
                                .accentColor(.primary())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .roundedBackground(cornerRadius: 12, strokeColor: .primaryBlack(), lineWidth: 1)
                        }
                        .foregroundColor(.black222020())

                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey.email)
                                .customFont(weight: .medium, size: 12)

                            TextField(LocalizedStringKey.email, text: $email)
                                .placeholder(when: name.isEmpty) {
                                    Text(LocalizedStringKey.email)
                                        .foregroundColor(.gray999999())
                                }
                                .focused($keyIsFocused)
                                .customFont(weight: .regular, size: 14)
                                .keyboardType(.emailAddress)
                                .accentColor(.primary())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .roundedBackground(cornerRadius: 12, strokeColor: .primaryBlack(), lineWidth: 1)
                        }
                        .foregroundColor(.black222020())
                        
//                        VStack(alignment: .leading) {
//                            Text(LocalizedStringKey.dob)
//                                .customFont(weight: .medium, size: 12)
//                            
//                            HStack {
//                                TextField(LocalizedStringKey.dmy, text: $dateStr)
//                                    .placeholder(when: dateStr.isEmpty) {
//                                        Text(LocalizedStringKey.dmy)
//                                            .foregroundColor(.gray999999())
//                                    }
//                                    .customFont(weight: .regular, size: 14)
//                                    .disabled(true)
//
//                                Spacer()
//                                
//                                Image("ic_calendar")
//                                    .foregroundColor(.black)
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 18)
//                            .roundedBackground(cornerRadius: 12, strokeColor: .primaryBlack(), lineWidth: 1)
//                            .onTapGesture {
//                                isShowingDatePicker = true
//                            }
//                        }

                        Spacer()

                        if let uploadProgress = viewModel.uploadProgress {
                            // Display the progress view only when upload is in progress
                            LinearProgressView(LocalizedStringKey.loading, progress: uploadProgress, color: .primary())
                        }
                        
                        Button {
                            update()
                        } label: {
                            Text(LocalizedStringKey.saveChanges)
                        }
                        .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .dismissKeyboardOnTap()
        .fullScreenCover(isPresented: $mediaPickerViewModel.isPresentingImagePicker, content: {
            ImagePicker(sourceType: mediaPickerViewModel.sourceType, completionHandler: mediaPickerViewModel.didSelectImage)
        })
        .popup(isPresented: $isFloatingPickerPresented) {
            FloatingPickerView(
                isPresented: $isFloatingPickerPresented,
                onChoosePhoto: {
                    // Handle choosing a photo here
                    mediaPickerViewModel.choosePhoto()
                },
                onTakePhoto: {
                    // Handle taking a photo here
                    mediaPickerViewModel.takePhoto()
                }
            )
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(false)
                .closeOnTap(false)
                .backgroundColor(.black.opacity(0.5))
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Image("ic_gift")

                    VStack(alignment: .leading, spacing: 2) {
                        Text(LocalizedStringKey.myProfile)
                            .customFont(weight: .bold, size: 20)
                        
                        Text(LocalizedStringKey.profileHint)
                            .customFont(weight: .regular, size: 12)
                    }
                    .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onAppear {
            getUserData()

            // Use the user's current location if available
            if let userLocation = LocationManager.shared.userLocation {
                self.userLocation = userLocation
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .popup(isPresented: $isShowingDatePicker) {
            let dateModel = DateTimeModel(pickerMode: .date) { date in
                self.date = date
                dateStr = date.toString(format: "yyyy-MM-dd")
                isShowingDatePicker = false
            } onCancelAction: {
                isShowingDatePicker = false
            }
            
            DateTimePicker(model: dateModel)
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
    }
}

#Preview {
    PersonalInfoView()
        .environmentObject(UserSettings())
        .environmentObject(AppState())
}

extension PersonalInfoView {
    private func getUserData() {
        viewModel.fetchUserData {
            name = viewModel.user?.full_name ?? ""
            email = viewModel.user?.email ?? ""
            dateStr = viewModel.user?.formattedDOB ?? ""
        }
    }
    
    private func update() {
        var imageData: Data? = nil
        var params: [String: Any] = [:]

        if isImageSelected, let uiImage = mediaPickerViewModel.selectedImage {
            // Convert the UIImage to Data, if needed
            imageData = uiImage.jpegData(compressionQuality: 0.8)
        }

        params = [
            "email": email,
            "full_name": name,
            "lat": userLocation?.latitude ?? 0.0,
            "lng": userLocation?.longitude ?? 0.0,
            "address": "",
            "dob": dateStr,
        ]
        
        viewModel.updateUserDataWithImage(imageData: imageData, additionalParams: params) { _ in
            settings.loggedIn = true
        }
    }
}

extension PersonalInfoView {
    @ViewBuilder
    func profileImageView() -> some View {
        if let selectedImage = mediaPickerViewModel.selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .frame(width: 115, height: 115)
                .cornerRadius(8)
        } else {
            let imageURL = viewModel.user?.image?.toURL()
            AsyncImageView(
                width: 115,
                height: 115,
                cornerRadius: 8,
                imageURL: imageURL,
                placeholder: Image(systemName: "photo.circle"),
                contentMode: .fill
            )
        }
    }
}
