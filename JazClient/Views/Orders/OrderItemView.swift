import SwiftUI

struct OrderItemView: View {
    let item: OrderModel
    let onSelect: () -> Void

    // المبلغ النهائي شامل الضريبة (مع الأخذ بالتعديلات إن وجدت)
    private var finalAmount: Double {
        if let newTotal = item.new_total, newTotal > 0 { return newTotal }
        if let net = item.netTotal, net > 0 { return net }
        if let total = item.total, total > 0 { return total }
        let base = item.price ?? 0
        let discount = item.totalDiscount ?? 0
        let tax = item.tax ?? 0
        return max(0, base - discount + tax)
    }

    var body: some View {
        Button(action: { onSelect() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(item.category_id?.title ?? "—")
                            .customFont(weight: .bold, size: 16)
                            .foregroundColor(.primary)
                        Text(item.sub_category_id?.title ?? "—")
                            .customFont(weight: .regular, size: 16)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if let statusText = item.orderStatus?.value {
                        Text(statusText)
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(item.orderStatus?.colors.foreground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(item.orderStatus?.colors.background)
                            .cornerRadius(6)
                    }
                }

                if let address = item.address?.address {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(address)
                            .lineLimit(2)
                    }
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.gray)
                }

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(item.formattedCreateDate ?? "—")
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(item.dt_time ?? "—")
                    }
                }
                .customFont(weight: .regular, size: 14)
                .foregroundColor(.gray)

                if let providerName = item.provider?.name {
                    HStack(spacing: 6) {
                        Image(systemName: "wrench.adjustable")
                        Text("مزود الخدمة: \(providerName)")
                    }
                    .customFont(weight: .bold, size: 13)
                    .foregroundColor(.gray)
                }

                HStack(alignment: .firstTextBaseline) {
                    Spacer()
                    Text("\(String(format: "%.2f", finalAmount)) SAR")
                        .customFont(weight: .bold, size: 16)
                        .foregroundColor(.black)
                    // يمكنك إظهار توضيح صغير إن رغبت
                    // Text("شامل الضريبة")
                    //     .customFont(weight: .regular, size: 11)
                    //     .foregroundColor(.gray)
                }

                Divider()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
