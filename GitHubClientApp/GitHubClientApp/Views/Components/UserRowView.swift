//
//  UserRowView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// A row view representing a single GitHub user in a list.
///
/// This view shows:
/// - The user's avatar image (loaded asynchronously).
/// - The user's login name.
struct UserRowView: View {
    /// The `User` model representing the GitHub user.
    let user: User
    
    var body: some View {
        HStack {
            // MARK: - Avatar
            // Load the user's avatar image asynchronously.
            // Displays a gray placeholder with a person icon until the image is loaded.
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                image.resizable()
                    .scaledToFit() // Scale the image to fit its frame.
            } placeholder: {
                // Placeholder while avatar loads.
                Circle()
                    .fill(.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    )
            }
            .frame(width: 50, height: 50) // Set fixed size for avatar.
            .clipShape(Circle()) // Make the avatar circular.
            
            // MARK: - Username
            // Display the user's login name.
            Text(user.login)
                .font(.headline)
        }
    }
}
