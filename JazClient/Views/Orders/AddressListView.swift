//
//  AddressListView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI

struct AddressListView: View {
    var customModel: CustomModel<AddressItem>
    @Binding var currentUserLocation: AddressItem?
    @Binding var isAddressBook: Bool

    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .leading) {
                Text(customModel.title)
                    .customFont(weight: .bold, size: 14)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Display current user location as the first item
                        if let currentUserLocation = currentUserLocation {
                            VStack(spacing: 10) {
                                Text(currentUserLocation.title ?? "")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black1C1C28())
                                CustomDivider()
                            }
                            .onTapGesture {
                                isAddressBook = false
                                customModel.onSelect(currentUserLocation)
                            }
                        }
                        
                        // Loop through the rest of the items
                        ForEach(customModel.items) { item in
                            VStack(spacing: 10) {
                                Text(item.title ?? "")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black1C1C28())
                                CustomDivider()
                            }
                            .onTapGesture {
                                isAddressBook = true
                                customModel.onSelect(item)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(height: 300)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

