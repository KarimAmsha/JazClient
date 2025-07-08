import SwiftUI

struct SliderView: View {
    let slider: Slider

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // الصورة كـ Background ثابت لا يتأثر بالنص
            if let imageUrl = slider.image, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.orange.opacity(0.5)
                    case .success(let img):
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                            .clipped()
                    case .failure(_):
                        Color.orange.opacity(0.2)
                    @unknown default:
                        Color.orange.opacity(0.2)
                    }
                }
            } else {
                Color.orange.opacity(0.5)
            }
            
            // طبقة تدرج مظلم لحماية النص من الخلفية
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.75), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 60)
            .frame(maxWidth: .infinity, alignment: .bottom)
            .cornerRadius(16)

            // النص فوق الكل دائماً
            VStack(alignment: .leading, spacing: 6) {
                if let title = slider.title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 1)
                }
                if let desc = slider.description {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
        .cornerRadius(16)
        .shadow(color: Color.orange.opacity(0.10), radius: 6)
        .padding(.horizontal, 8)
        .clipped() // مهم لمنع الصورة من الخروج أو تغطية النص
    }
}
