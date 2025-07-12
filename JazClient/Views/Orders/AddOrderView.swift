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

    var subCategories: [SubCategory] {
        pickedCategory?.sub ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // --- المعلومات الأساسية ---
                    Text("المعلومات الاساسية")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 16)
                        .padding(.leading)

                    // --- Main Category Dropdown ---
                    VStack(alignment: .leading, spacing: 4) {
                        Text("نوع الخدمة الاساسي")
                            .font(.system(size: 14, weight: .medium))
                        Picker(selection: $pickedCategoryId) {
                            Text("اضغط لاختيار نوع الخدمة").tag(String?.none)
                            ForEach(viewModel.homeItems?.category ?? [], id: \.id) { category in
                                Text(category.title ?? "").tag(String?.some(category.id))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.menu)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .onChange(of: pickedCategoryId) { newValue in
                            if let id = newValue,
                               let found = viewModel.homeItems?.category?.first(where: { $0.id == id }) {
                                pickedCategory = found
                                // عند تغيير الخدمة الأساسية، صفّر الفرعية
                                pickedSubCategoryId = nil
                                pickedSubCategory = nil
                            }
                        }
                        // رسالة إذا فاضي
                        if (viewModel.homeItems?.category ?? []).isEmpty {
                            Text("لا توجد خدمات رئيسية متاحة حاليًا")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal)

                    // --- SubCategory Dropdown ---
                    VStack(alignment: .leading, spacing: 4) {
                        Text("الخدمات")
                            .font(.system(size: 14, weight: .medium))
                        Picker(selection: $pickedSubCategoryId) {
                            Text("اضغط لاختيار نوع الخدمة").tag(String?.none)
                            ForEach(subCategories, id: \.id) { sub in
                                Text(sub.title ?? "").tag(String?.some(sub.id))
                            }
                        } label: { EmptyView() }
                        .pickerStyle(.menu)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .onChange(of: pickedSubCategoryId) { newValue in
                            if let id = newValue,
                               let found = subCategories.first(where: { $0.id == id }) {
                                pickedSubCategory = found
                            }
                        }
                        // رسالة إذا فاضي
                        if pickedCategory != nil && subCategories.isEmpty {
                            Text("لا توجد خدمات فرعية متاحة لهذا التصنيف")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.horizontal)

                    // --- Date & Time ---
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("التاريخ")
                                .font(.system(size: 14))
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ar"))
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("الوقت")
                                .font(.system(size: 14))
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ar"))
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }
                    }
                    .padding(.horizontal)

                    // --- العنوان ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("العنوان")
                            .font(.system(size: 14, weight: .medium))
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
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary())
                                    Text(locationManager.address.isEmpty ? "جارٍ تحديد الموقع..." : locationManager.address)
                                        .font(.footnote)
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
                                .foregroundColor(.gray)
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
                            .font(.footnote)
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
                        .font(.system(size: 18, weight: .bold))
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
                    .font(.system(size: 18, weight: .bold))
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
                        .font(.system(size: 20, weight: .bold))
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
            if (viewModel.homeItems?.category ?? []).isEmpty {
                viewModel.fetchHomeItems(q: nil, lat: 18.2418308, lng: 42.4660169)
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

        let orderData = OrderData(
            services: [selectedService],
            address: nil,
            userLocation: Location(
                lat: Constants.defaultLat,
                lng: Constants.defaultLng
            ),
            notes: extraDetails.isEmpty ? nil : extraDetails,
            date: date.toDateString(),
            time: time.toTimeString()
        )

//        let orderData = OrderData(
//            services: [selectedService],
//            address: isCurrentLocationSelected ? nil : selectedAddress,
//            userLocation: isCurrentLocationSelected ? Location(lat: finalLat, lng: finalLng) : nil,
//            notes: extraDetails.isEmpty ? nil : extraDetails,
//            date: date.toDateString(),
//            time: time.toTimeString()
//        )

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
            // دائرة التحديد
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .orange : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text((address.title?.isEmpty ?? false) ? "عنوان بدون اسم" : address.title ?? "")
                    .font(.system(size: 16, weight: .medium))
                Text(address.address)
                    .font(.footnote)
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
                // ✅ زر اختيار "موقعي الحالي"
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
                                .fontWeight(.medium)
                            Text("استخدم الموقع الجغرافي الحالي")
                                .font(.footnote)
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

                // ✅ قائمة جميع العناوين
                ScrollView {
                    VStack(spacing: 8) {
                        let addressList = userViewModel.addressBook ?? []
                        if addressList.isEmpty {
                            Text("لا يوجد عناوين محفوظة")
                                .foregroundColor(.gray)
                                .font(.footnote)
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
