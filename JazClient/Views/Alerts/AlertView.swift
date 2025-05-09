//
//  AlertView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

struct AlertView: View {
    var alertModel: AlertModel

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack {
                if !alertModel.hidesIcon {
                    Image(alertModel.icon)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding(16)
                }
                
                VStack(alignment: .center, spacing: 8) {
                    Text(alertModel.title)
                        .customFont(weight: .semiBold, size: 16)
                    
                    if alertModel.hasItem {
                        Text(alertModel.item ?? "")
                            .customFont(weight: .regular, size: 12)
                    }
                    
                    Text(alertModel.message)
                        .customFont(weight: .regular, size: 14)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.black222020())
            }
            
            VStack(spacing: 10) {
                Button {
                    withAnimation {
                        alertModel.onOKAction?()
                    }
                } label: {
                    Text(alertModel.okTitle)
                }
                .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .bold, background: .dangerNormal(), foreground: .white, height: 48, radius: 8))
                
                if !alertModel.hidesCancel {
                    Button {
                        alertModel.onCancelAction?()
                    } label: {
                        Text(alertModel.cancelTitle)
                    }
                    .buttonStyle(PrimaryButton(fontSize: 16, fontWeight: .regular, background: .dangerLight(), foreground: .dangerDarker(), height: 48, radius: 8))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
}
