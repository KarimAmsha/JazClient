//
//  EventListView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct EventListView: View {
    var customModel: CustomModel<Event>

    var body: some View {
        VStack(alignment: .leading) {
            Text(customModel.title)
                .customFont(weight: .bold, size: 14)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(customModel.items, id: \.self) { item in
                        VStack(spacing: 10) {
                            Text(item.localizedName ?? "")
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
        .frame(height: 300)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}

#Preview {
    EventListView(customModel: CustomModel(title: "", content: "", items: [], onSelect: {_ in }))
}
