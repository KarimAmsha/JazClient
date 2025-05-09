//
//  GroupListView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI

struct GroupListView: View {
    @State var isPublic = false
    @State var selectedGroup: Group?
    let onSelect: (Group, Bool) -> Void
    let onCancel: () -> Void
    @StateObject var viewModel = WishesViewModel(errorHandling: ErrorHandling())
    @StateObject var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(LocalizedStringKey.addToMyWishes)
                    .customFont(weight: .bold, size: 14)
                Spacer()
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black121212())
                }
            }
            
            if viewModel.groups.isEmpty {
                Spacer()
                Text("ليس لديك قوائم او مجموعات.. يرجى اضافة قوائم من قسم الامنيات من الواجهة الرئيسية.")
                    .customFont(weight: .medium, size: 16)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(viewModel.groups, id: \.self) { item in
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: selectedGroup == item ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(selectedGroup == item ? Color.primary1() : Color.gray)

                                    Text(item.name ?? "")
                                        .customFont(weight: .regular, size: 14)
                                        .foregroundColor(.black1C1C28())
                                    Spacer()
                                }
                                
                                CustomDivider()
                            }
                            .onTapGesture {
                                selectedGroup = item
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizedStringKey.privacy)
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.black1F1F1F())

                    HStack(spacing: 50) {
                        RadioButton(label: LocalizedStringKey.publicGroup, isSelected: isPublic) {
                            isPublic = true
                        }
                        RadioButton(label: LocalizedStringKey.privateGroup, isSelected: !isPublic) {
                            isPublic = false
                        }
                    }
                }
                
                if isPublic {
                    let cost = initialViewModel.appconstantsItems?.settings?.filter({ $0.name == "مبلغ الاكسبلور" }).first?.value ?? ""
                    let duration = initialViewModel.appconstantsItems?.settings?.filter({ $0.name == "مدة الاكسبلور باليوم" }).first?.value ?? ""
                        let message = "سيتم عرض الامنية في الاكسبلور لمدة \(duration) يوم وبسعر \(cost) ر.س"

                    Text(message)
                        .customFont(weight: .bold, size: 12)
                        .foregroundColor(.red)
                }
                
                Button {
                    withAnimation {
                        if let item = selectedGroup {
                            onSelect(item, isPublic)
                        }
                    }
                } label: {
                    Text(LocalizedStringKey.add)
                }
                .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
            }
        }
        .frame(height: 300)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 44)
        .ignoresSafeArea()
        .background(Color.white)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .onAppear {
            loadData()
            initialViewModel.fetchAppConstantsItems()
        }
    }
}

#Preview {
    GroupListView(onSelect: {_, _ in}, onCancel: {})
}

struct RadioButton: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(isSelected ? .primary() : .primaryLight())
                .onTapGesture {
                    action()
                }
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.black1F1F1F())
        }
        .padding(.vertical, 8)
    }
}

extension GroupListView {
    func loadData() {
        viewModel.groups.removeAll()
        viewModel.getWishGroups(page: 0, limit: 30, user_id: UserSettings.shared.id ?? "")
    }
    
//    private func showAlertMessage() {
//        let cost = initialViewModel.appconstantsItems?.settings?.filter({ $0.name == "مبلغ الاكسبلور" }).first?.value ?? ""
//        let duration = initialViewModel.appconstantsItems?.settings?.filter({ $0.name == "مدة الاكسبلور باليوم" }).first?.value ?? ""
//        let alertModel = AlertModel(
//            icon: "",
//            title: "",
//            message: "سيتم عرض الامنية في الاكسبلور لمدة \(duration) يوم وبسعر \(cost) ر.س",
//            hasItem: false,
//            item: "",
//            okTitle: LocalizedStringKey.accept,
//            cancelTitle: LocalizedStringKey.reject,
//            hidesIcon: true,
//            hidesCancel: false,
//            onOKAction: {
//                appRouter.togglePopup(nil)
//                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
//                    isPublic = true
//                })
//            },
//            onCancelAction: {
//                withAnimation {
//                    appRouter.togglePopup(nil)
//                }
//            }
//        )
//
//        appRouter.togglePopup(.alert(alertModel))
//    }
}
