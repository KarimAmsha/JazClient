import SwiftUI

struct DefaultEmptyView: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String = "tray"

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 50)

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(Color.primary())
                    .opacity(0.85)
            }

            Text(title)
                .customFont(weight: .bold, size: 16)
                .foregroundColor(Color.primaryDark())
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).opacity(0.30))
        .padding(.horizontal, 24)
    }
}

#Preview {
    DefaultEmptyView(
        title: "لا توجد طلبات حالياً",
        subtitle: "جرب تحديث الصفحة أو عد لاحقاً.",
        systemImage: "tray"
    )
}
