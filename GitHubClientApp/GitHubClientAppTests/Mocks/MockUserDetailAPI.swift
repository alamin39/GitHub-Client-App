//
//  MockUserDetailAPI.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/21.
//

import XCTest
@testable import GitHubClientApp

// Mock API for User Detail ViewModel
final class MockUserDetailAPI: UserDetailFetching {
    // Results per endpoint
    var userResult: Result<User, Error> = .failure(MockError.unset)
    var reposResult: Result<[Repository], Error> = .failure(MockError.unset)
    
    // Optional artificial delay (ns) to simulate slow network
    var delayNanoseconds: UInt64? = nil
    
    // Call counters for concurrency assertions
    private(set) var userCallCount = 0
    private(set) var reposCallCount = 0
    
    func fetchUserDetail(username: String) async throws -> User {
        userCallCount += 1
        if let delay = delayNanoseconds { try? await Task.sleep(nanoseconds: delay) }
        return try userResult.get()
    }
    
    func fetchUserRepositories(username: String) async throws -> [Repository] {
        reposCallCount += 1
        if let delay = delayNanoseconds { try? await Task.sleep(nanoseconds: delay) }
        return try reposResult.get()
    }
    
    enum MockError: Error { case unset }
}
