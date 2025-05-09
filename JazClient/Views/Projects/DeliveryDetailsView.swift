//
//  DeliveryDetailsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct DeliveryDetailsView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    GeneralCardView(
                        title: "تصميم بروشور شركة",
                        rating: 4.8,
                        reviewer: "محمد سعيد",
                        completedProjects: 100,
                        price: "$160",
                        date: "٢٧ أكتوبر 2024",
                        status: "قيد التنفيذ"
                    )
                    .padding()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("التسليمات")
                            .font(.headline)

                        ForEach(0..<2) { _ in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("التسليم النهائي.zip")
                                        .bold()
                                    Text("12 نوفمبر 2024")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button("تحميل الملف") {}
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    Spacer()
                }
            }
            .background(Color.background())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Button(action: {
                            appRouter.navigateBack()
                        }) {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.black)
                        }

                        VStack(alignment: .leading) {
                            Text("تصميم بروشور شركة")
                                .customFont(weight: .bold, size: 20)
                            Text("تحكم بجميع مشاريعك عبر المنصة!")
                                .customFont(weight: .regular, size: 10)
                        }
                        .foregroundColor(Color.black222020())
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
}

struct GeneralCardView: View {
    let title: String
    let rating: Double
    let reviewer: String
    let completedProjects: Int
    let price: String
    let date: String
    let status: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .customFont(weight: .bold, size: 18)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center) {
                HStack {
                    AsyncImageView(
                        width: 38,
                        height: 38,
                        cornerRadius: 19,
                        imageURL: UserSettings.shared.user?.image?.toURL(),
                        placeholder: Image(systemName: "person.fill"),
                        contentMode: .fill
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(reviewer)
                            .bold()
                            .foregroundColor(.white)
                        Text("\(completedProjects) مشروع مكتمل")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .foregroundColor(.white)
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.1))
            .cornerRadius(20)

            HStack(spacing: 12) {
                InfoBadge(text: price, systemIcon: "dollarsign.circle")
                InfoBadge(text: date, systemIcon: "calendar")
                InfoBadge(text: status, systemIcon: "doc.text")
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primary().opacity(0.8), Color.primary()]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
    }
}

struct InfoBadge: View {
    let text: String
    let systemIcon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemIcon)
            Text(text)
        }
        .font(.footnote)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}

#Preview {
    DeliveryDetailsView()
        .environmentObject(AppRouter())
}
