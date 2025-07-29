import SwiftUI
import CoreLocation
import MapKit

struct AddOrderView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject var locationManager = LocationManager.shared

    let selectedCategory: Category?
    let selectedSubCategory: SubCategory?
    let cameFromMain: Bool

    // State
    @State private var pickedCategory: Category?
    @State private var pickedSubCategory: SubCategory?
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var extraDetails: String = ""
    @State private var isCurrentLocationSelected: Bool = true
    @State private var selectedAddress: AddressItem? = nil
    @State private var isShowingAllAddresses = false
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var pickedCategoryId: String? = nil
    @State private var pickedSubCategoryId: String? = nil
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    var subCategories: [SubCategory] {
        pickedCategory?.sub ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // --- المعلومات الأساسية ---
                    Text("المعلومات الاساسية")
                        .customFont(weight: .bold, size: 18)
                        .padding(.top, 16)
                        .padding(.leading)

                    VStack(spacing: 20) {

                        // --- Main Category Dropdown ---
                        DropdownField(
                            title: "نوع الخدمة الأساسي",
                            selection: $pickedCategoryId,
                            options: viewModel.homeItems?.category?.compactMap { $0.id } ?? [],
                            displayFor: { id in
                                viewModel.homeItems?.category?.first(where: { $0.id == id })?.title ?? ""
                            }
                        )
                        .onChange(of: pickedCategoryId) { newValue in
                            if let found = viewModel.homeItems?.category?.first(where: { $0.id == newValue }) {
                                pickedCategory = found
                                pickedSubCategoryId = ""
                                pickedSubCategory = nil
                            }
                        }

                        // --- SubCategory Dropdown ---
                        DropdownField(
                            title: "الخدمات",
                            selection: $pickedSubCategoryId,
                            options: pickedCategory?.sub?.compactMap { $0.id } ?? [],
                            displayFor: { id in
                                pickedCategory?.sub?.first(where: { $0.id == id })?.title ?? ""
                            }
                        )
                        .onChange(of: pickedSubCategoryId) { newValue in
                            if let found = pickedCategory?.sub?.first(where: { $0.id == newValue }) {
                                pickedSubCategory = found
                            }
                        }

                        // --- Date & Time Pickers ---
                        HStack(spacing: 12) {
                            // --- التاريخ كـ Dropdown ---
                            VStack(alignment: .leading, spacing: 6) {
                                Text("التاريخ")
                                    .customFont(weight: .regular, size: 14)

                                Button {
                                    showDatePicker.toggle()
                                } label: {
                                    HStack {
                                        Text(date.formatted(.dateTime.year().month().day())
                                                .replacingOccurrences(of: "-", with: " / "))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 48)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                                }
                                .sheet(isPresented: $showDatePicker) {
                                    VStack {
                                        DatePicker("اختر التاريخ", selection: $date, displayedComponents: .date)
                                            .datePickerStyle(.wheel)
                                            .labelsHidden()
                                            .environment(\.locale, Locale(identifier: "ar"))
                                            .padding()
                                        Button("تم") {
                                            showDatePicker = false
                                        }
                                        .padding()
                                    }
                                    .presentationDetents([.fraction(0.35)])
                                }
                            }

                            // --- الوقت كـ Dropdown ---
                            VStack(alignment: .leading, spacing: 6) {
                                Text("الوقت")
                                    .customFont(weight: .regular, size: 14)

                                Button {
                                    showTimePicker.toggle()
                                } label: {
                                    HStack {
                                        Text(time.formatted(date: .omitted, time: .shortened))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 48)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                                }
                                .sheet(isPresented: $showTimePicker) {
                                    VStack {
                                        DatePicker("اختر الوقت", selection: $time, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.wheel)
                                            .labelsHidden()
                                            .environment(\.locale, Locale(identifier: "ar"))
                                            .padding()
                                        Button("تم") {
                                            showTimePicker = false
                                        }
                                        .padding()
                                    }
                                    .presentationDetents([.fraction(0.35)])
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // --- العنوان ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("العنوان")
                            .customFont(weight: .bold, size: 14)
                        // ✅ موقعي الحالي
                        Button(action: {
                            selectedAddress = nil
                            isCurrentLocationSelected = true
                        }) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: isCurrentLocationSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.primary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("موقعي الحالي")
                                        .customFont(weight: .medium, size: 18)
                                        .foregroundColor(.primary())
                                    Text(locationManager.address.isEmpty ? "جارٍ تحديد الموقع..." : locationManager.address)
                                        .customFont(weight: .medium, size: 18)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                        Divider()
                        // ✅ أول 3 عناوين
                        let addressList = userViewModel.addressBook ?? []
                        if addressList.isEmpty {
                            Text("لا يوجد عناوين محفوظة")
                                .customFont(weight: .medium, size: 18)
                                .font(.footnote)
                        }
                        ForEach(addressList.prefix(3), id: \.id) { address in
                            AddressItemView(address: address, isSelected: selectedAddress?.id == address.id)
                                .onTapGesture {
                                    withAnimation {
                                        selectedAddress = address
                                        isCurrentLocationSelected = false
                                    }
                                }
                        }
                        // ✅ زر عرض كل العناوين
                        if addressList.count > 3 {
                            Button("عرض كل العناوين") {
                                isShowingAllAddresses = true
                            }
                            .customFont(weight: .medium, size: 18)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // ✅ MiniMap
                    if isCurrentLocationSelected, let loc = locationManager.userLocation {
                        MiniMapView(coordinate: loc)
                            .frame(height: 120)
                            .padding(.horizontal)
                    } else if let address = selectedAddress,
                              let lat = address.lat,
                              let lng = address.lng {
                        MiniMapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                            .frame(height: 120)
                            .padding(.horizontal)
                    }

                    // --- Extra Details ---
                    Text("تفاصيل إضافية")
                        .customFont(weight: .bold, size: 18)
                        .padding(.leading)
                    TextEditor(text: $extraDetails)
                        .frame(height: 100)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .padding(.horizontal)
                }
            }

            // --- زر تقديم الطلب ---
            Button(action: submitOrder) {
                Text("تقديم طلب الخدمة!")
                    .customFont(weight: .bold, size: 18)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color(hex: "#FFA300"))
                    .cornerRadius(14)
            }
            .padding()
        }
        .environment(\.layoutDirection, .rightToLeft)
        .background(Color.background())
        .dismissKeyboardOnTap()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isShowingAllAddresses) {
            FullAddressListView(
                selectedAddress: $selectedAddress,
                isCurrentLocationSelected: $isCurrentLocationSelected
            )
            .environmentObject(userViewModel)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    if !cameFromMain {
                        Button(action: {
                            appRouter.navigateBack()
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    Text("اضافة طلب جديد")
                        .customFont(weight: .medium, size: 20)
                        .padding(.leading, !cameFromMain ? 6 : 0)
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: .constant(validationMessage),
                alertType: .constant(.error)
            )
        )
        .onAppear {
            // تهيئة القيم الأولية عند الدخول للشاشة
            if let selectedCategory = selectedCategory {
                pickedCategory = selectedCategory
                pickedCategoryId = selectedCategory.id
            }
            if let selectedSubCategory = selectedSubCategory {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    pickedSubCategory = selectedSubCategory
                    pickedSubCategoryId = selectedSubCategory.id
                }
            }

            if userViewModel.addressBook == nil {
                userViewModel.getAddressList()
            }
            LocationManager.shared.getCurrentLocation { coordinate in
                guard let coordinate = coordinate else { return }
                if (viewModel.homeItems?.category ?? []).isEmpty {
                    viewModel.fetchHomeItems(q: nil, lat: coordinate.latitude, lng: coordinate.longitude)
                }
            }

            locationManager.requestLocationIfNeeded()
        }
    }

    func submitOrder() {
        guard let mainCat = pickedCategory else {
            validationMessage = "يرجى اختيار نوع الخدمة الرئيسي"
            showValidationError = true
            return
        }
        guard let subCat = pickedSubCategory else {
            validationMessage = "يرجى اختيار نوع الخدمة الفرعية"
            showValidationError = true
            return
        }

        var lat: Double?
        var lng: Double?

        if isCurrentLocationSelected, let loc = locationManager.userLocation {
            lat = loc.latitude
            lng = loc.longitude
        } else if let address = selectedAddress {
            lat = address.lat
            lng = address.lng
        }

        guard let finalLat = lat, let finalLng = lng else {
            validationMessage = "يرجى تحديد الموقع"
            showValidationError = true
            return
        }

        let selectedService = SelectedServiceItem(
            service: subCat,
            quantity: 1,
            categoryId: mainCat.id,
            subCategoryId: subCat.id,
            categoryTitle: mainCat.title ?? "",
            subCategoryTitle: subCat.title ?? ""
        )
        let currentAddress = AddressItem(streetName: "", floorNo: "", buildingNo: "", flatNo: "", type: "", createAt: "", id: "", title: "", lat: locationManager.userLocation?.latitude ?? 0.0, lng: locationManager.userLocation?.longitude ?? 0.0, address: locationManager.address, userId: "", discount: 0)
            let orderData = OrderData(
                services: [selectedService],
                address: isCurrentLocationSelected ? nil : selectedAddress,
                userLocation: isCurrentLocationSelected ? Location(lat: locationManager.userLocation?.latitude ?? 0.0, lng: locationManager.userLocation?.longitude ?? 0.0, address: locationManager.address) : nil,
                notes: extraDetails.isEmpty ? nil : extraDetails,
                date: date.toDateString(),
                time: time.toTimeString()
            )

        appRouter.navigate(to: .checkout(orderData: orderData))
    }
}

