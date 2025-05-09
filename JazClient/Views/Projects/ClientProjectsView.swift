//
//  ClientProjectsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct ClientProjectsView: View {
    @State private var selectedTab: ProjectStatus = .inProgress
    @State private var showSpeedRequest = false
    @State private var showEditRequest = false
    @State private var showCancelRequest = false
    @State private var showRating = false
    @State private var showRejectionReason = false
    @State private var showProjectOptions = false
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                ForEach(ProjectStatus.allCases, id: \.self) { status in
                    VStack(spacing: 16) {
                        Button(action: {
                            selectedTab = status
                        }) {
                            Text(status.title)
                                .fontWeight(selectedTab == status ? .bold : .regular)
                                .foregroundColor(.black)
                        }
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == status ? Color.brown : .clear)
                    }
                }
            }
            .padding(.vertical, 12)

            Divider()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<2) { _ in
                        ClientProjectCardView(
                            status: selectedTab,
                            showSpeedRequest: $showSpeedRequest,
                            showEditRequest: $showEditRequest,
                            showCancelRequest: $showCancelRequest,
                            showRating: $showRating,
                            showRejectionReason: $showRejectionReason,
                            showProjectOptions: $showProjectOptions
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showSpeedRequest) {
            SpeedRequestSheet(isPresented: $showSpeedRequest)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditRequest) {
            EditRequestSheet(isPresented: $showEditRequest)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCancelRequest) {
            CancelRequestSheet(isPresented: $showCancelRequest)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showRating) {
            RatingSheet(isPresented: $showRating)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showRejectionReason) {
            RejectionReasonSheet(isPresented: $showRejectionReason)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showProjectOptions) {
            ProjectOptionsSheet(
                isPresented: $showProjectOptions,
                onRequestEdit: { showEditRequest = true },
                onRequestCancel: { showCancelRequest = true },
                onRequestSpeedUp: { showSpeedRequest = true }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading) {
                    Text("📂 المشاريع")
                        .customFont(weight: .bold, size: 20)
                    Text("تحكم بجميع مشاريعك عبر المنصة!")
                        .customFont(weight: .regular, size: 10)
                }
                .foregroundColor(Color.black222020())
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

// MARK: - قالب واجهة منبثقة

struct ModalTemplate<Content: View>: View {
    let title: String
    let content: () -> Content
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title).font(.title3).bold()
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            content()
        }
        .padding()
    }
}

// MARK: - البطاقة الرئيسية

struct ClientProjectCardView: View {
    var status: ProjectStatus
    @Binding var showSpeedRequest: Bool
    @Binding var showEditRequest: Bool
    @Binding var showCancelRequest: Bool
    @Binding var showRating: Bool
    @Binding var showRejectionReason: Bool
    @Binding var showProjectOptions: Bool
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ahmed M Y Al-Azaiza").bold()
                    Text("UXUI Designer").font(.caption).foregroundColor(.gray)
                }
                Spacer()
                ProjectStatusBadge(status: status)
            }
            
            Text("الخدمة: تصميم بوستات لمنصات السوشيال لليبيا و مواقع الويب")
                .font(.callout)

            HStack {
                Text("موعد التسليم: 27 أكتوبر 2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\"تقييم 1400+\" ★ 4.5/5")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if status == .inProgress {
                HStack {
                    Button(action: { showSpeedRequest = true }) {
                        Text("طلب تسريع التسليم")
                            .customFont(weight: .bold, size: 12)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        // فتح المحادثة
                    }) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(Color.black151515())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    optionsButton
                }
            } else if status == .underReview {
                HStack(spacing: 10) {
                    Button(action: {}) {
                        Text("اعتماد التسليم")
                            .customFont(weight: .bold, size: 12)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary())
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        appRouter.navigate(to: .deliveryDetails)
                    }) {
                        Text("عرض التسليم")
                            .customFont(weight: .bold, size: 12)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(Color.black151515())
                            .cornerRadius(8)
                    }

                    Button(action: {
                        // فتح المحادثة
                    }) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(Color.black151515())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    optionsButton
                }
            } else if status == .completed {
                Button(action: { showRating = true }) {
                    Text("تقييم الفريلانسر")
                        .customFont(weight: .bold, size: 12)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary())
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else if status == .cancelled {
                Button(action: { showRejectionReason = true }) {
                    Text("عرض سبب الرفض")
                        .customFont(weight: .bold, size: 12)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.redE50000())
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    var optionsButton: some View {
        Button(action: { showProjectOptions = true }) {
            Image(systemName: "ellipsis")
                .foregroundColor(Color.black151515())
                .padding()
                .frame(height: 48) // نفس ارتفاع الزر النصي تقريبًا
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ClientProjectsView()
}
