//
//  Repository.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import Foundation

/// Represents a GitHub repository with essential details.
/// Conforms to `Identifiable` for SwiftUI list usage and
/// `Codable` for easy JSON encoding/decoding.
struct Repository: Identifiable, Codable {
    /// Unique identifier for the repository (provided by GitHub).
    let id: Int
    
    /// The name of the repository.
    let name: String
    
    /// A brief description of the repository (optional).
    let description: String?
    
    /// The number of stars the repository has received.
    let stargazersCount: Int
    
    /// The main programming language used in the repository (optional).
    let language: String?
    
    /// The HTML URL for viewing the repository on GitHub.
    let htmlUrl: String
    
    /// A flag indicating if the repository is a fork of another repository.
    let fork: Bool
}
