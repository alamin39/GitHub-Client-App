//
//  UserDetailViewModelTests.swift
//  GitHubClientAppTests
//
//  Created by Al-Amin on 2025/07/21.
//

import XCTest
@testable import GitHubClientApp

@MainActor
final class UserDetailViewModelTests: XCTestCase {
    private var mockAPI: MockUserDetailAPI!
    private var viewModel: UserDetailViewModel!
    private let usernameUnderTest = "octocat"
    
    override func setUp() {
        super.setUp()
        mockAPI = MockUserDetailAPI()
        viewModel = UserDetailViewModel(username: usernameUnderTest, apiClient: mockAPI)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        super.tearDown()
    }
    
    private func makeUser(id: Int = 1, login: String = "octocat") -> User {
        User(id: id, login: login, avatarUrl: "", name: nil, followers: 12, following: 10)
    }
    
    private func makeRepository(id: Int = 1, name: String = "RepoA", stargazersCount: Int = 20, fork: Bool = false) -> Repository {
        Repository(id: id, name: name, description: nil, stargazersCount: stargazersCount, language: nil, htmlUrl: "", fork: fork)
    }
    
    // MARK: - Initial State
    func test_initialState() {
        XCTAssertEqual(viewModel.userState, .idle)
        XCTAssertTrue(viewModel.repositories.isEmpty)
        XCTAssertTrue(viewModel.hasNoRepositories)
    }
    
    // MARK: - Success Flow
    func test_fetchDetails_success_setsUserAndRepos() async {
        // Given
        let user = makeUser()
        let repos = [
            makeRepository(id: 1, name: "RepoA", stargazersCount: 5),
            makeRepository(id: 2, name: "RepoB", stargazersCount: 2, fork: true),
            makeRepository(id: 3, name: "RepoC", stargazersCount: 20)
        ]
        mockAPI.userResult = .success(user)
        mockAPI.reposResult = .success(repos)
        
        // When
        await viewModel.fetchDetails()
        
        // Then
        guard case .loaded(let loadedUser) = viewModel.userState else {
            return XCTFail("Expected .loaded user state.")
        }
        XCTAssertEqual(loadedUser, user)
        
        // Should filter out forks and sort by stargazers desc: RepoC (20), RepoA (5)
        XCTAssertEqual(viewModel.repositories.map { $0.name }, ["RepoC", "RepoA"])
        XCTAssertFalse(viewModel.hasNoRepositories)
        XCTAssertEqual(mockAPI.userCallCount, 1)
        XCTAssertEqual(mockAPI.reposCallCount, 1)
    }
    
