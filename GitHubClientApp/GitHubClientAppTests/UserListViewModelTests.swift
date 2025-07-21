//
//  UserListViewModelTests.swift
//  GitHubClientAppTests
//
//  Created by Al-Amin on 2025/07/20.
//

import XCTest
@testable import GitHubClientApp

@MainActor
final class UserListViewModelTests: XCTestCase {
    private var mockAPI: MockUserListAPI!
    private var viewModel: UserListViewModel!
    
    // Runs before each test
    override func setUp() {
        super.setUp()
        mockAPI = MockUserListAPI()
        viewModel = UserListViewModel(apiClient: mockAPI)
    }
    
    // Runs after each test
    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        super.tearDown()
    }
    
    private func makeUser(id: Int = 1, login: String = "alamin", followers: Int = 12, following: Int = 10) -> User {
        User(id: id, login: login, avatarUrl: "", name: nil, followers: followers, following: following)
    }
    
    // MARK: - Tests
    
    func test_fetchUsers_success() async {
        // Given
        mockAPI.usersToReturn = [makeUser(login: "alamin", followers: 12, following: 10)]
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        if case .loaded(let users) = viewModel.usersState {
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users.first?.login, "alamin")
            XCTAssertEqual(users.first?.followers, 12)
            XCTAssertEqual(users.first?.following, 10)
        } else {
            XCTFail("Expected .loaded state but got \(viewModel.usersState)")
        }
    }
    
    func test_fetchUsers_failure() async {
        // Given
        mockAPI.shouldThrowError = true
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        if case .failed(let errorMessage) = viewModel.usersState {
            XCTAssertNotNil(errorMessage)
        } else {
            XCTFail("Expected .failed state but got \(viewModel.usersState)")
        }
    }
    
    func test_fetchUsers_ignoresDuplicateLoading() async {
        // Given
        viewModel.usersState = .loading
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        // State should remain .loading, because a duplicate call is ignored
        XCTAssertEqual(viewModel.usersState, .loading, "Expected .loading state but got \(viewModel.usersState)")
    }
    
    func test_fetchUsers_stopLoadingAfterFetch() async {
        // Given
        mockAPI.usersToReturn = [makeUser()]
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        // Loading should stop after fetch
        XCTAssertFalse(viewModel.usersState == .loading)
    }
    
    func test_usersProperty_whenLoaded_returnsUsers() {
        let mockUsers = [makeUser()]
        viewModel.usersState = .loaded(mockUsers)
        XCTAssertEqual(viewModel.users, mockUsers)
    }
    
    func test_usersProperty_whenNotLoaded_returnsEmpty() {
        viewModel.usersState = .idle
        XCTAssertTrue(viewModel.users.isEmpty)
        
        viewModel.usersState = .failed("Error")
        XCTAssertTrue(viewModel.users.isEmpty)
    }
    
    func test_fetchUsers_resetsErrorMessageBeforeLoading() async {
        viewModel.errorMessage = "Previous error"
        await viewModel.fetchUsers()
        XCTAssertNil(viewModel.errorMessage, "Expected errorMessage to be cleared before loading")
    }
    
    func test_fetchUsers_afterFailure_transitionsToLoadingAndLoaded() async {
        // 1. First call fails
        mockAPI.shouldThrowError = true
        await viewModel.fetchUsers()
        if case .failed = viewModel.usersState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failed state after error")
        }
        
        // 2. Second call succeeds
        mockAPI.shouldThrowError = false
        mockAPI.usersToReturn = [makeUser(login: "alamin")]
        await viewModel.fetchUsers()
        
        if case .loaded(let users) = viewModel.usersState {
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users.first?.login, "alamin")
        } else {
            XCTFail("Expected .loaded state after retry")
        }
    }
    
    func test_fetchUsers_overwritesLoadedDataOnRefresh() async {
        // Initial load
        mockAPI.usersToReturn = [makeUser()]
        await viewModel.fetchUsers()
        
        // Refresh with new data
        mockAPI.usersToReturn = [makeUser(id: 2, login: "NewUser", followers: 2, following: 10)]
        await viewModel.fetchUsers()
        
        if case .loaded(let users) = viewModel.usersState {
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users.first?.login, "NewUser")
            XCTAssertFalse(viewModel.users.contains(where: { $0.login == "alamin" }))
        } else {
            XCTFail("Expected .loaded state with refreshed data")
        }
    }
}
