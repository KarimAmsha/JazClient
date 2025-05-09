import SwiftUI

struct CartItemView: View {
    let item: CartProduct
    let onDelete: (CartProduct) -> Void
    let onQuantityChange: (CartProduct, Int) -> Void
    
    @State private var quantity: Int

    init(item: CartProduct, onDelete: @escaping (CartProduct) -> Void, onQuantityChange: @escaping (CartProduct, Int) -> Void) {
        self.item = item
        self.onDelete = onDelete
        self.onQuantityChange = onQuantityChange
        _quantity = State(initialValue: item.qty ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImageView(
                    width: 60,
                    height: 60,
                    cornerRadius: 5,
                    imageURL: item.image?.toURL(),
                    placeholder: Image(systemName: "photo"),
                    contentMode: .fill
                )
                
                VStack(alignment: .leading) {
                    Text(item.name ?? "")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.primaryBlack())
                    
                    if let variationName = item.variation_name, !variationName.isEmpty {
                        Text("النوع: \(variationName)")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.gray737373())
                            .padding(.top, 2)
                    }

                    HStack {
                        Text(String(format: "%.2f", item.sale_price ?? 0))
                        Text(LocalizedStringKey.sar)
                    }
                    .customFont(weight: .semiBold, size: 12)
                    .foregroundColor(.primary())

                }
                
                Spacer()
                
                HStack {
                    HStack(spacing: 8) {
                        Button(action: {
                            quantity += 1
                            onQuantityChange(item, quantity)
                        }) {
                            Image(systemName: "plus")
                        }
                        
                        Text("\(quantity.toEnglish())")
                            .padding(.horizontal, 8)
                        
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                                onQuantityChange(item, quantity)
                            }
                        }) {
                            Image(systemName: "minus")
                        }
                    }
                    .padding(4)
                    .customFont(weight: .semiBold, size: 12)
                    .foregroundColor(Color.primary())
                    .background(Color.primaryLight().cornerRadius(4))
                    
                    Button {
                        onDelete(item)
                    } label: {
                        Image("ic_delete")
                    }

                }
            }
            .padding(.vertical, 8)
        }
    }
}
