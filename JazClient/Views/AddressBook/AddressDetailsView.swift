//
//  AddressDetailsView.swift
//  Fazaa
//
//  Created by Karim Amsha on 29.02.2024.
//

import SwiftUI
import MapKit

struct AddressDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter
    let addressItem: AddressItem
    @StateObject var viewModel = UserViewModel(errorHandling: ErrorHandling())

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image("ic_location")
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey.geographicalLocation)
                                .customFont(weight: .bold, size: 14)
                                .foregroundColor(.black1F1F1F())
                            Text(addressItem.address ?? "")
                                .customFont(weight: .regular, size: 12)
                                .foregroundColor(.black0B0B0B())
                        }
                        Spacer()
                    }

                    // Display Map using SwiftUI's Map
                    Map(coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: addressItem.lat ?? 0.0, longitude: addressItem.lng ?? 0.0),
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        )
                    ), showsUserLocation: true,  annotationItems: [addressItem]) { location in
                        MapPin(coordinate: CLLocationCoordinate2D(latitude: location.lat ?? 0.0, longitude: location.lng ?? 0.0))
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                    .allowsHitTesting(false)

                    // Display Address Details
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.streetName)
                            .customFont(weight: .bold, size: 12)
                            .foregroundColor(.black1F1F1F())
                        Text(addressItem.streetName ?? "")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black0B0B0B())
                    }

                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey.buildingNo)
                                    .customFont(weight: .bold, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                Text(addressItem.buildingNo ?? "")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey.floorNo)
                                    .customFont(weight: .bold, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                Text(addressItem.floorNo ?? "")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                            }
                            Spacer()
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Text(LocalizedStringKey.flatNo)
                                    .customFont(weight: .bold, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                Text("#\(addressItem.flatNo ?? "")")
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                            }
                            Spacer()
                        }
                    }
                }
                .padding(8)
                .background(Color.white.cornerRadius(8))

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity)
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
                    
                    Text(LocalizedStringKey.addressDetails)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.black141F1F())
                }
            }
            
            // Add Edit Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    appRouter.navigate(to: .editAddressBook(addressItem))
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white.cornerRadius(8))
                }
            }

            // Add Delete Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAlertMessage()
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.white.cornerRadius(8))
                }
            }
        }
    }
}
#Preview {
    AddressDetailsView(addressItem: AddressItem(streetName: nil, floorNo: nil, buildingNo: nil, flatNo: nil, type: nil, createAt: nil, id: nil, title: nil, lat: nil, lng: nil, address: nil, userId: nil, discount: nil))
}

extension AddressDetailsView {
    private func deleteAddress() {
        viewModel.deleteAddress(id: addressItem.id ?? "") { message in
            showSuccessMessage(message: message)
        }
    }
    
    private func showAlertMessage() {
        let alertModel = AlertModel(
            icon: "",
            title: LocalizedStringKey.deleteMessage,
            message: "",
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: false,
            onOKAction: {
                appRouter.togglePopup(nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    deleteAddress()
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
