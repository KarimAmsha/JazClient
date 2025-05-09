//
//  AddUserProductView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI
import PopupView

struct AddUserProductView: View {
    @ObservedObject var viewModel: InitialViewModel
    @EnvironmentObject var appRouter: AppRouter
    @State var title = ""
    @State var name = ""
    @State var note = ""
    @State var iban = ""
    @State var total = ""
    @State var category = ""
    @State private var selectedImages: [SelectedImage] = []
    @State private var showImagePicker = false
    @State private var isShowingCategory = false
    @State private var selectedCategory: MainCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Image picker button
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.addPhotos)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Text(LocalizedStringKey.selectImages)
                                .foregroundColor(.primary1())
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Selected images
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImages) { selectedImage in
                                    Image(uiImage: selectedImage.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker2(selectedImages: $selectedImages)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("اختر التصنيف")
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        ZStack {
                            CustomTextField(text: $category, placeholder: "اختر التصنيف", textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .disabled(true)
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray8F8F8F())
                                    .padding()
                            }
                        }
                        .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                    }
                    .onTapGesture {
                        isShowingCategory = true
                    }
                    
                    CustomInputField(title: LocalizedStringKey.productTitle, text: $title, placeholder: LocalizedStringKey.productTitle)
                        .disabled(viewModel.isLoading)
                    
                    CustomInputField(title: "اسم البائع", text: $name, placeholder: "اسم البائع")
                        .disabled(viewModel.isLoading)

                    CustomInputField(title: LocalizedStringKey.note, text: $note, placeholder: LocalizedStringKey.note)
                        .disabled(viewModel.isLoading)

                    CustomInputField(title: LocalizedStringKey.iban, text: $iban, placeholder: LocalizedStringKey.iban)
                        .disabled(viewModel.isLoading)

                    CustomInputField(title: LocalizedStringKey.estimatedAmount, text: $total, placeholder: LocalizedStringKey.estimatedAmount, keyboardType: .numberPad)
                        .disabled(viewModel.isLoading)
                        .onChange(of: total) { value in
                            total = value.toInt()?.toEnglish() ?? ""
                        }
                }
            }
            
            
            if viewModel.isLoading {
                LoadingView()
            }
            
            Button {
                withAnimation {
                    let images: [UIImage?] = selectedImages.map { $0.image }

                    handleImageUploadAndPostRequest(
                        images: images
                    )
                }
            } label: {
                Text(LocalizedStringKey.addUserProducts)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
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
                    
                    Text(LocalizedStringKey.addUserProducts)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .popup(isPresented: $isShowingCategory) {
            let model = CustomModel(
                title: LocalizedStringKey.categories,
                content: "",
                items: viewModel.mainCategoryItems ?? [],
                onSelect: { item in
                    DispatchQueue.main.async {
                        selectedCategory = item
                        category = item.title ?? ""
                        
                        isShowingCategory = false
                    }
            })
            
            CategoryView(customModel: model)

        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .onAppear {
            viewModel.getMainCategories(q: "")
        }
    }
}

#Preview {
    AddUserProductView(viewModel: InitialViewModel(errorHandling: ErrorHandling()))
}

extension AddUserProductView {
    func createRequestBody(title: String, name: String, note: String, imageUrls: [String], iban: String, total: String) -> [String: Any] {
        return [
            "title": title,
            "name": name,
            "note": note,
            "images": imageUrls.map { [$0] },
            "iban": iban,
            "total": total
        ]
    }

    func handleImageUploadAndPostRequest(images: [UIImage?]) {
        viewModel.errorMessage = nil
        viewModel.isLoading = true
        let userID = UserSettings.shared.id ?? ""
        
        FirestoreService.shared.uploadMultipleImages(images: images, id: userID) { imageUrls, success in
            if success, let urls = imageUrls {
                var imagesArray: [String] = []
                for url in urls {
                    imagesArray.append(url)
                }
                
                let body: [String: Any] = [
                    "title": title,
                    "name": name,
                    "note": note,
                    "images": imagesArray,
                    "iban": iban,
                    "total": total,
                    "category_id": selectedCategory?.id ?? ""
                ]

                viewModel.addUserProduct2(params: body) {
                    appRouter.navigateBack()
                }
            } else {
                viewModel.errorMessage = "يجب عليك اختيار صور لرفعها"
                viewModel.isLoading = false
            }
        }
    }
}

struct CustomInputField: View {
    var title: String
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .customFont(weight: .regular, size: 12)
                .foregroundColor(.black1F1F1F())
            CustomTextField(
                text: $text,
                placeholder: placeholder,
                textColor: .black4E5556(),
                placeholderColor: .grayA4ACAD()
            )
            .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
            .keyboardType(keyboardType)
        }
    }
}
