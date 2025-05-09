//
//  EditAddressView.swift
//  Fazaa
//
//  Created by Karim Amsha on 29.02.2024.
//

import SwiftUI
import MapKit

struct EditAddressView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var title = ""
    @State private var streetName = ""
    @State private var buildingNo = ""
    @State private var floorNo = ""
    @State private var flatNo = ""
    @State private var address = ""
    private let errorHandling = ErrorHandling()
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
    let addressItem: AddressItem
    @State private var isShowingMap = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(LocalizedStringKey.addressDetails)
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.black1F1F1F())

                        HStack {
                            createButton(image: "ic_house", title: LocalizedStringKey.house, place: .home)
                            createButton(image: "ic_work", title: LocalizedStringKey.work, place: .work)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.name)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            CustomTextField(text: $title, placeholder: LocalizedStringKey.homeAddress, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .disabled(viewModel.isLoading)
                        }

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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey.streetName)
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black1F1F1F())
                            CustomTextField(text: $streetName, placeholder: LocalizedStringKey.streetName, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .disabled(viewModel.isLoading)
                        }
                        
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.buildingNo)
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                CustomTextField(text: $buildingNo, placeholder: LocalizedStringKey.buildingNo, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                    .disabled(viewModel.isLoading)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.floorNo)
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                CustomTextField(text: $floorNo, placeholder: LocalizedStringKey.floorNo, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                    .disabled(viewModel.isLoading)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.flatNo)
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                CustomTextField(text: $flatNo, placeholder: LocalizedStringKey.flatNo, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
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
                            update()
                        }
                    } label: {
                        Text(LocalizedStringKey.send)
                    }
                    .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .primary(), foreground: .white, height: 48, radius: 8))
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
                    
                    Text(LocalizedStringKey.editAddress)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.black141F1F())
                }
            }
        }
        .onAppear {
            LocationManager.shared.getCurrentLocation { location in
                if let location = location {
                    self.userLocation = userLocation
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
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
            .background((addressPlace == place ? Color.blue057E98() : .white).cornerRadius(8))
        }
    }
}

#Preview {
    EditAddressView(addressItem: AddressItem(streetName: nil, floorNo: nil, buildingNo: nil, flatNo: nil, type: nil, createAt: nil, id: nil, title: nil, lat: nil, lng: nil, address: nil, userId: nil, discount: nil))
}

extension EditAddressView {
    private func update() {
        guard !title.isEmpty else {
            appRouter.toggleAppPopup(.alertError("", LocalizedStringKey.addressTitleRequired))
            return
        }

        var params: [String: Any] = [:]
        params = [
            "id": addressItem.id ?? "",
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
        
        viewModel.updateAddress(params: params, onsuccess: { message in
            showMessage(message: message)
        })
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
