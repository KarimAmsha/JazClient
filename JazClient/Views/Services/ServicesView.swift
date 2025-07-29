import SwiftUI

struct ServicesView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    let selectedCategoryId: String?

    @State private var selectedTabIndex: Int = 0
    @State private var showBackButton: Bool = false
    @State private var searchText: String = ""

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var categories: [Category] {
        viewModel.homeItems?.category ?? []
    }

    var filteredSubItems: [(Category, SubCategory)] {
        guard isSearching else { return [] }
        return categories.flatMap { category in
            (category.sub ?? [])
                .filter { $0.title?.localizedStandardContains(searchText) ?? false }
                .map { (category, $0) }
        }
    }

    var currentCategory: Category? {
        categories[safe: selectedTabIndex]
    }

    var body: some View {
        ZStack {
            Color.background().ignoresSafeArea()
            VStack(spacing: 0) {

                if !isSearching, !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(categories.enumerated()), id: \.element.id) { idx, category in
                                Button(action: { selectedTabIndex = idx }) {
                                    Text(category.localizedName)
                                        .customFont(weight: .medium, size: 16)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(tabBackground(isSelected: selectedTabIndex == idx))
                                        .foregroundColor(selectedTabIndex == idx ? .white : .black)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .transition(.move(edge: .top))
                }

                HStack {
                    TextField("ابحث عن خدمة", text: $searchText)
                        .padding(12)
                        .background(Color.gray.opacity(0.11))
                        .cornerRadius(10)
                        .submitLabel(.search)
                        .onSubmit { fetchDataWithSearch() }
                        .onChange(of: searchText) { _ in
                            if searchText.count > 2 || searchText.isEmpty {
                                fetchDataWithSearch()
                            }
                        }
                    Button(action: { fetchDataWithSearch() }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 8)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("جاري تحميل الخدمات...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .customFont(weight: .medium, size: 17)
                            .padding()
                            .background(Color.white.opacity(0.96))
                            .cornerRadius(16)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            if isSearching {
                                if filteredSubItems.isEmpty {
                                    EmptyResultsView(message: "لا توجد خدمات مطابقة لبحثك.")
                                } else {
                                    ForEach(filteredSubItems, id: \.1.id) { (category, item) in
                                        ServiceCardView(
                                            item: item,
                                            categoryName: category.localizedName
                                        ) {
                                            appRouter.navigate(to: .addOrder(selectedCategory: category, selectedSubCategory: item))
                                        }
                                    }
                                }
                            } else {
                                if let subItems = currentCategory?.sub, !subItems.isEmpty {
                                    ForEach(subItems, id: \.id) { item in
                                        ServiceCardView(
                                            item: item,
                                            categoryName: currentCategory?.localizedName ?? ""
                                        ) {
                                            appRouter.navigate(to: .addOrder(selectedCategory: currentCategory!, selectedSubCategory: item))
                                        }
                                    }
                                } else {
                                    EmptyResultsView(message: "لا توجد خدمات متاحة في هذا القسم حالياً.")
                                }
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 22)
                    }
                }
            }
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
                            .customFont(weight: .bold, size: 20)
                            .padding(.leading, showBackButton ? 8 : 0)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                updateSelectedTab()
                showBackButton = selectedCategoryId != nil
                if viewModel.homeItems == nil || viewModel.homeItems?.category?.isEmpty == true {
                    fetchDataWithSearch()
                }
            }
        }
    }

    func updateSelectedTab() {
        if let id = selectedCategoryId,
           let index = categories.firstIndex(where: { $0.id == id }) {
            selectedTabIndex = index
        } else {
            selectedTabIndex = 0
        }
    }

    func fetchDataWithSearch() {
        LocationManager.shared.getCurrentLocation { coordinate in
            guard let coordinate = coordinate else { return }
            viewModel.fetchHomeItems(q: nil, lat: coordinate.latitude, lng: coordinate.longitude)
        }
    }

    @ViewBuilder
    private func tabBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue068DA9())
                .shadow(color: Color.blue068DA9().opacity(0.11), radius: 6, y: 3)
        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        }
    }
}

struct ServiceCardView: View {
    let item: SubCategory
    let categoryName: String // يمكن تجاهلها الآن
    let onOrderTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: item.image ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.13)
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .customFont(weight: .bold, size: 16)
                    if let price = item.price {
                        Text("\(Int(price)) ر.س")
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                    }
                }
                Spacer()
            }
            Text(item.description)
                .customFont(weight: .regular, size: 13)
                .foregroundColor(.black)
                .lineLimit(3)
                .padding(.bottom, 3)
            Button(action: onOrderTap) {
                Text("اطلب الآن")
                    .customFont(weight: .bold, size: 15)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.primary())
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.13), radius: 6, y: 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.055), radius: 4, y: 3)
        )
        .padding(.horizontal, 8)
    }
}

struct EmptyResultsView: View {
    let message: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundColor(.gray.opacity(0.23))
            Text(message)
                .customFont(weight: .medium, size: 14)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ServicesView(selectedCategoryId: nil)
        .environmentObject(AppRouter())
}
