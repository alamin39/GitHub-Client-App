//
//  RepositoryWebView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for displaying a web page using `WKWebView`.
/// This is typically used to show a repository's GitHub page inside the app.
struct RepositoryWebView: UIViewRepresentable {
    /// The URL of the repository web page to load.
    let url: String
    
    /// Creates the `WKWebView` instance to be used in the SwiftUI view hierarchy.
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Attempt to convert the `url` string into a valid `URL` object.
        if let requestURL = URL(string: url) {
            let request = URLRequest(url: requestURL)
            webView.load(request)  // Load the specified URL in the web view.
        }
        
        return webView
    }
    
    /// Updates the existing `WKWebView` when SwiftUI requires it.
    /// (Currently no update logic is needed as the web content does not dynamically change.)
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