// --- Helpers لتنسيق التاريخ والوقت
extension Date {
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

#Preview {
    AddOrderView(
        viewModel: InitialViewModel(errorHandling: ErrorHandling()),
        locationManager: LocationManager.shared,
        selectedCategory: nil,
        selectedSubCategory: nil,
        cameFromMain: true
    )
}

struct MiniMapView: View {
    let coordinate: CLLocationCoordinate2D

    // مركز الخريطة
    @State private var region: MKCoordinateRegion

    // Initializer لتهيئة المنطقة تلقائيًا
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        // نقطة المركز والتقريب
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapPin(coordinate: coordinate)]) { pin in
            MapMarker(coordinate: pin.coordinate, tint: .orange)
        }
        .cornerRadius(12)
        .disabled(true) // يمنع التكبير/التصغير إذا أردت أن تكون الخريطة فقط للعرض
    }
}

// هيكل بسيط لتعريف الـ annotation
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct AddressItemView: View {
    let address: AddressItem
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .orange : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text((address.title?.isEmpty ?? false) ? "عنوان بدون اسم" : address.title ?? "")
                    .customFont(weight: .medium, size: 16)
                Text(address.address)
                    .customFont(weight: .regular, size: 13)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.orange.opacity(0.07) : Color(.systemGray6))
        )
    }
}

