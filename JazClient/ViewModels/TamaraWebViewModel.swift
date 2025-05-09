//
//  TamaraWebViewModel.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import Foundation
import Combine
import WebKit

struct TamaraMerchantURL {
    let success: String
    let failure: String
    let cancel: String
    let notification: String
}

enum TamaraWebResult {
    case success
    case failure
    case cancelled
    case notification
}

class TamaraWebViewModel: ObservableObject {
    @Published var url: String
    @Published var result: TamaraWebResult?
    @Published var isLoading: Bool = true
    let merchantURL: TamaraMerchantURL
    let webView: WKWebView

    init(url: String, merchantURL: TamaraMerchantURL) {
        self.url = url
        self.merchantURL = merchantURL

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        self.webView = WKWebView(frame: .zero, configuration: config)
    }
}
