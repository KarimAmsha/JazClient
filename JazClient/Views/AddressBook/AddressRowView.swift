//
//  AddressRowView.swift
//  Fazaa
//
//  Created by Karim Amsha on 29.02.2024.
//

import SwiftUI

struct AddressRowView: View {
    
    let item: AddressItem

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(item.addressType?.value ?? "")
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 14)
                    .background(Color.primary1())
                    .clipShape(Capsule())
                Spacer()
                Text(item.title ?? "")
                    .customFont(weight: .bold, size: 14)
                    .foregroundColor(.black1C1C28())
            }
                        
            HStack {
                Spacer()
                Text(item.address ?? "")
                    .customFont(weight: .regular, size: 12)
                    .foregroundColor(.black0B0B0B())
                Image("ic_location")
            }

            CustomDivider()
        }
        .padding(8)
    }
}

#Preview {
    AddressRowView(item: AddressItem(streetName: "", floorNo: "", buildingNo: "", flatNo: "", type: "", createAt: "", id: "", title: "", lat: 0.0, lng: 0.0, address: "", userId: "", discount: 0))
}
