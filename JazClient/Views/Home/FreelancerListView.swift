//
//  FreelancerListView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct FreelancerListView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var searchText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search Bar and Filter
            HStack(spacing: 12) {
                TextField("ابحث باسم الفريلانسر", text: $searchText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    )
                
                Button(action: {
                    // TODO: فتح الفلتر
                }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .padding()
                        .foregroundColor(.black151515())
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // MARK: - Freelancer List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        Button(action: {
                            appRouter.navigate(to: .freelancerProfile)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    AsyncImageView(
                                        width: 44,
                                        height: 44,
                                        cornerRadius: 22,
                                        imageURL: nil,
                                        placeholder: Image(systemName: "person.fill"),
                                        contentMode: .fill
                                    )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("احمد العزايزة")
                                            .font(.headline)

                                        Text("UXUI Designer")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.black151515())
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", 4.8))
                                            .foregroundColor(.black151515())
                                    }
                                    .font(.subheadline)
                                }

                                Text("هذا النص هو مثال يمكن أن يستبدل في نفس المساحة. لقد تم توليد هذا النص من مولد النص العربي...")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)

                                HStack(spacing: 12) {
                                    Label("10 خدمات", systemImage: "square.grid.2x2")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Label("5 مشاريع مكتملة", systemImage: "checkmark.seal")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Spacer()

                                    Text("$150")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding()
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
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("التصميم")
                            .font(.system(size: 18, weight: .bold))
                        Text("+1500 فريلانسر")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
    FreelancerListView()
        .environmentObject(AppState())
}
