//
//  DefaultEmptyView.swift
//  Fazaa
//
//  Created by Karim Amsha on 13.02.2024.
//

import SwiftUI

struct DefaultEmptyView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            
            Image("ic_logo")
                .renderingMode(.template)
                .resizable()
                .frame(width: 85, height: 81)
                .foregroundColor(.gray)
            
            Text(title)
                .customFont(weight: .bold, size: 14)
                .foregroundColor(.gray)

            Spacer()
        }
    }
}

#Preview {
    DefaultEmptyView(title: LocalizedStringKey.noOrdersFound)
}
