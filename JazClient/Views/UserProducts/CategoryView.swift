//
//  CategoryView.swift
//  Wishy
//
//  Created by Karim Amsha on 20.06.2024.
//

import SwiftUI

struct CategoryView: View {
    var customModel: CustomModel<MainCategory>

    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .leading) {
                Text(customModel.title)
                    .customFont(weight: .bold, size: 14)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Loop through the rest of the items
                        ForEach(customModel.items, id: \.self) { item in
                            VStack(spacing: 10) {
                                Text(item.title ?? "")
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.black1C1C28())
                                CustomDivider()
                            }
                            .onTapGesture {
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

