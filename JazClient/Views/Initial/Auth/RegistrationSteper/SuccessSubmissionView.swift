import SwiftUI

struct SuccessSubmissionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(Color.primary())

                Text("لقد تم تقديم طلبك بنجاح!")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryBlack())

                Text("نفخر بمجهودك، لقد قمنا باستلام طلبك وهو الآن قيد المراجعة من الإدارة. سنقوم بإرسال رسالة تفيد بقبول أو رفض حسابك.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(hex: "FFF3D9"))
            .cornerRadius(16)

            Spacer()
        }
        .padding()
        .background(Color(hex: "FFF3D9"))
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isPresented = false
                appState.currentPage = .home
                UserSettings.shared.loggedIn = true
            }
        }
    }
}

#Preview {
    SuccessSubmissionView(isPresented: .constant(false))
        .environmentObject(AppState())
}
