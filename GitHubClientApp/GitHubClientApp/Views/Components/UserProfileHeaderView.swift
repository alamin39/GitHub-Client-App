//
//  UserProfileHeaderView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// A header view displaying a GitHub user's profile information.
///
/// This view shows:
/// - The user's avatar.
/// - The full name (or login if no name).
/// - The username (handle).
/// - Followers and following counts.
/// - A gradient background with a card-like appearance.
struct UserProfileHeaderView: View {
    /// The `User` model containing the profile information.
    let user: User
    
    /// The username (login handle) of the user.
    let username: String
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Avatar
            // Displays the user's avatar using AsyncImage.
            // If the image is not yet loaded, a placeholder with a person icon is shown.
            AsyncImage(url: URL(string: user.avatarUrl)) { image in
                image.resizable()
                    .scaledToFill() // Scale image to fill the frame without empty spaces.
            } placeholder: {
                // Placeholder while the image loads
                Circle()
                    .fill(.black.opacity(0.5))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    )
            }
            .frame(width: 120, height: 120) // Avatar size
            .clipShape(Circle()) // Circular avatar
            .overlay(Circle().stroke(.white, lineWidth: 4)) // White border around avatar
            .shadow(radius: 6) // Drop shadow for depth
            
            // MARK: - Full Name & Username
            // Display full name if available; otherwise, fallback to login name.
            Text(user.name ?? user.login)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Display username (GitHub handle) with '@' prefix
            Text("@\(username)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            // MARK: - Stats
            // Horizontal stack for "Followers" and "Following" counts.
            HStack(spacing: 24) {
                UserStatView(text: "Followers", count: user.followers ?? 0)
                UserStatView(text: "Following", count: user.following ?? 0)
            }
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity) // Stretch horizontally
        .padding(.vertical, 32) // Vertical padding
        
        // MARK: - Background & Styling
        .background(
            // Gradient background for a more visually appealing header
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16) // Rounded corners
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4) // Shadow for depth
        .padding(.horizontal, 16) // Horizontal padding for spacing
    }
}

#Preview {
    UserProfileHeaderView(user: User(id: 1,
                                     login: "alamin39",
                                     avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4",
                                     name: "Al-Amin",
                                     followers: 18,
                                     following: 25),
                          username: "alamin39")
}
