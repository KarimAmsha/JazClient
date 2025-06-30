import SwiftUI

struct SliderView: View {
    let slider: Slider

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // صورة السلايدر من الإنترنت
//            if let imageUrl = slider.image, let url = URL(string: imageUrl) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.orange.opacity(0.5))
//                    case .success(let img):
//                        img
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .clipped()
//                    case .failure(_):
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.orange.opacity(0.2))
//                            .overlay(
//                                Image(systemName: "photo")
//                                    .font(.largeTitle)
//                                    .foregroundColor(.white.opacity(0.5))
//                            )
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.orange.opacity(0.5))
//            }
            
            // MARK: - Slider (صورة ثابتة حالياً)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.7))

            // العنوان والوصف
            VStack(alignment: .leading, spacing: 6) {
                Text(slider.title ?? "")
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                if let desc = slider.description {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(radius: 2)
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.37), .clear]), startPoint: .bottom, endPoint: .top)
            )
        }
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .cornerRadius(16)
        .shadow(color: Color.orange.opacity(0.10), radius: 6)
        .padding(.horizontal, 8)
    }
}
