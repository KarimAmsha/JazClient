//
//  HTMLView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI
import WebKit

struct HTMLView: UIViewRepresentable {
    let html: String
    @Binding var contentHeight: CGFloat

    init(html: String, contentHeight: Binding<CGFloat>) {
        self.html = html
        self._contentHeight = contentHeight
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator

        let direction = UIApplication.shared.userInterfaceLayoutDirection
        let lang = direction == .rightToLeft ? "ar" : "en" // Change "ar" to your RTL language code
        let adjustedHTML = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><style>html {direction: \(direction == .rightToLeft ? "rtl" : "ltr");}</style></head><body lang=\"\(lang)\">\(html)</body></html>"

        webView.loadHTMLString(adjustedHTML, baseURL: nil)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLView

        init(_ parent: HTMLView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                if let height = result as? CGFloat {
                    self.parent.contentHeight = height
                }
            }
        }
    }
}

