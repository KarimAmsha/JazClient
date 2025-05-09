//
//  CustomDivider.swift
//  Khawi
//
//  Created by Karim Amsha on 25.10.2023.
//

import SwiftUI

struct CustomDivider: View {
    var color = Color.grayF2F2F2()
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(height: 2)
            .background(color)
    }
}
