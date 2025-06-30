import SwiftUI
import PopupView
import MapKit

struct EditProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var name = ""
    @State private var email = ""
    @State private var dateStr: String = ""
    @State private var userLocation: CLLocationCoordinate2D? = nil

    @StateObject private var viewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject private var mediaPickerViewModel = MediaPickerViewModel()
    @State private var isFloatingPickerPresented = false

    private var isImageSelected: Bool {
        mediaPickerViewModel.selectedImage != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Profile Image Section
                    HStack(spacing: 16) {
                        profileImageView()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))

                        Spacer()

                        Button(action: {
                            isFloatingPickerPresented.toggle()
                        }) {
                            Text("اضغط لرفع صورة جديدة")
                                .font(.system(size: 14))
                                .foregroundColor(.primary())
                        }

                        Spacer()
                        
                        Button(action: {
                            isFloatingPickerPresented.toggle()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                        }

                    }
                    .padding()
                    .background(Color.primary().opacity(0.2))
                    .cornerRadius(12)

                    // MARK: - Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("اسم العرض")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))

                        TextField("", text: $name)
                            .padding()
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4))
                            )
                    }

                    // MARK: - Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("البريد الإلكتروني")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))

                        TextField("", text: $email)
                            .padding()
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4))
                            )
                            .keyboardType(.emailAddress)
                    }

                    // MARK: - Save Button
                    Button(action: {
                        update()
                    }) {
                        Text("حفظ التغييرات")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color.primary())
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .background(Color.background())
        .onAppear {
            getUserData()
            if let location = LocationManager.shared.userLocation {
                userLocation = location
            }
        }
        .fullScreenCover(isPresented: $mediaPickerViewModel.isPresentingImagePicker) {
            ImagePicker(sourceType: mediaPickerViewModel.sourceType, completionHandler: mediaPickerViewModel.didSelectImage)
        }
        .popup(isPresented: $isFloatingPickerPresented) {
            FloatingPickerView(
                isPresented: $isFloatingPickerPresented,
                onChoosePhoto: mediaPickerViewModel.choosePhoto,
                onTakePhoto: mediaPickerViewModel.takePhoto
            )
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(Color.black.opacity(0.5))
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }

                    Text("اسم وصورة العرض")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
    }

    // MARK: - Profile Image View
    @ViewBuilder
    func profileImageView() -> some View {
        if let selectedImage = mediaPickerViewModel.selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            let imageURL = viewModel.user?.image?.toURL()
            AsyncImageView(
                width: 90,
                height: 90,
                cornerRadius: 45,
                imageURL: imageURL,
                placeholder: Image(systemName: "person.fill"),
                contentMode: .fill
            )
        }
    }

    // MARK: - Update Profile
    private func update() {
        var imageData: Data? = nil
        if isImageSelected, let uiImage = mediaPickerViewModel.selectedImage {
            imageData = uiImage.jpegData(compressionQuality: 0.8)
        }

        let params: [String: Any] = [
            "full_name": name,
            "email": email,
            "lat": userLocation?.latitude ?? 0.0,
            "lng": userLocation?.longitude ?? 0.0
        ]

        viewModel.updateUserDataWithImage(imageData: imageData, additionalParams: params) { message in
            ChatViewModel.setUser()
            showMessage(message: message)
        }
    }

    private func getUserData() {
        viewModel.fetchUserData {
            name = viewModel.user?.full_name ?? ""
            email = viewModel.user?.email ?? ""
            dateStr = viewModel.user?.formattedDOB ?? ""
        }
    }

    private func showMessage(message: String) {
        let alertModel = AlertModel(
            icon: "",
            title: "",
            message: message,
            hasItem: false,
            item: nil,
            okTitle: "تم",
            cancelTitle: "رجوع",
            hidesIcon: true,
            hidesCancel: true
        ) {
            appRouter.dismissPopup()
            appRouter.navigateBack()
        } onCancelAction: {
            appRouter.dismissPopup()
        }

        appRouter.togglePopup(.alert(alertModel))
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserSettings())
        .environmentObject(AppState())
}








