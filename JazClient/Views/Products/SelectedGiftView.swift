//
//  SelectedGiftView.swift
//  Wishy
//
//  Created by Karim Amsha on 1.05.2024.
//

import SwiftUI

struct SelectedGiftView: View {
    @State private var quantity: Int = 1
    @EnvironmentObject var appRouter: AppRouter
    @State private var name = ""
    @State var presentSheet = false
    @State var mobile: String = ""

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        AsyncImageView(
                            width: 60,
                            height: 60,
                            cornerRadius: 5,
                            imageURL: "https://media.zid.store/cdn-cgi/image/f=auto/https://media.zid.store/ca6f01a7-f802-4c28-b793-b6c642a7f178/42610e71-37fa-471e-aa72-b5e11fb658a7.jpg".toURL(),
                            placeholder: Image(systemName: "photo"),
                            contentMode: .fill
                        )

                        VStack(alignment: .leading) {
                            Text("سلة ورد")
                                .customFont(weight: .semiBold, size: 14)
                                .foregroundColor(.primaryBlack())
                            
                            Text("299,43 ر.س")
                                .customFont(weight: .semiBold, size: 12)
                                .foregroundColor(.primary())
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                quantity += 1
                                updateSelectedServiceQuantity()
                            }) {
                                Image(systemName: "plus")
                            }
                            
                            Text("\(quantity)")
                                .padding(.horizontal, 8)
                            
                            Button(action: {
                                quantity -= 1
                                updateSelectedServiceQuantity()
                            }) {
                                Image(systemName: "minus")
                            }
                        }
                        .padding(4)
                        .customFont(weight: .semiBold, size: 12)
                        .foregroundColor(Color.primary())
                        .background(Color.primaryLight().cornerRadius(4))
                    }
                    .padding(.vertical, 8)
                    
                    CustomDivider()
                    
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.nameOfPerson)
                            .customFont(weight: .medium, size: 12)

                        TextField(LocalizedStringKey.nameOfPerson, text: $name)
                            .placeholder(when: name.isEmpty) {
                                Text(LocalizedStringKey.nameOfPerson)
                                    .foregroundColor(.gray999999())
                            }
                            .customFont(weight: .regular, size: 14)
                            .accentColor(.primary())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .roundedBackground(cornerRadius: 12, strokeColor: .primaryBlack(), lineWidth: 1)
                    }
                    .foregroundColor(.black222020())
                    
                    MobileView(mobile: $mobile, presentSheet: $presentSheet, strokeColor: .primaryBlack())

                }
            }
            
            Spacer()
            
            VStack {
                CustomDivider()
                
                Button {
                    appRouter.navigate(to: .paymentSuccess)
                } label: {
                    HStack(spacing: 4) {
                        Image("ic_w_gift")
                        Text(LocalizedStringKey.payNow)
                    }
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            }
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text("اهدي المنتج لشخص ما!")
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
    }
    
    func updateSelectedServiceQuantity() {
        // Update selected service quantity
    }
}

#Preview {
    SelectedGiftView()
}
