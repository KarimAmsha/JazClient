import SwiftUI

struct CustomAsyncImage: View {
    var imageURL: URL?
    var cornerRadius: CGFloat
    var height: CGFloat = 200

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            if let image = phase.image {
                // Display the loaded image
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                    .cornerRadius(cornerRadius)
                    .clipped()
            } else if phase.error != nil {
                // Display a placeholder when loading failed
                Image(systemName: "questionmark.diamond")
                    .frame(height: height)
                    .foregroundColor(.gray)
            } else {
                // Display a placeholder while loading
                ProgressView()
                    .frame(height: height)
            }
        }
        .frame(height: height) // Ensuring the container view respects the height
    }
}

struct AsyncImageView: View {
    var width: CGFloat?
    var height: CGFloat
    var cornerRadius: CGFloat
    var imageURL: URL?
    var placeholder: Image?
    var contentMode: ContentMode = .fit

    var body: some View {
        if let imageURL = imageURL {
            AsyncImage(url: imageURL, scale: 1.0, content: { phase in
                switch phase {
                case .empty:
                    placeholder?
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .foregroundColor(.grayCCCCCC())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .failure(let error):
                    placeholder?
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .foregroundColor(.grayCCCCCC())
                @unknown default:
                    ProgressView()
                }
            })
            .aspectRatio(contentMode: contentMode)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
        } else {
            placeholder?
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: width, height: height)
                .cornerRadius(cornerRadius)
        }
    }
}

