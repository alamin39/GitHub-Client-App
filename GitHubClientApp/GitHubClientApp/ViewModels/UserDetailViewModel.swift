//
//  UserDetailViewModel.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import SwiftUI

/// ViewModel driving `UserDetailView`.
///
/// Responsibilities:
/// - Fetch a specific GitHub user's profile **and** repositories.
/// - Expose a `LoadableState<User>` so the view can render loading / error / success UI.
/// - Maintain a filtered + sorted `[Repository]` list (non‑forks, most starred first).
/// - Prevent redundant network requests while one is in-flight.
/// - Surface user-friendly error messages via `BaseViewModel.handleError(_:)`.
@MainActor
final class UserDetailViewModel: BaseViewModel {
    /// State machine for the *user profile* payload.
    @Published private(set) var userState: LoadableState<User> = .idle
    
    /// Filtered + sorted repositories for display (non‑forks, sorted by stars).
    @Published private(set) var repositories: [Repository] = []
    
    /// The GitHub username whose details are fetched.
    private let username: String
    
    /// Injected API dependency (default: live `APIClient.shared`). Inject mocks in tests.
    private let apiClient: UserDetailFetching
    
    /// Convenience: true when no repositories are available (after load or on failure).
    var hasNoRepositories: Bool { repositories.isEmpty }
    
    /// Designated initializer with dependency injection for testability.
    init(username: String, apiClient: UserDetailFetching = APIClient.shared) {
        self.username = username
        self.apiClient = apiClient
    }
    
    /// Public entry point to load user details + repos.
    ///
    /// Safe to call from multiple places (`.task`, retry buttons).
    /// A `.loading` guard prevents overlapping network calls and wasted bandwidth.
    func fetchDetails() async {
        if case .loading = userState {
            return   // Already loading; ignore redundant call
        }
        userState = .loading
        await loadDetails()
    }
    
    /// Performs the actual async fetch work.
    ///
    /// - Clears any old error state.
    /// - Starts **two concurrent requests** (`async let`) for user + repos.
    /// - Filters out forked repos and sorts remaining repos by descending star count.
    /// - On success: updates `userState` and `repositories`.
    /// - On failure: maps error to user-friendly text via `handleError(_:)`,
    ///   moves `userState` to `.failed`, and clears repos for a predictable UI.
    private func loadDetails() async {
        clearErrorMessage() // Reset prior error before a new attempt.
        do {
            // Fire user + repo requests in parallel.
            async let userDetails: User = apiClient.fetchUserDetail(username: username)
            async let repos: [Repository] = apiClient.fetchUserRepositories(username: username)
            
            // Await results.
            let fetchedUser = try await userDetails
            let fetchedRepos = try await repos
                .filter { !$0.fork }                                // Ignore forked repos
                .sorted { $0.stargazersCount > $1.stargazersCount } // Most starred first
            
            // Success.
            userState = .loaded(fetchedUser)
            repositories = fetchedRepos
            
        } catch {
            // Map error to user-friendly string (fills `errorMessage`)
            handleError(error)
            
            // Move to failed state
            userState = .failed(errorMessage ?? "Unexpected error")
            
            // Clear repos so UI doesn't show stale data after a failed refresh.
            repositories = []
        }
    }
}