    // MARK: - Failure Flow (user fetch fails)
    func test_fetchDetails_userFailure_setsFailedState_andClearsRepos() async {
        mockAPI.userResult = .failure(URLError(.notConnectedToInternet))
        mockAPI.reposResult = .success([]) // will not matter; error short-circuits after await
        
        await viewModel.fetchDetails()
        
        if case .failed(let msg) = viewModel.userState {
            XCTAssertFalse(msg.isEmpty)
        } else {
            XCTFail("Expected failed user state.")
        }
        XCTAssertTrue(viewModel.repositories.isEmpty, "Repos should be cleared on failure.")
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    // MARK: - Failure Flow (repo fetch fails)
    func test_fetchDetails_repoFailure_setsFailedState() async {
        let user = makeUser()
        mockAPI.userResult = .success(user)
        mockAPI.reposResult = .failure(URLError(.timedOut))
        
        await viewModel.fetchDetails()
        
        if case .failed = viewModel.userState {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failed user state after repo error.")
        }
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set when repo fetch fails.")
        XCTAssertTrue(viewModel.repositories.isEmpty, "Repos should be empty if repo fetch fails.")
    }
    
    // MARK: - Duplicate Call Suppression
    func test_fetchDetails_ignoresDuplicateCallWhileLoading() async {
        mockAPI.userResult = .success(makeUser())
        mockAPI.reposResult = .success([])
        
        // Kick off two calls nearly simultaneously
        async let first: () = viewModel.fetchDetails()
        async let second: () = viewModel.fetchDetails() // should return immediately due to .loading guard
        _ = await (first, second)
        
        // Only one underlying fetch per endpoint should have happened
        XCTAssertEqual(mockAPI.userCallCount, 1)
        XCTAssertEqual(mockAPI.reposCallCount, 1)
    }
    
    // MARK: - Retry After Failure
    func test_fetchDetails_afterFailure_recoversOnSuccess() async {
        // 1. Fail first
        mockAPI.userResult = .failure(URLError(.notConnectedToInternet))
        mockAPI.reposResult = .failure(URLError(.cannotConnectToHost))
        await viewModel.fetchDetails()
        guard case .failed = viewModel.userState else {
            return XCTFail("Expected failed user state on first call.")
        }
        
        // 2. Succeed on retry
        let user = makeUser()
        let repos = [makeRepository()]
        mockAPI.userResult = .success(user)
        mockAPI.reposResult = .success(repos)
        await viewModel.fetchDetails()
        
        guard case .loaded(let loadedUser) = viewModel.userState else {
            return XCTFail("Expected loaded state on retry.")
        }
        XCTAssertEqual(loadedUser, user)
        XCTAssertEqual(viewModel.repositories.count, 1)
    }
    
    func test_errorMessageClearedOnRetry() async {
        // Fail once
        mockAPI.userResult = .failure(URLError(.notConnectedToInternet))
        mockAPI.reposResult = .failure(URLError(.timedOut))
        await viewModel.fetchDetails()
        XCTAssertNotNil(viewModel.errorMessage)
        
        // Succeed next
        mockAPI.userResult = .success(makeUser())
        mockAPI.reposResult = .success([])
        await viewModel.fetchDetails()
        
        XCTAssertNil(viewModel.errorMessage, "Error should be cleared before retry load.")
    }
    
    // MARK: - hasNoRepositories State
    func test_hasNoRepositories_togglesCorrectly() async {
        // 1. Initial state
        XCTAssertTrue(viewModel.hasNoRepositories)
        
        // 2. Success with empty repos
        mockAPI.userResult = .success(makeUser())
        mockAPI.reposResult = .success([])
        await viewModel.fetchDetails()
        XCTAssertTrue(viewModel.hasNoRepositories, "Expected true for empty repos.")
        
        // 3. Success with non-empty repos
        mockAPI.userResult = .success(makeUser())
        mockAPI.reposResult = .success([makeRepository()])
        await viewModel.fetchDetails()
        XCTAssertFalse(viewModel.hasNoRepositories, "Expected false for non-empty repos.")
        
        // 4. Failure resets to empty repos
        mockAPI.userResult = .failure(URLError(.notConnectedToInternet))
        mockAPI.reposResult = .failure(URLError(.timedOut))
        await viewModel.fetchDetails()
        XCTAssertTrue(viewModel.hasNoRepositories, "Expected true after failure resets repos.")
    }
    
    // MARK: - Repository Replacement Policy
    func test_repositories_areReplacedOnEachSuccessLoad() async {
        let user = makeUser()
        
        // First load: Repo1
        mockAPI.userResult = .success(user)
        mockAPI.reposResult = .success([makeRepository(name: "Repo1")])
        await viewModel.fetchDetails()
        XCTAssertEqual(viewModel.repositories.map(\.name), ["Repo1"])
        
        // Second load: Repo2 replaces Repo1
        mockAPI.userResult = .success(user)
        mockAPI.reposResult = .success([makeRepository(name: "Repo2")])
        await viewModel.fetchDetails()
        XCTAssertEqual(viewModel.repositories.map(\.name), ["Repo2"], "Repositories should be replaced, not appended.")
    }
    
    // MARK: - Slow / Concurrency
    func test_fetchDetails_secondCallDuringSlowLoad_isIgnored() async {
        // Slow responses so we overlap
        mockAPI.delayNanoseconds = 200_000_000 // 0.2s
        mockAPI.userResult = .success(makeUser())
        mockAPI.reposResult = .success([])
        
        // Kick off first load (slow)
        let first = Task { await viewModel.fetchDetails() }
        
        // Immediately issue a second load (should hit the guard and return)
        await viewModel.fetchDetails()
        
        // Finish first
        await first.value
        
        XCTAssertEqual(mockAPI.userCallCount, 1, "Second call should have been ignored while loading.")
        XCTAssertEqual(mockAPI.reposCallCount, 1, "Second call should have been ignored while loading.")
    }
}
