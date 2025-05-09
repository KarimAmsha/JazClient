//
//  ConstantView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI

struct ConstantView: View {
    @Binding var item: ConstantItem?
    @State private var contentHeight: CGFloat = 0
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        Image("ic_logo2")
                                                
                        HTMLView(html: item?.Content ?? "", contentHeight: $contentHeight)
                            .frame(height: contentHeight)

                        Spacer()
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .navigationBarBackButtonHidden()
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
                    
                    Text(item?.Title ?? "")
                        .customFont(weight: .bold, size: 18)
                        .foregroundColor(Color.black141F1F())
                }
            }
        }
    }
}

#Preview {
    ConstantView(item: .constant(ConstantItem(_id: nil, Type: nil, Title: nil, Content: nil)))
}
