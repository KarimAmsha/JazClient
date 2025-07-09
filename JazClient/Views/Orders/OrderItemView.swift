import SwiftUI

struct OrderItemView: View {
    let item: OrderModel
    let onSelect: () -> Void

    var body: some View {
        Button(action: { onSelect() }) {
            HStack(alignment: .top, spacing: 16) {
                // صورة المزود أو الخدمة (اختياري حسب الداتا المتوفرة)
                AsyncImage(
                    url: item.provider?.image?.toURL() ?? item.sub_category_id?.image?.toURL(),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    },
                    placeholder: {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray.opacity(0.2))
                    }
                )
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // تفاصيل الطلب
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.order_no ?? "-")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        // حالة الطلب بشكل كبسولة
                        if let statusText = item.orderStatus?.value {
                            Text(statusText)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.13))
                                .clipShape(Capsule())
                        }
                    }

                    // اسم الخدمة أو التصنيف
                    Text(item.sub_category_id?.title ?? item.category_id?.title ?? "-")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)

                    // العنوان مختصر
                    if let address = item.address?.streetName, !address.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Text(address)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }

                    // التاريخ والوقت والسعر
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(item.formattedCreateDate ?? "-")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                        if let time = item.dt_time {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text(time)
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        }

                        Spacer()

                        // السعر
                        if let price = item.price {
                            Text("\(Int(price)) ريال")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
            )
            .padding(.horizontal, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
