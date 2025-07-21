//
//  APIClient.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import Foundation

/// A protocol defining the ability to fetch a list of GitHub users.
protocol UserFetching {
    /// Fetches a list of GitHub users.
    /// - Returns: An array of `User` objects.
    /// - Throws: An `APIError` if the request fails.
    func fetchUsers() async throws -> [User]
}

/// A protocol defining the ability to fetch detailed information for a specific GitHub user.
protocol UserDetailFetching {
    /// Fetches detailed information about a specific user.
    /// - Parameter username: The GitHub username.
    /// - Returns: A `User` object containing detailed user info.
    /// - Throws: An `APIError` if the request fails.
    func fetchUserDetail(username: String) async throws -> User
    
    /// Fetches repositories for a specific user.
    /// - Parameter username: The GitHub username.
    /// - Returns: An array of `Repository` objects for the given user.
    /// - Throws: An `APIError` if the request fails.
    func fetchUserRepositories(username: String) async throws -> [Repository]
}

/// A concrete API client for communicating with GitHub's REST API.
struct APIClient {
    /// A shared, singleton instance of `APIClient` for convenience.
    static let shared = APIClient()
    
    /// A JSON decoder configured to convert `snake_case` keys from the GitHub API
    /// to `camelCase` properties in Swift models.
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - Generic fetch method
    
    /// A generic helper method for making network requests and decoding JSON responses.
    /// - Parameter endpoint: The API endpoint (relative to `AppConstants.baseURL`).
    /// - Returns: A decoded object of type `T`.
    /// - Throws: An `APIError` if there is a network failure, invalid response, or decoding error.
    private func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        // Construct the full URL
        guard let url = URL(string: AppConstants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        // Prepare the request with headers
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add Authorization header if a GitHub token is set
        if !AppConstants.githubToken.isEmpty {
            request.setValue("token \(AppConstants.githubToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Execute the network request using async/await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            break // Successful response, continue to decoding
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.rateLimited
        case 404:
            throw APIError.notFound
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        // Decode the JSON response into the requested model
        do {
            return try APIClient.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

// MARK: - UserFetching Conformance
extension APIClient: UserFetching {
    /// Fetches a list of GitHub users.
    /// - Returns: An array of `User` objects.
    func fetchUsers() async throws -> [User] {
        try await fetch("/users")
    }
}

// MARK: - UserDetailFetching Conformance
extension APIClient: UserDetailFetching {
    /// Fetches detailed information for a specific GitHub user.
    /// - Parameter username: The GitHub username.
    /// - Returns: A `User` object.
    func fetchUserDetail(username: String) async throws -> User {
        try await fetch("/users/\(username)")
    }
    
    /// Fetches all repositories for a specific GitHub user.
    /// - Parameter username: The GitHub username.
    /// - Returns: An array of `Repository` objects.
    func fetchUserRepositories(username: String) async throws -> [Repository] {
        try await fetch("/users/\(username)/repos")
    }
}
