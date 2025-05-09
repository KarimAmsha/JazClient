//
//  EarningsView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 8.05.2025.
//

import SwiftUI

struct EarningsView: View {
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 16) {
            // Balance card
            VStack(spacing: 16) {
                Text("المبلغ المتاح للسحب")
                    .foregroundColor(.white)
                Text("$1,200")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Button(action: {}) {
                    Text("سحب الارباح")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.primary())
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.primary())
            .cornerRadius(20)
            .padding(.horizontal)

            // Transactions
            VStack(alignment: .leading, spacing: 12) {
                Text("اخر العمليات")
                    .bold()
                    .padding(.horizontal)

                ForEach(0..<4) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("$1200")
                                .bold()
                            Text("سحب ارباح")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("12 نوفمبر 2024")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(i == 2 ? "مرفوضة" : "مكتمل")
                                .font(.caption2)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(i == 2 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                .foregroundColor(i == 2 ? .red : .green)
                                .clipShape(Capsule())
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    .padding(.horizontal)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.background())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    Button(action: {
                        appRouter.navigateBack()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                    }

                    VStack(alignment: .leading) {
                        Text("ارباحي")
                            .customFont(weight: .bold, size: 20)
                        Text("تحكم برصيدك وارباحك عبر المنصة!")
                            .customFont(weight: .regular, size: 10)
                    }
                    .foregroundColor(Color.black222020())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
            }
        }
    }
}

#Preview {
    EarningsView()
        .environmentObject(AppRouter())
}
