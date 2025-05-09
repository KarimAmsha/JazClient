//
//  ServiceDetailsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct ServiceDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    AsyncImageView(
                        width: .infinity, 
                        height: 120,
                        cornerRadius: 8,
                        imageURL: URL(string: "https://picsum.photos/300/200"),
                        placeholder: Image(systemName: "photo"),
                        contentMode: .fill
                    )
                    .padding()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("تصميم بوستات سوشيال ميديا")
                            .font(.title3)
                            .bold()

                        HStack {
                            Text("$15")
                                .font(.headline)
                                .foregroundColor(Color.primary())
                            Spacer()
                            Label("4.8", systemImage: "star.fill")
                                .foregroundColor(.orange)
                        }

                        Divider()

                        Text("تفاصيل الخدمة")
                            .font(.title3).bold()
                            .font(.headline)

                        Text("تصميم بوستات لمنصات السوشيال لليبيا و مواقع الويب")
                            .font(.headline)

                        Text("إن كنت تبحث عن خبير للتصميم محتوى بصري مميز واحترافي.")
                            .font(.callout)

                        Text("فإن كنت مهم بتعزيز تواجد شركتك أو مؤسستك وتوظيف محتوى بصري مميز يعرفك بنفسه ويوصل رسالتك في عقل جمهورك.")
                            .font(.callout)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("تفاصيل الخدمة المقدمة")
                                .font(.headline)
                            Text("مدة التسليم، وسعر التصميم مرفقان.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        Divider()
                        
                        HStack(spacing: 12) {
                            Button("اطلب الخدمة الآن") {
                                // Navigate to order
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary())
                            .foregroundColor(.white)
                            .cornerRadius(10)

                            Text("$10")
                                .font(.title3.bold())
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text("تفاصيل الخدمة")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
    }
}

#Preview {
    ServiceDetailsView()
        .environmentObject(AppState())
}

