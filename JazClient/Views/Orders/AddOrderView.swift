//
//  AddOrderView.swift
//  JazClient
//
//  Created by Karim OTHMAN on 11.06.2025.
//

import SwiftUI
import CoreLocation

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @ObservedObject var viewModel: InitialViewModel
    @ObservedObject var userViewModel: UserViewModel
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

    // عنوان
    @State private var isCurrentLocationSelected: Bool = true
    @State private var selectedAddress: AddressItem? = nil
    @State private var isShowingAllAddresses = false

    var subCategories: [SubCategory] {
        pickedCategory?.sub ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            // --- Toolbar ---
            HStack {
                if !cameFromMain {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                Text("اضافة طلب جديد")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.trailing, 10)
                Spacer()
                if !cameFromMain { Spacer().frame(width: 30) }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#FFA300").opacity(0.97))

            ScrollView {
                VStack(alignment: .trailing, spacing: 18) {
                    // --- المعلومات الأساسية ---
                    Text("المعلومات الاساسية")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 16)
                        .padding(.trailing)

                    // --- Main Category Dropdown ---
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("نوع الخدمة الاساسي")
                            .font(.system(size: 14, weight: .medium))
                        Picker(selection: $pickedCategory) {
                            Text("اضغط لاختيار نوع الخدمة").tag(Category?.none)
                            ForEach(viewModel.homeItems?.category ?? [], id: \.id) { category in
                                Text(category.title).tag(Category?.some(category))
                            }
                        } label: { Text("") }
                        .pickerStyle(.menu)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .onChange(of: pickedCategory) { _ in
                            pickedSubCategory = nil
                        }
                    }
                    .padding(.horizontal)
                    .disabled((viewModel.homeItems?.category ?? []).isEmpty)

                    // --- SubCategory Dropdown ---
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("الخدمات")
                            .font(.system(size: 14, weight: .medium))
                        Picker(selection: $pickedSubCategory) {
                            Text("اضغط لاختيار نوع الخدمة").tag(SubCategory?.none)
                            ForEach(subCategories, id: \.id) { sub in
                                Text(sub.title).tag(SubCategory?.some(sub))
                            }
                        } label: { Text("") }
                        .pickerStyle(.menu)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                    }
                    .padding(.horizontal)
                    .disabled(subCategories.isEmpty)

                    // --- Date & Time ---
                    HStack {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("التاريخ")
                                .font(.system(size: 14))
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ar"))
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        }
                        VStack(alignment: .trailing, spacing: 2) {
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
                    VStack(alignment: .trailing, spacing: 8) {
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
                    if isCurrentLocationSelected, let loc = locationManager.location?.coordinate {
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
                        .padding(.trailing)
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
        .onAppear {
            pickedCategory = selectedCategory
            pickedSubCategory = selectedSubCategory
            // جلب بيانات العناوين إذا لم تكن موجودة (حسب مشروعك)
            if userViewModel.addressBook == nil {
                userViewModel.fetchAddresses()
            }
            // جلب الكاتجوري إذا لم تكن موجودة
            if (viewModel.homeItems?.category ?? []).isEmpty {
                viewModel.fetchHomeItems(q: nil, lat: 18.2418308, lng: 42.4660169)
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .sheet(isPresented: $isShowingAllAddresses) {
            // شاشة كل العناوين (نفذها حسب مشروعك)
            AddressBookView(selectedAddress: $selectedAddress, isCurrentLocationSelected: $isCurrentLocationSelected)
                .environmentObject(userViewModel)
        }
    }

    func submitOrder() {
        // ربط مع API هنا
    }
}

#Preview {
    AddOrderView(
        selectedCategory: nil,
        selectedSubCategory: nil,
        viewModel: InitialViewModel(errorHandling: ErrorHandling())
    )
}

