//
//  SafariView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onRedirect: (URL) -> Void

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let parent: SafariView

        init(_ parent: SafariView) {
            self.parent = parent
        }

        func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
            if !didLoadSuccessfully {
                print("❌ SafariView failed to load")
            }
        }

        func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo url: URL) {
            print("🔁 Redirected to: \(url.absoluteString)")
            parent.onRedirect(url)
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.onRedirect(URL(string: "https://wishy.sa/tamara/cancel")!)
            print("❌ SafariView closed by user")
        }
                
        func safariViewController(_ controller: SFSafariViewController, didRedirectTo URL: URL) {
            print("🔁 Redirected to: \(URL.absoluteString)")
            parent.onRedirect(URL)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safari = SFSafariViewController(url: url)
        safari.delegate = context.coordinator
        return safari
    }

    func updateUIViewController(_ safari: SFSafariViewController, context: Context) {}
}
