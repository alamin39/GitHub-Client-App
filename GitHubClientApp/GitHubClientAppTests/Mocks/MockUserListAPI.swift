//
//  MockUserListAPI.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/21.
//

import XCTest
@testable import GitHubClientApp

// Mock API for User List ViewModel
final class MockUserListAPI: UserFetching {
    var shouldThrowError = false
    var usersToReturn: [User] = []
    
    func fetchUsers() async throws -> [User] {
        if shouldThrowError {
            throw APIError.invalidResponse
        }
        return usersToReturn
    }
}
