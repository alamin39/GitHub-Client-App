//
//  User.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import Foundation

/// Represents a GitHub user with basic profile details.
/// Conforms to `Identifiable` for use in SwiftUI lists,
/// `Codable` for easy decoding from JSON,
/// and `Equatable` for comparing user instances.
struct User: Identifiable, Codable, Equatable {
    /// Unique identifier for the user (provided by GitHub).
    let id: Int
    
    /// GitHub username (login handle).
    let login: String
    
    /// URL string for the user's avatar image.
    let avatarUrl: String
    
    /// Full name of the user, if available.
    let name: String?
    
    /// Number of followers (optional, not always fetched).
    let followers: Int?
    
    /// Number of users this user is following (optional, not always fetched).
    let following: Int?
}
