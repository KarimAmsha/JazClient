import SwiftUI

struct PrivacyPolicyAgreementView: View {
    @Binding var showSheet: Bool
    var onAgree: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("الموافقة على سياسة الاستخدام والخصوصية")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Spacer()
                Button(action: { showSheet = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(1...3, id: \.self) { section in
                        Text("البند \(section)")
                            .font(.headline)
                            .foregroundColor(.black)

                        VStack(alignment: .trailing, spacing: 8) {
                            ForEach(1...2, id: \.self) { _ in
                                Text("هذا النص هو مثال للنص يمكن أن يستبدل في نفس المساحة. لقد تم توليد هذا النص من مولد النص العربي.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }

            PrimaryActionButton(title: "أوافق على سياسة الاستخدام والخصوصية") {
                onAgree()
                showSheet = false
            }
        }
        .padding()
        .background(Color.white)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    PrivacyPolicyAgreementView(showSheet: .constant(true), onAgree: {})
}
