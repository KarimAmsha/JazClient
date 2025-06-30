import SwiftUI

struct DefaultEmptyView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            
            // صورة من النظام
            Image(systemName: "tray")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.3))
            
            Text(title)
                .customFont(weight: .bold, size: 14)
                .foregroundColor(.gray)

            Spacer()
        }
    }
}

#Preview {
    DefaultEmptyView(title: "لا يوجد طلبات")
}
