//
//  AppState.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI
import MapKit

class AppState: ObservableObject {
    @Published var currentPage: Page = .home
    @Published var currentAddSelection: RequestType = .joiningRequest
    @Published var shouldAnimating: Bool = false
    @Published var showingSucessToastStatus: Bool = false
    @Published var showingErrorToastStatus: Bool = false
    @Published var showingLogoutView: Bool = false
    @Published var toastTitle: String = ""
    @Published var toastMessage: String = ""
    @Published var selection = 0
    @Published var showingDatePicker = false
    @Published var showingTimePicker = false
    @Published var phoneNumber = ""
    @Published var userId = ""
    @Published var token = ""
    @Published var registerType = ""
//    @Published var selectedCategory: Category?
//    @Published var selectedSubCategory: SubCategory?
    @Published var selectedDate: Date?
    @Published var startCoordinate: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 24.1136, longitude: 46.3753)
    @Published var endCoordinate: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
    @Published var referalUrl: URL?
    @Published var cartCount = 0

    init() {
        
    }

    func showingActivityIndicator(_ status: Bool) {
        shouldAnimating = status
    }
    
    func showSuccessToast(_ title: String, _ msg: String) {
        shouldAnimating = false
        showingSucessToastStatus = true
        showingErrorToastStatus = false
        toastTitle = ""
        toastMessage = msg
    }
    
    func showErrorToast(_ title: String,_ msg: String) {
        shouldAnimating = false
        showingErrorToastStatus = true
        showingSucessToastStatus = false
        toastTitle = title
        toastMessage = msg
    }

    func cleanToasts() {
        showingSucessToastStatus = false
        showingErrorToastStatus = false
        toastTitle = ""
        toastMessage = ""
    }
}