struct FullAddressListView: View {
    @Binding var selectedAddress: AddressItem?
    @Binding var isCurrentLocationSelected: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    selectedAddress = nil
                    isCurrentLocationSelected = true
                    dismiss()
                }) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: isCurrentLocationSelected ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.primary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("موقعي الحالي")
                                .customFont(weight: .medium, size: 15)
                            Text("استخدم الموقع الجغرافي الحالي")
                                .customFont(weight: .regular, size: 13)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                Divider().padding(.vertical, 2)

                ScrollView {
                    VStack(spacing: 8) {
                        let addressList = userViewModel.addressBook ?? []
                        if addressList.isEmpty {
                            Text("لا يوجد عناوين محفوظة")
                                .foregroundColor(.gray)
                                .customFont(weight: .regular, size: 13)
                                .padding()
                        }
                        ForEach(addressList, id: \.id) { address in
                            AddressItemView(address: address, isSelected: selectedAddress?.id == address.id)
                                .onTapGesture {
                                    selectedAddress = address
                                    isCurrentLocationSelected = false
                                    dismiss()
                                }
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("كل العناوين")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }
                }
            }
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}

import SwiftUI

struct DropdownField<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [T]
    let displayFor: (T) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .customFont(weight: .medium, size: 14)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        Text(displayFor(option))
                            .customFont(weight: .regular, size: 12)
                    }
                }
            } label: {
                HStack {
                    Text(displayFor(selection).isEmpty ? "اضغط للاختيار" : displayFor(selection))
                        .foregroundColor(displayFor(selection).isEmpty ? .gray : .primary)
                        .customFont(weight: .regular, size: 12)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
}

