//
//  UpcomingRemindersView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI
import PopupView

struct UpcomingRemindersView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var viewModel = ReminderViewModel(errorHandling: ErrorHandling())
    @State var showAddReminder = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if viewModel.reminders.isEmpty {
                        DefaultEmptyView(title: LocalizedStringKey.noDataFound)
                    } else {
                        ForEach(viewModel.reminders, id: \.self) { item in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.title ?? "")
                                            .customFont(weight: .bold, size: 14)
                                        
                                        HStack(spacing: 10) {
                                            Text("تاريخ التذكير:")
                                            Text(item.date ?? "")
                                        }
                                        .customFont(weight: .regular, size: 12)
                                        
                                        HStack(spacing: 10) {
                                            Text("تذكير قبل:")
                                            Text(item.before?.toString() ?? "")
                                        }
                                        .customFont(weight: .regular, size: 12)
                                    }

                                    Spacer()
                                    
                                    Button {
                                        showAlertMessage(item: item)
                                    } label: {
                                        Image("ic_delete")
                                    }
                                }
                                
                                CustomDivider(color: .grayF2F2F2())
                            }
                            .foregroundColor(.primaryBlack())
                        }
                        
                        if viewModel.shouldLoadMoreData {
                            Color.clear.onAppear {
                                loadMore()
                            }
                        }
                        
                        if viewModel.isFetchingMoreData {
                            LoadingView()
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            Button {
                showAddReminder.toggle()
            } label: {
                Text(LocalizedStringKey.addNewReminder)
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

                    Text(LocalizedStringKey.upcomingReminders)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .popup(isPresented: $showAddReminder) {
            AddReminder { title, date, before in
                addReminder(title: title, date: date, before: before)
            } onClose: {
                showAddReminder.toggle()
            }
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
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            loadData()
        }
    }
}

#Preview {
    UpcomingRemindersView()
}

extension UpcomingRemindersView {
    func loadData() {
        viewModel.reminders.removeAll()
        viewModel.getReminders(page: 0, limit: 10)
    }
    
    func loadMore() {
        viewModel.loadMorReminders(limit: 10)
    }
    
    func addReminder(title: String, date: String, before: String) {
        let params: [String: Any] = [
            "title": title,
            "date": date,
            "before": before
        ]
        viewModel.addReminder(params: params, onsuccess: {
            loadData()
            showAddReminder.toggle()
        })
    }

    private func showAlertMessage(item: Reminder) {
        let alertModel = AlertModel(
            icon: "",
            title: LocalizedStringKey.deleteMessage,
            message: "",
            hasItem: false,
            item: "",
            okTitle: LocalizedStringKey.ok,
            cancelTitle: LocalizedStringKey.back,
            hidesIcon: true,
            hidesCancel: false,
            onOKAction: {
                appRouter.togglePopup(nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                    deleteReminder(item: item)
                })
            },
            onCancelAction: {
                withAnimation {
                    appRouter.togglePopup(nil)
                }
            }
        )

        appRouter.togglePopup(.alert(alertModel))
    }
    
    private func deleteReminder(item: Reminder) {
        let params: [String: Any] = [:]
        viewModel.deleteReminder(id: item.id ?? "", params: params) {
            loadData()
        }
    }
}
