//
//  RetailPaymentView.swift
//  Wishy
//
//  Created by Karim Amsha on 1.05.2024.
//

import SwiftUI
import goSellSDK
import TamaraSDK

struct RetailPaymentView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State var total = ""
    @ObservedObject var wishesViewModel = WishesViewModel(errorHandling: ErrorHandling())
    let wishId: String?
    @StateObject private var paymentViewModel = PaymentViewModel()
    @State private var payMada: Bool = true
    @State private var payTamara: Bool = false
    @StateObject var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var showTamaraPayment = false
    @State private var checkoutUrl = ""
    @State var tamaraViewModel: TamaraWebViewModel? = nil

    var body: some View {
        VStack {
            Image("ic_money")
                .padding(.top, 80)
            
            PaymentOptionsSection(payMada: $payMada, payTamara: $payTamara)
                .padding(.bottom, 16)

            Text("اكتب القيمة بالريال السعودي")
                .customFont(weight: .bold, size: 16)
                .foregroundColor(.primaryBlack())
            
            VStack(alignment: .leading) {
                TextField(LocalizedStringKey.sar, text: $total)
                    .placeholder(when: total.isEmpty) {
                        Text(LocalizedStringKey.sar)
                            .foregroundColor(.gray999999())
                    }
                    .customFont(weight: .regular, size: 14)
                    .keyboardType(.numberPad)
                    .accentColor(.primary())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .underline()
                    .roundedBackground(cornerRadius: 12, strokeColor: .gray898989(), lineWidth: 1)
            }
            .foregroundColor(.black222020())

            Spacer()
            
            if orderViewModel.isLoading {
                LoadingView()
            }

            Button {
                if total.isEmpty {
                    wishesViewModel.errorMessage = "ادخل قيمة للاستمرار بالدفع!"
                    return
                }

                let amount = total.toDouble() ?? 0.0

                if payMada {
                    startPayment(amount: amount)
                } else if payTamara {
                    startTamaraCheckout(amount: amount)
                }
            } label: {
                Text("الاستمرار للدفع")
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            .padding(.horizontal, 16)
            .disabled(orderViewModel.isLoading)
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text("ساهم الان بـ قَطّة!")
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $orderViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            MessageAlertObserverView(
                message: $wishesViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .overlay(
            MessageAlertObserverView(
                message: $paymentViewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onChange(of: paymentViewModel.paymentStatus) { status in
            guard let status = status else { return }

            wishesViewModel.isLoading = false

            switch status {
            case .success:
                payWish()
            case .failed(let message):
                paymentViewModel.errorMessage = message
            case .cancelled:
                paymentViewModel.errorMessage = "تم إلغاء عملية الدفع"
            }
        }
        .fullScreenCover(isPresented: $showTamaraPayment) {
            if let url = URL(string: checkoutUrl) {
                SafariView(url: url) { redirectedURL in
                    handleTamaraRedirect(url: redirectedURL)
                }
            }
        }
        .onAppear {
            GoSellSDK.mode = .production
            
            laodWishData()
        }
    }

    private func handleTamaraRedirect(url: URL) {
        let urlStr = url.absoluteString
        showTamaraPayment = false

        if urlStr.contains("wishy.sa/tamara/success") {
            payWish()
        } else if urlStr.contains("wishy.sa/tamara/failure") {
            orderViewModel.errorMessage = "فشلت عملية الدفع"
        } else if urlStr.contains("wishy.sa/tamara/cancel") {
            orderViewModel.errorMessage = "تم إلغاء عملية الدفع"
        }

        // بغض النظر عن الحالة، أغلق الفيو
        showTamaraPayment = false
    }

    func payWish() {
        let params: [String: Any] = [
            "total": total
        ]

        wishesViewModel.payWish(id: wishId ?? "", params: params) {
            appRouter.navigate(to: .paymentSuccess)
        }
    }

    func startPayment(amount: Double) {
        orderViewModel.isLoading = true
        paymentViewModel.updateAmount(amount.toString())
        paymentViewModel.startPayment()
    }

    func startTamaraCheckout(amount: Double) {
        orderViewModel.isLoading = true
        let productId = wishesViewModel.wish?.product_id?.id ?? ""

        let tamaraBody = TamaraBody(
            amount: amount,
            products: [
                TamaraProduct(
                    product_id: productId,
                    variation_name: "",
                    variation_sku: "",
                    qty: 1
                )
            ]
        )

        orderViewModel.tamaraCheckout(params: tamaraBody) {
            let url = orderViewModel.tamaraCheckout?.checkout_url ?? ""
            self.checkoutUrl = url
//            self.checkoutUrl = "https://raw.githack.com/KarimAmsha/my-project/main/index.html"

            // Initialize the Tamara view model with the new URL and merchantURL
            self.tamaraViewModel = TamaraWebViewModel(
                url: self.checkoutUrl,
                merchantURL: TamaraMerchantURL(
                    success: "https://wishy.sa/tamara/success",
                    failure: "https://wishy.sa/tamara/failure",
                    cancel: "https://wishy.sa/tamara/cancel",
                    notification: "https://wishy.sa/tamara/cancel"
                )
            )

            showTamaraPayment.toggle()
        }
    }
    
}

extension RetailPaymentView {
    func laodWishData() {
        wishesViewModel.getWish(id: wishId ?? "")
    }
}
struct PaymentOptionsSection: View {
    @Binding var payMada: Bool
    @Binding var payTamara: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("اختر طريقة الدفع")
                .customFont(weight: .bold, size: 15)
                .foregroundColor(.black121212())

            HStack(spacing: 20) {
                RetailCheckboxButton(title: "مدى", isChecked: $payMada, other: $payTamara)
                RetailCheckboxButton(title: "تمارا", isChecked: $payTamara, other: $payMada)
            }
        }
    }
}

struct RetailCheckboxButton: View {
    let title: String
    @Binding var isChecked: Bool
    @Binding var other: Bool

    var body: some View {
        Button {
            if !isChecked {
                isChecked = true
                other = false
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isChecked ? .primary() : .gray595959())
                Text(title)
                    .foregroundColor(.black121212())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
