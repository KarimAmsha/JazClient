//
//  AddAddressView.swift
//  Fazaa
//
//  Created by Karim Amsha on 29.02.2024.
//

import SwiftUI
import MapKit

struct AddAddressView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var title = ""
    @State private var streetName = ""
    @State private var buildingNo = ""
    @State private var floorNo = ""
    @State private var flatNo = ""
    @State private var address = ""
    private let errorHandling = ErrorHandling()
    @EnvironmentObject var settings: UserSettings
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
    @State private var locations: [Mark] = []
    @State private var addressPlace: PlaceType = .home
    @State private var isShowingMap = false

    // حالة التحقق
    @State private var showValidation = false

    // Toast نجاح
    @State private var showSuccessToast = false
    @State private var successText: String = ""

    // قواعد الإلزام (يمكن تعديلها بحسب متطلبات الـ API)
    private var isTitleValid: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isAddressValid: Bool { !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isStreetValid: Bool { !streetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isBuildingValid: Bool { !buildingNo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    // اعتبرنا الحقول الإلزامية: الاسم، الشارع، رقم المبنى، العنوان (من الخريطة)
    private var isFormValid: Bool {
        isTitleValid && isAddressValid && isStreetValid && isBuildingValid
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        Text(LocalizedStringKey.addressDetails)
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.black1F1F1F())

                        // شريط إرشادي: أفضل ممارسات لتوضيح المطلوب
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("الحقول المعلّمة بعلامة ✱ مطلوبة لإضافة العنوان بنجاح: الاسم، الشارع، رقم المبنى، وتحديد الموقع على الخريطة.")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Text("يمكنك تحريك الخريطة أو التكبير لتحديد موقعك بدقة، وسيتم تعبئة العنوان تلقائياً.")
                                .customFont(weight: .regular, size: 11)
                                .foregroundColor(.gray)
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.10))
                        .cornerRadius(8)

                        HStack {
                            createButton(image: "ic_house", title: LocalizedStringKey.house, place: .home)
                            createButton(image: "ic_work", title: LocalizedStringKey.work, place: .work)
                        }
                        .frame(maxWidth: .infinity)

                        // اسم العنوان (إلزامي)
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("الاسم")
                            CustomTextField(
                                text: $title,
                                placeholder: LocalizedStringKey.homeAddress,
                                textColor: .black4E5556(),
                                placeholderColor: .grayA4ACAD()
                            )
                            .disabled(viewModel.isLoading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((showValidation && !isTitleValid) ? Color.red.opacity(0.85) : .clear, lineWidth: 1)
                            )
                            if showValidation && !isTitleValid {
                                validationText("هذا الحقل مطلوب")
                            }
                        }

                        // الخريطة + تلميح
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("الموقع على الخريطة")
                            ZStack {
                                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
                                    MapAnnotation(
                                        coordinate: location.coordinate,
                                        anchorPoint: CGPoint(x: 0.5, y: 0.7)
                                    ) {
                                        VStack{
                                            if location.show {
                                                Text(location.title)
                                                    .customFont(weight: .bold, size: 14)
                                                    .foregroundColor(.black131313())
                                            }
                                            Image(location.imageName)
                                                .font(.title)
                                                .foregroundColor(.red)
                                                .onTapGesture {
                                                    let index: Int = locations.firstIndex(where: {$0.id == location.id})!
                                                    locations[index].show.toggle()
                                                }
                                        }
                                    }
                                }
                                .disabled(true)
                                .onChange(of: region, perform: { newRegion in
                                    Utilities.getAddress(for: newRegion.center) { address in
                                        self.address = address
                                    }
                                })
                                .onAppear {
                                    moveToUserLocation()
                                }

                                Image("ic_logo")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())

                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "square.arrowtriangle.4.outward")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                isShowingMap = true
                                            }
                                    }
                                }
                                .padding(10)
                                .sheet(isPresented: $isShowingMap) {
                                    FullMapView(region: $region, isShowingMap: $isShowingMap, address: $address)
                                }
                            }
                            .frame(height: 250)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((showValidation && !isAddressValid) ? Color.red.opacity(0.85) : .clear, lineWidth: 1)
                            )

                            // العنوان النصي المستنتج
                            Text(address.isEmpty ? "حرّك الخريطة أو كبّر لتحديد موقعك بدقة" : address)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(address.isEmpty ? .gray : .black131313())

                            if showValidation && !isAddressValid {
                                validationText("تحديد الموقع مطلوب")
                            }
                        }

                        // الشارع (إلزامي)
                        VStack(alignment: .leading, spacing: 8) {
                            requiredLabel("الشارع")
                            CustomTextField(
                                text: $streetName,
                                placeholder: LocalizedStringKey.streetName,
                                textColor: .black4E5556(),
                                placeholderColor: .grayA4ACAD()
                            )
                            .disabled(viewModel.isLoading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((showValidation && !isStreetValid) ? Color.red.opacity(0.85) : .clear, lineWidth: 1)
                            )
                            if showValidation && !isStreetValid {
                                validationText("هذا الحقل مطلوب")
                            }
                        }

                        HStack(spacing: 8) {
                            // رقم المبنى (إلزامي)
                            VStack(alignment: .leading, spacing: 8) {
                                requiredLabel("رقم المبنى")
                                CustomTextField(
                                    text: $buildingNo,
                                    placeholder: LocalizedStringKey.buildingNo,
                                    textColor: .black4E5556(),
                                    placeholderColor: .grayA4ACAD()
                                )
                                .disabled(viewModel.isLoading)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke((showValidation && !isBuildingValid) ? Color.red.opacity(0.85) : .clear, lineWidth: 1)
                                )
                                if showValidation && !isBuildingValid {
                                    validationText("هذا الحقل مطلوب")
                                }
                            }

                            // رقم الدور (اختياري)
                            VStack(alignment: .leading, spacing: 8) {
                                optionalLabel("رقم الدور")
                                CustomTextField(
                                    text: $floorNo,
                                    placeholder: LocalizedStringKey.floorNo,
                                    textColor: .black4E5556(),
                                    placeholderColor: .grayA4ACAD()
                                )
                                .disabled(viewModel.isLoading)
                            }
                        }

                        HStack(spacing: 8) {
                            // رقم الشقة (اختياري)
                            VStack(alignment: .leading, spacing: 8) {
                                optionalLabel("رقم الشقة")
                                CustomTextField(
                                    text: $flatNo,
                                    placeholder: LocalizedStringKey.flatNo,
                                    textColor: .black4E5556(),
                                    placeholderColor: .grayA4ACAD()
                                )
                                .disabled(viewModel.isLoading)
                            }

                            Spacer()
                        }

                        Spacer()

                        if viewModel.isLoading {
                            LoadingView()
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }

                VStack {
                    Button {
                        withAnimation {
                            showValidation = true
                            add()
                        }
                    } label: {
                        Text(LocalizedStringKey.send)
                    }
                    .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: isFormValid ? .primary() : .gray.opacity(0.4), foreground: .white, height: 48, radius: 8))
                    .disabled(viewModel.isLoading || !isFormValid)
                }
                .padding(24)
                .background(Color.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: -3)
                )
            }
        }
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
                            .padding(.vertical, 13)
                            .padding(.horizontal, 8)
                            .background(Color.white.cornerRadius(8))
                    }

                    Text(LocalizedStringKey.addAddress)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.black141F1F())
                }
            }
        }
        .onAppear {
            // اجلب موقع المستخدم الحقيقي وحدّث المنطقة
            LocationManager.shared.getCurrentLocation { location in
                if let location = location {
                    self.userLocation = location
                    self.region.center = location
                    self.region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        // Toast النجاح أعلى الشاشة
        .overlay(alignment: .top) {
            if showSuccessToast {
                SuccessToast(message: successText)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showSuccessToast)
    }

    // شارة توضح حالة الحقل المطلوب
    private func requiredBadge(_ title: String, isOK: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: isOK ? "checkmark.circle.fill" : "exclamationmark.circle")
                .foregroundColor(isOK ? .green : .red)
            Text(title)
                .customFont(weight: .regular, size: 12)
                .foregroundColor(isOK ? .green : .red)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background((isOK ? Color.green.opacity(0.10) : Color.red.opacity(0.10)).cornerRadius(8))
    }

    private func requiredLabel(_ title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .customFont(weight: .regular, size: 12)
                .foregroundColor(.black1F1F1F())
            // استخدم نجمة بديلة لمنع استبدال الخط لها بشعار
            Text("✱")
                .customFont(weight: .bold, size: 14)
                .foregroundColor(.red)
        }
    }

    private func optionalLabel(_ title: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .customFont(weight: .regular, size: 12)
                .foregroundColor(.black1F1F1F())
            Text("(اختياري)")
                .customFont(weight: .regular, size: 11)
                .foregroundColor(.gray)
        }
    }

    private func validationText(_ msg: String) -> some View {
        Text(msg)
            .customFont(weight: .regular, size: 11)
            .foregroundColor(.red)
    }

    // Function to create buttons
    private func createButton(image: String, title: String, place: PlaceType) -> some View {
        Button {
            withAnimation {
                addressPlace = place
            }
        } label: {
            VStack(spacing: 4) {
                Image(image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(addressPlace == place ? .white : .black1F1F1F())
                Text(title)
                    .customFont(weight: addressPlace == place ? .bold : .regular, size: 14)
                    .foregroundColor(addressPlace == place ? .white : .black1F1F1F())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 38)
            .frame(maxWidth: .infinity)
            .background((addressPlace == place ? Color.primary() : .white).cornerRadius(8))
        }
    }

    func moveToUserLocation() {
        withAnimation(.easeInOut(duration: 2.0)) {
            LocationManager.shared.getCurrentLocation { location in
                if let location = location {
                    region.center = location
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
        }
    }
}

#Preview {
    AddAddressView()
        .environmentObject(UserSettings())
}

extension AddAddressView {
    private func add() {
        // لا تعرض Popup عامّة إلا بعد إظهار رسائل الحقول
        guard isFormValid else { return }

        var params: [String: Any] = [:]

        params = [
            "lat": region.center.latitude,
            "lng": region.center.longitude,
            "address": address,
            "type": addressPlace.rawValue,
            "streetName": streetName,
            "buildingNo": buildingNo,
            "floorNo": floorNo,
            "flatNo": flatNo,
            "title": title
        ]

        viewModel.addAddress(params: params, onsuccess: { message in
            showMessage(message: message)
        })
    }

    private func showMessage(message: String) {
        // أشعِر قائمة العناوين بالتحديث
        NotificationCenter.default.post(name: Notification.Name("addressBookUpdated"), object: nil)

        // Haptic نجاح
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif

        // Toast نجاح ثم رجوع تلقائي
        successText = message.isEmpty ? "تم إضافة العنوان بنجاح" : message
        showSuccessToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSuccessToast = false
            }
            // الرجوع للشاشة السابقة
            appRouter.navigateBack()
        }
    }
}

// Toast نجاح بسيط
private struct SuccessToast: View {
    let message: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            Text(message)
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.green.opacity(0.92))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }
}
