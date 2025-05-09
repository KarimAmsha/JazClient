//
//  LoadingView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView(LocalizedStringKey.loading)
            .progressViewStyle(CircularProgressViewStyle(tint: .primary()))
            .background(Color.clear)
            .padding()
    }
}

struct LinearProgressView: View {
    var label: String
    var progress: Double
    var color: Color
    
    init(_ label: String, progress: Double, color: Color) {
        self.label = label
        self.progress = progress
        self.color = color
    }
    
    var body: some View {
        ProgressView(label, value: progress)
            .progressViewStyle(LinearProgressViewStyle(tint: color))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}
