//
//  ProgressLineView.swift
//  Wishy
//
//  Created by Karim Amsha on 1.05.2024.
//

import SwiftUI

struct ProgressLineView: View {
    var percentage: Double // Percentage of votes
    var barHeight: CGFloat = 10 // Height of the progress bar
    var barColor: Color = Color.primary() // Color of the progress bar

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: barHeight)
                    .opacity(0.3) // Background bar color
                    .foregroundColor(.grayE8EBF3())
                
                Rectangle()
                    .frame(width: min(CGFloat(percentage) / 100 * geometry.size.width, geometry.size.width), height: barHeight)
                    .foregroundColor(barColor) // Progress bar color
                    .animation(.linear(duration: 1.0)) // Smooth animation when changing the percentage
            }
        }
        .cornerRadius(barHeight / 2) // Rounded corners
    }
}
