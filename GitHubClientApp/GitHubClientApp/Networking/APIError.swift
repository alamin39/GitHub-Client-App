//
//  APIError.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/20.
//

import Foundation

/// Unified error surface for networking.
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case rateLimited
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided."
        case .invalidResponse:
            return "Invalid server response."
        case .unauthorized:
            return "Unauthorized request. Check your token."
        case .notFound:
            return "Resource not found."
        case .rateLimited:
            return "You have hit the rate limit. Try later."
        case .serverError(let code):
            return "Server error: \(code)."
        case .decodingError:
            return "Data format is invalid."
        case .networkError:
            return "Network issue. Check your internet connection."
        case .unknown(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}
