import SwiftUI

struct ServicesView: View {
    @EnvironmentObject var appRouter: AppRouter
    @ObservedObject var viewModel: InitialViewModel
    let selectedCategoryId: String? // nil if from tab bar

    @State private var selectedTabIndex: Int = 0
    @State private var showBackButton: Bool = false
    @State private var searchText: String = ""
    
    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Tabs (Hidden when searching)
            if !isSearching {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(viewModel.homeItems?.category?.enumerated() ?? [].enumerated()), id: \.element.id) { idx, category in
                            Button(action: { selectedTabIndex = idx }) {
                                Text(category.localizedName)
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(selectedTabIndex == idx ? Color(hex: "#0097A7") : Color(.systemGray6))
                                    .foregroundColor(selectedTabIndex == idx ? .white : .black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            // MARK: - Search Bar
            HStack {
                TextField("ابحث عن خدمة", text: $searchText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .submitLabel(.search)
                    .onSubmit { fetchDataWithSearch() }
                    .onChange(of: searchText) { _ in
                        // instant search (optional: add debounce for performance)
                        if searchText.count > 2 || searchText.isEmpty {
                            fetchDataWithSearch()
                        }
                    }
                Button(action: { fetchDataWithSearch() }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 6)

            // MARK: - Services List
            ScrollView {
                LazyVStack(spacing: 16) {
                    if isSearching, let categories = viewModel.homeItems?.category {
                        ForEach(categories, id: \.id) { category in
                            if let subItems = category.sub, !subItems.isEmpty {
                                // عنوان التصنيف لكل مجموعة نتائج
                                Text(category.localizedName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing)
                                    .padding(.top, 12)
                                ForEach(subItems, id: \.id) { item in
                                    ServiceCardView(
                                        item: item,
                                        categoryName: category.localizedName
                                    ) {
                                        // كود الإجراء عند الضغط (مثال)
                                        let selectedCategory = category
                                        let selectedSubCategory = item
                                        appRouter.navigate(to: .addOrder(selectedCategory: selectedCategory, selectedSubCategory: selectedSubCategory))
                                    }
                                }
                            }
                        }
                    } else {
                        // الوضع الافتراضي: فقط تبويب التصنيف الحالي
                        if let category = viewModel.homeItems?.category?[safe: selectedTabIndex],
                           let subItems = category.sub, !subItems.isEmpty {
                            ForEach(subItems, id: \.id) { item in
                                ServiceCardView(
                                    item: item,
                                    categoryName: category.localizedName
                                ) {
                                    // كود الإجراء عند الضغط
                                    let selectedCategory = category
                                    let selectedSubCategory = item
                                    appRouter.navigate(to: .addOrder(selectedCategory: selectedCategory, selectedSubCategory: selectedSubCategory))
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.background())
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    if showBackButton {
                        Button(action: { appRouter.navigateBack() }) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    Text("الخدمات")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading, showBackButton ? 8 : 0)
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            updateSelectedTab()
            showBackButton = selectedCategoryId != nil // Only show if coming from home
            fetchDataWithSearch()
        }
    }
    
    func updateSelectedTab() {
        if let id = selectedCategoryId,
           let index = viewModel.homeItems?.category?.firstIndex(where: { $0.id == id }) {
            selectedTabIndex = index
        } else {
            selectedTabIndex = 0
        }
    }

    func fetchDataWithSearch() {
        // هنا يفضل إضافة جلب اللوكيشن بدلاً من ثوابت lat/lng
        viewModel.fetchHomeItems(
            q: searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText,
            lat: 18.2418308,
            lng: 42.4660169
        )
    }
}

// MARK: - Service Card View (Extracted for Cleanliness)
struct ServiceCardView: View {
    let item: SubCategory
    let categoryName: String
    let onOrderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                    if !categoryName.isEmpty {
                        Text(categoryName)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                AsyncImage(url: URL(string: item.image ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Text(item.description)
                .font(.system(size: 13))
                .foregroundColor(.black)
                .lineLimit(3)
            Button(action: onOrderTap) {
                Text("اطلب الآن")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
#Preview {
    ServicesView(viewModel: InitialViewModel(errorHandling: ErrorHandling()), selectedCategoryId: nil)
}
