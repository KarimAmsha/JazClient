import SwiftUI
import SkeletonUI

struct CategoryItemView: View {
    let item: Category?
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            AsyncImageView(
                width: (UIScreen.main.bounds.width - 48) / 3, // Adjusted width for three columns
                height: (UIScreen.main.bounds.width - 48) / 3, // Adjusted height for three columns
                cornerRadius: 10,
                imageURL: item?.image?.toURL(),
                placeholder: .placeholder,
                contentMode: .fill
            )
            .cornerRadius(4)
            .padding(6)
            .skeleton(with: item == nil)

            Text(item?.localizedName ?? "")
                .customFont(weight: .bold, size: 14)
                .foregroundColor(.primaryBlack())
                .padding(.bottom, 4)
                .skeleton(with: item == nil)
        }
        .frame(width: (UIScreen.main.bounds.width - 48) / 3) // Adjusted frame width for three columns
        .roundedBackground(cornerRadius: 4, strokeColor: .grayEBF0FF(), lineWidth: 1)
        .onTapGesture {
            onSelect()
        }
    }
}
