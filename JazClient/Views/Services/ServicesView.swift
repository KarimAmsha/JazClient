import SwiftUI
import CoreLocation

struct ServicesView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject private var locationManager = LocationManager.shared
    let selectedCategoryId: String?

    @State private var selectedTabIndex: Int = 0
    @State private var showBackButton: Bool = false
    @State private var searchText: String = ""

    // تحسينات الأداء
    @State private var lastQuery: String? = nil
    @State private var lastCoordinate: CLLocationCoordinate2D? = nil
    @State private var lastFetchSignature: String? = nil
    @State private var searchTask: Task<Void, Never>? = nil

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isSearching: Bool {
        !trimmedSearchText.isEmpty
    }

    var categories: [Category] {
        viewModel.homeItems?.category ?? []
    }

    var filteredSubItems: [(Category, SubCategory)] {
        guard isSearching else { return [] }
        return categories.flatMap { category in
            (category.sub ?? [])
                .filter {
                    ($0.title?.localizedStandardContains(trimmedSearchText) ?? false) ||
                    ($0.description?.localizedStandardContains(trimmedSearchText) ?? false)
                }
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
                            // Debounce لمنع إطلاق طلب عند كل حرف
                            searchTask?.cancel()
                            let currentText = trimmedSearchText
                            searchTask = Task { [currentText] in
                                try? await Task.sleep(nanoseconds: 350_000_000) // 350ms
                                if Task.isCancelled { return }
                                if currentText.count > 2 || currentText.isEmpty {
                                    fetchDataWithSearch(query: currentText)
                                }
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
                                            if let currentCategory = currentCategory {
                                                appRouter.navigate(to: .addOrder(selectedCategory: currentCategory, selectedSubCategory: item))
                                            }
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

                // اطلب الموقع في الخلفية لكن لا تنتظر وصوله لبدء الجلب
                locationManager.requestLocationIfNeeded()

                // جلب سريع بإحداثيات معروفة (آخر محفوظ أو افتراضي) حتى تظهر النتائج فورًا
                if viewModel.homeItems == nil || viewModel.homeItems?.category?.isEmpty == true {
                    fetchDataWithSearch()
                }
            }
            .onChange(of: viewModel.homeItems) { _ in
                // أعد ضبط التبويب بعد وصول البيانات
                updateSelectedTab()
            }
            .onChange(of: locationManager.userLocation) { newCoord in
                guard let coord = newCoord else { return }
                // إذا كنا نستخدم إحداثيات افتراضية أو تغيّر الموقع بشكل ملحوظ، أعِد الجلب
                if lastCoordinate == nil || coordinatesDifferent(lastCoordinate!, coord) {
                    lastCoordinate = coord
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

    // توقيع لمنع تكرار نفس الطلب (query + lat/lng)
    private func makeSignature(query: String?, coord: CLLocationCoordinate2D) -> String {
        let q = query ?? "nil"
        let lat = (coord.latitude * 1000).rounded() / 1000
        let lng = (coord.longitude * 1000).rounded() / 1000
        return "\(q)|\(lat),\(lng)"
    }

    private func coordinatesDifferent(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
        abs(a.latitude - b.latitude) > 0.01 || abs(a.longitude - b.longitude) > 0.01
    }

    func fetchDataWithSearch(query: String? = nil) {
        let qTrim = (query ?? trimmedSearchText).trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveQuery: String? = qTrim.isEmpty ? nil : qTrim

        // استخدم آخر موقع معروف أو افتراضي مباشرة لتسريع الظهور
        let coord: CLLocationCoordinate2D = locationManager.userLocation
            ?? lastCoordinate
            ?? CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753) // الرياض كافتراضي

        let signature = makeSignature(query: effectiveQuery, coord: coord)
        if signature == lastFetchSignature {
            return // لا تعيد نفس الطلب
        }

        lastFetchSignature = signature
        lastQuery = effectiveQuery
        lastCoordinate = coord

        viewModel.fetchHomeItems(q: effectiveQuery, lat: coord.latitude, lng: coord.longitude)
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
    let categoryName: String
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
                    Text(item.title ?? "")
                        .customFont(weight: .bold, size: 16)
                    if let price = item.price {
                        Text("\(String(format: "%.0f", price)) ر.س")
                            .customFont(weight: .medium, size: 13)
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                    }
                }
                Spacer()
            }
            Text(item.description ?? "")
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
