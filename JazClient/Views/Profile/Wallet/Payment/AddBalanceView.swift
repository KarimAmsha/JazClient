//
//  AddBalanceView.swift
//  Wishy
//
//  Created by Karim Amsha on 15.06.2024.
//

import SwiftUI
import goSellSDK
import MoyasarSdk

struct AddBalanceView: View {
    @State private var coupon = ""
    @State private var amount = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var showAddBalanceView: Bool
    var onsuccess: () -> Void
    @StateObject private var viewModel = PaymentViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var orderViewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var showCardSheet = false
    @State private var lastAmount: Double = 0.0
    @StateObject private var paymentState = PaymentState(errorHandling: ErrorHandling())

    init(showAddBalanceView: Binding<Bool>, onsuccess: @escaping () -> Void) {
        _showAddBalanceView = showAddBalanceView
        self.onsuccess = onsuccess
    }

    var body: some View {
        VStack(spacing: 20) {
            CustomTextFieldWithTitle(text: $amount, placeholder: LocalizedStringKey.amount, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                .keyboardType(.numberPad)
                .disabled(paymentState.isLoading)

            if let errorMessage = paymentState.errorMessage {
                Text(errorMessage)
                    .customFont(weight: .regular, size: 14)
                    .foregroundColor(.redFF3F3F())
            }

            if paymentState.isLoading {
                LoadingView()
            }

            Button {
                checkCoupon()
            } label: {
                Text(LocalizedStringKey.send)
            }
            .buttonStyle(PrimaryButton(fontSize: 18, fontWeight: .bold, background: .primary(), foreground: .white, height: 48, radius: 12))
            .disabled(paymentState.isLoading)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        withAnimation {
                            appRouter.navigateBack()
                        }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: 20, height: 15)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white.clipShape(Circle()))
                    }
                    
                    Text(LocalizedStringKey.addAccount)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.black222020())
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(LocalizedStringKey.error), message: Text(alertMessage), dismissButton: .default(Text(LocalizedStringKey.ok)))
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .sheet(isPresented: $showCardSheet) {
            ZStack(alignment: .top) {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text("إدخال بيانات البطاقة")
                            .font(.title3.bold())
                        Spacer()
                        Button(action: { showCardSheet = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 28, weight: .semibold))
                                .padding(4)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        Color(.systemGray6)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .black.opacity(0.07), radius: 5, y: 2)
                    )

                    Divider().padding(.horizontal, 12)

                    VStack(spacing: 0) {
                        CreditCardView(request: createPaymentRequest()) { result in
                            handleMoyasarResult(result)
                            showCardSheet = false
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 28)
                        Spacer()
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }
            .presentationDetents([.fraction(0.65), .large])
        }
    }
}

extension AddBalanceView {
    private func checkCoupon() {
        paymentState.errorMessage = nil

        guard !amount.isEmpty, let doubleAmount = Double(amount), doubleAmount > 0 else {
            paymentState.errorMessage = "يرجى إدخال المبلغ بشكل صحيح"
            return
        }
        lastAmount = doubleAmount
        showCardSheet = true
    }
       
    func addBalance() {
        let params: [String: Any] = [
            "amount": lastAmount,
            "coupon": coupon
        ]
        paymentState.addBalanceToWallet(params: params) { message in
            showAddBalanceView = false
            self.onsuccess()
        }
    }
    
    func createPaymentRequest() -> PaymentRequest {
        do {
            return try PaymentRequest(
                apiKey: MoyasarEnvironment.production.apiKey, // أو .test حسب البيئة
                amount: Int(lastAmount * 100), // هللات
                currency: "SAR",
                description: "شحن رصيد المحفظة",
                metadata: [:]
            )
        } catch {
            fatalError("فشل في إنشاء PaymentRequest: \(error.localizedDescription)")
        }
    }
    
    func handleMoyasarResult(_ result: PaymentResult) {
        switch result {
        case let .completed(payment):
            if payment.status == .paid {
                // إذا نجح الدفع، أضف الرصيد
                addBalance()
            } else {
                var errorMsg = "فشل الدفع"
                switch payment.source {
                case .creditCard(let source):
                    errorMsg = source.message ?? "فشل الدفع"
                case .applePay(let source):
                    errorMsg = source.message ?? "فشل الدفع"
                case .stcPay(let source):
                    errorMsg = "فشل الدفع عبر STC Pay"
                default:
                    break
                }
                paymentState.errorMessage = errorMsg
            }
        case .failed(let error):
            paymentState.errorMessage = "فشل الدفع: \(error.localizedDescription)"
        case .canceled:
            paymentState.errorMessage = "تم إلغاء عملية الدفع"
        default:
            break
        }
    }
}

