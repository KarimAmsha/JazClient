//
//  AddReviewView.swift
//  Wishy
//
//  Created by Karim Amsha on 16.06.2024.
//

import SwiftUI

struct ProductReview: Identifiable {
    var id: String
    var name: String
    var image: String?
    var rating: Int?
    var note: String
}

struct AddReviewView: View {
    @EnvironmentObject var appRouter: AppRouter
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    let orderId: String
    @State private var productReviews: [ProductReview] = []

    var body: some View {
        VStack(spacing: 16) {
            ScrollView(showsIndicators: false) {
                ForEach(productReviews.indices, id: \.self) { index in
                    let product = productReviews[index]
                    VStack {
                        HStack {
                            AsyncImageView(
                                width: 60,
                                height: 60,
                                cornerRadius: 10,
                                imageURL: product.image?.toURL(),
                                placeholder: Image(systemName: "photo"),
                                contentMode: .fill
                            )
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(product.name)
                                        .customFont(weight: .bold, size: 14)
                                        .foregroundColor(.primaryBlack())
                                    Spacer()
                                    StarRatingView(rating: $productReviews[index].rating)
                                        .frame(width: 150) // Adjust the width as necessary
                                }
                                
                                TextField("اترك ملاحظة", text: $productReviews[index].note)
                                    .customFont(weight: .regular, size: 14)
                                    .foregroundColor(.primaryBlack())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }

                        CustomDivider()
                    }
                    .padding(.vertical, 8)
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .padding(.horizontal)
            }

            Button {
                submitReviews()
            } label: {
                Text(LocalizedStringKey.addReview)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            .padding(.horizontal)
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }

                    Text(LocalizedStringKey.addReview)
                        .customFont(weight: .bold, size: 18)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .onAppear {
            getOrderDetails()
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
    }
}

extension AddReviewView {
    func getOrderDetails() {
        viewModel.getOrderDetails(orderId: orderId) {
            // Initialize the product reviews from the order items
            if let items = viewModel.orderDetailsItem?.items?.items {
                productReviews = items.map { item in
                    ProductReview(
                        id: item.id ?? "",
                        name: item.name ?? "",
                        image: item.image,
                        rating: nil,
                        note: ""
                    )
                }
            }
        }
    }
    
    private func submitReviews() {
        let reviews = productReviews.compactMap { product -> [String: Any]? in
            guard let rating = product.rating else { return nil }
            return ["product_id": product.id, "rate": rating, "note": product.note]
        }

        guard !reviews.isEmpty else {
            viewModel.errorMessage = "الرجاء تقييم منتج واحد على الاقل"
            return
        }

        let params: [String: Any] = ["products": reviews]
        
        viewModel.addReview(orderID: orderId, params: params) { id in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct StarRatingView: View {
    @Binding var rating: Int?
    var maximumRating = 5
    var onImage = Image(systemName: "star.fill")
    var offImage = Image(systemName: "star")
    var onColor = Color.yellow
    var offColor = Color.gray

    var body: some View {
        HStack {
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .foregroundColor(number <= (rating ?? 0) ? onColor : offColor)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }

    private func image(for number: Int) -> Image {
        return number <= (rating ?? 0) ? onImage : offImage
    }
}
