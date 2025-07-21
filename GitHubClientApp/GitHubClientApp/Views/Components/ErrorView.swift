//
//  ErrorView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// A reusable error display component with an icon, message, and retry button.
///
/// This view is typically used when a network request or data fetch fails.
/// It shows:
/// - A warning icon.
/// - A descriptive error message.
/// - A "Retry" button that triggers a retry action asynchronously.
struct ErrorView: View {
    /// The error message to display.
    let errorMessage: String
    
    /// A closure to execute when the user taps the "Retry" button.
    /// It is an async function, so it can trigger network calls safely.
    let onRetry: () async -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Error Icon
            // A large red warning triangle to indicate something went wrong.
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundStyle(.red.gradient)
            
            // MARK: - Error Message
            // Displays the error message in a readable, centered format.
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .font(.headline)
                .padding(.horizontal, 16)
            
            // MARK: - Retry Button
            // Tapping this button will trigger the `onRetry` closure asynchronously.
            Button(action: {
                Task { await onRetry() } // Wrap in a Task to call async function from the button.
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent) // Prominent button style
            .tint(.blue) // Blue background color
        }
        .frame(maxWidth: .infinity, minHeight: 200) // Takes full width with minimum height.
        .padding()
    }
}
