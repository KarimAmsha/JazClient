
import SwiftUI

struct ProjectsView: View {
    @State private var selectedTab: ProjectStatus = .inProgress
    @EnvironmentObject var appRouter: AppRouter
    @State private var showDelivery = false
    @State private var showRating = false
    @State private var showRejectionReason = false

    var body: some View {
        VStack {
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

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<2) { _ in
                        ProjectCardView(status: selectedTab, showDelivery: $showDelivery, showRating: $showRating, showRejectionReason: $showRejectionReason)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDelivery) {
            DeliveryView(showModal: $showDelivery)
        }
        .sheet(isPresented: $showRating) {
            ServiceRatingView(showModal: $showRating)
        }
        .sheet(isPresented: $showRejectionReason) {
            RejectionReasonView(showModal: $showRejectionReason)
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

enum ProjectStatus: String, CaseIterable {
    case inProgress, underReview, completed, cancelled

    var title: String {
        switch self {
        case .inProgress: return "قيد التنفيذ"
        case .underReview: return "قيد المراجعة"
        case .completed: return "المكتملة"
        case .cancelled: return "ملغية"
        }
    }

    var color: Color {
        switch self {
        case .inProgress: return Color.blue.opacity(0.1)
        case .underReview: return Color.yellow.opacity(0.2)
        case .completed: return Color.green.opacity(0.2)
        case .cancelled: return Color.red.opacity(0.2)
        }
    }

    var textColor: Color {
        switch self {
        case .inProgress: return .blue
        case .underReview: return .orange
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

struct ProjectStatusBadge: View {
    let status: ProjectStatus

    var body: some View {
        Text(status.title)
            .font(.caption)
            .padding(12)
            .background(status.color)
            .foregroundColor(status.textColor)
            .clipShape(Capsule())
    }
}

// MARK: - البطاقة

struct ProjectCardView: View {
    var status: ProjectStatus
    @Binding var showDelivery: Bool
    @Binding var showRating: Bool
    @Binding var showRejectionReason: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("اسم العميل").bold()
                Spacer()
                ProjectStatusBadge(status: status)
            }

            Text("الخدمة: تصميم بوستات لمنصات السوشيال لليبيا و مواقع الويب")
                .font(.callout)

            HStack {
                Text("27 أكتوبر 2024")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\"تقييم 1400+ تقييم\"  ★ 4.5/5")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            if status == .inProgress {
                HStack {
                    Button(action: {
                        showDelivery = true
                    }) {
                        Text("تسليم الخدمة")
                            .customFont(weight: .bold, size: 12)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary())
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Button(action: {}) {
                        Label("محادثة", systemImage: "bubble.left")
                            .customFont(weight: .bold, size: 12)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
            } else if status == .underReview {
                Button(action: {}) {
                    Label("محادثة", systemImage: "bubble.left")
                        .customFont(weight: .bold, size: 12)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            } else if status == .completed {
                Button(action: {
                    showRating = true
                }) {
                    Text("تقييم العميل")
                        .customFont(weight: .bold, size: 12)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary())
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else if status == .cancelled {
                Button(action: {
                    showRejectionReason = true
                }) {
                    Text("عرض سبب الرفض")
                        .customFont(weight: .bold, size: 12)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ProjectsView()
}
