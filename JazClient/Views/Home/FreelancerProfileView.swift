//
//  FreelancerProfileView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct FreelancerProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var selectedTab: FreelancerTab = .services

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Header Profile Info
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("احمد العزايزة")
                                .font(.headline)
                            Text("UXUI Designer")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("انضم بتاريخ: 20 أكتوبر 2024")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        AsyncImageView(
                            width: 50,
                            height: 50,
                            cornerRadius: 25,
                            imageURL: URL(string: "https://randomuser.me/api/portraits/men/32.jpg"),
                            placeholder: Image(systemName: "person.crop.circle.fill"),
                            contentMode: .fill
                        )
                    }
                    .padding(.horizontal)

                    // MARK: - Profile Completion
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("اكمال الملف الشخصي")
                                .font(.caption)
                            Spacer()
                            Text("95%")
                                .font(.caption)
                        }

                        ProgressView(value: 0.95)
                            .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    }
                    .padding(.horizontal)

                    // MARK: - Tabs
                    HStack(spacing: 0) {
                        TabItem(title: "الخدمات", selected: selectedTab == .services)
                            .onTapGesture { selectedTab = .services }
                        TabItem(title: "معرض الاعمال", selected: selectedTab == .portfolio)
                            .onTapGesture { selectedTab = .portfolio }
                        TabItem(title: "نبذة واحصائيات", selected: selectedTab == .about)
                            .onTapGesture { selectedTab = .about }
                        TabItem(title: "المراجعات", selected: selectedTab == .reviews)
                            .onTapGesture { selectedTab = .reviews }
                    }
                    .padding(.top)

                    // MARK: - Tab Content
                    switch selectedTab {
                    case .services:
                        FreelancerServicesTab()
                            .onTapGesture {
                                appRouter.navigate(to: .serviceDetails)
                            }
                    case .portfolio:
                        FreelancerPortfolioTab()
                    case .about:
                        FreelancerAboutTab()
                    case .reviews:
                        FreelancerReviewsTab()
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color.background())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text("احمد العزايزة")
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

struct TabItem: View {
    let title: String
    let selected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: selected ? .bold : .regular))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(selected ? Color.white : Color.clear)
            .overlay(
                Rectangle()
                    .frame(height: selected ? 2 : 0)
                    .foregroundColor(.yellow)
                    .padding(.top, 40)
            )
    }
}

#Preview {
    FreelancerProfileView()
        .environmentObject(AppState())
}

enum FreelancerTab {
    case services, portfolio, about, reviews
}

struct FreelancerServicesTab: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(0..<4) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImageView(
                        width: nil,
                        height: 120,
                        cornerRadius: 8,
                        imageURL: URL(string: "https://picsum.photos/300/200"),
                        placeholder: Image(systemName: "photo"),
                        contentMode: .fill
                    )

                    Text("تصميم بوستات لمنصات السوشيال لليبيا و مواقع الويب")
                        .font(.system(size: 12))
                        .lineLimit(2)

                    HStack {
                        Text("$10")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary())
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                        Label("4.8", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal)
    }
}

struct FreelancerPortfolioTab: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { index in
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                                .foregroundColor(.gray)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("مشروع رقم \(index + 1)")
                            .font(.subheadline)
                            .bold()
                        Text("نبذة قصيرة عن المشروع وتفاصيله ومجاله.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal)
    }
}

struct FreelancerAboutTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("نبذة عن الفريلانسر")
                .font(.headline)
            Text("هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة. لقد تم توليد هذا النص من مولد النص العربي.")
                .font(.body)
                .foregroundColor(.gray)

            Divider().padding(.vertical, 8)

            Text("احصائيات")
                .font(.headline)

            HStack {
                VStack {
                    Text("+1500")
                        .bold()
                    Text("مشروع")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("+1200")
                        .bold()
                    Text("عميل")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("4.8★")
                        .bold()
                    Text("تقييم")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FreelancerReviewsTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<3) { _ in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "person.fill"))

                        VStack(alignment: .leading) {
                            Text("مستخدم")
                                .bold()
                            Text("UXUI Client")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Label("4.8", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    Text("هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة. هذا النص يولد تلقائيًا من مولد النص العربي.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal)
    }
}
