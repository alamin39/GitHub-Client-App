//
//  RepositoryRowView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// A SwiftUI view that displays summary details of a GitHub repository.
///
/// This view is intended to be displayed in a list of repositories, showing:
/// - Repository name
/// - Description (if available)
/// - Star count and primary language (if available)
/// - A chevron indicating navigability
struct RepositoryRowView: View {
    /// The repository model containing details such as name, description, stars, and language.
    let repository: Repository
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Main content (repository info)
            VStack(alignment: .leading, spacing: 6) {
                
                // Repository name
                Text(repository.name)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Repository description (optional)
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)                      // Limit to 2 lines for compactness
                        .multilineTextAlignment(.leading)
                }
                
                // Star count and language (if available)
                HStack(spacing: 10) {
                    Text("⭐️ \(repository.stargazersCount)")  // Show star count
                    
                    if let language = repository.language {
                        Text("🔴 \(language)")              // Show primary language
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // MARK: - Chevron icon (indicates navigation)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(.white) // Card-like background
        .cornerRadius(12)   // Rounded corners for card effect
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2) // Subtle shadow
    }
}

#Preview {
    RepositoryRowView(repository: Repository(
        id: 10,
        name: "awesome-ios",
        description: "A curated list of awesome iOS frameworks.",
        stargazersCount: 1500,
        language: "Swift",
        htmlUrl: "https://github.com/vsouza/awesome-ios",
        fork: false
    ))
    .padding()
}
