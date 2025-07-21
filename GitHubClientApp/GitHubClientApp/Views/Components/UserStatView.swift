//
//  UserStatView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// A small reusable view that displays a user statistic (e.g., Followers, Following).
///
/// It shows:
/// - A label (e.g., "Followers:").
/// - A count next to the label.
struct UserStatView: View {
    /// The label for the statistic (e.g., "Followers" or "Following").
    let text: String
    
    /// The numeric value for the statistic.
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            // MARK: - Statistic Label
            // Displays the text label with slightly transparent white color.
            Text("\(text):")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            // MARK: - Statistic Value
            // Displays the numeric count in bold.
            Text("\(count)")
                .font(.headline)
                .bold()
        }
    }
}
