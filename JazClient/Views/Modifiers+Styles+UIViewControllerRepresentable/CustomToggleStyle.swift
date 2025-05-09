//
//  CustomToggleStyle.swift
//  Jaz Client
//
//  Created by Karim Amsha on 25.11.2023.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .primaryLight())) 
        }
    }
}
