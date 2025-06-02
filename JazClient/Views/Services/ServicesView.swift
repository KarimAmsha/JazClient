//
//  ServicesView.swift
//  JazClient
//
//  Created by Karim OTHMAN on 2.06.2025.
//

import SwiftUI

struct ServicesView: View {
    @EnvironmentObject var appRouter: AppRouter
    @ObservedObject var viewModel: InitialViewModel
    let selectedIndexFromHome: Int?

    @State private var selectedTabIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
//            Picker("", selection: $selectedTabIndex) {
//                ForEach(viewModel.homeItems?.category, id: \ .self) { index in
//                    Text(viewModel.homeItems?.category?[index].localizedName ?? "")
//                        .tag(index)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal)
//
//            HStack {
//                TextField("ابحث عن خدمة", text: .constant(""))
//                    .padding(10)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//
//                Button(action: {}) {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(.black)
//                }
//            }
//            .padding(.horizontal)

//            ScrollView {
//                LazyVStack(spacing: 16) {
//                    ForEach(viewModel.homeItems?.category?[safe: selectedTabIndex]?.sub ?? [], id: \._id) { item in
//                        VStack(alignment: .leading, spacing: 8) {
//                            HStack(alignment: .top) {
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(item.title)
//                                        .font(.system(size: 16, weight: .bold))
//
//                                    Text(viewModel.homeItems?.category?[safe: selectedTabIndex]?.localizedName ?? "")
//                                        .font(.system(size: 14))
//                                        .foregroundColor(.gray)
//                                }
//
//                                Spacer()
//
//                                AsyncImage(url: URL(string: item.image ?? "")) { image in
//                                    image.resizable()
//                                } placeholder: {
//                                    Color.gray.opacity(0.2)
//                                }
//                                .frame(width: 50, height: 50)
//                            }
//
//                            Text(item.description)
//                                .font(.system(size: 13))
//                                .lineLimit(3)
//
//                            Button(action: {}) {
//                                Text("اطلب الآن")
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .foregroundColor(.white)
//                                    .background(Color.orange)
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(12)
//                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
//                        .padding(.horizontal)
//                    }
//                }
//            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("الخدمات")
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .onAppear {
            if let selectedIndexFromHome = selectedIndexFromHome {
                self.selectedTabIndex = selectedIndexFromHome
            } else {
                self.selectedTabIndex = 0
            }
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ServicesView(viewModel: InitialViewModel(errorHandling: ErrorHandling()), selectedIndexFromHome: 0)
}
