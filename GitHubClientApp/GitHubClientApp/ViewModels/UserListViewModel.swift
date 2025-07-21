//
//  UserListViewModel.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import SwiftUI

/// ViewModel driving `UserListView`.
///
/// Responsibilities:
/// - Fetch a list of GitHub users.
/// - Expose a `LoadableState` so the View can switch between loading, error, and data UI.
/// - Provide a convenience `users` array for cases where the caller only cares about loaded data.
/// - Prevent redundant network requests while one is in-flight.
/// - Surface user-friendly error messages via `BaseViewModel.handleError(_:)`.
@MainActor
final class UserListViewModel: BaseViewModel {
    /// Current lifecycle state for the users payload.
    @Published var usersState: LoadableState<[User]> = .idle
    
    private let apiClient: UserFetching
    
    /// Dependency injection for testability
    init(apiClient: UserFetching = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// Convenience accessor for Views that just want `[User]` when loaded.
    var users: [User] {
        if case .loaded(let data) = usersState { return data }
        return []
    }
    
    /// Public entry point to load users.
    /// Safe to call from multiple places (e.g., `.task`, `.refreshable`).
    /// If a load is currently in-flight, the call is ignored to avoid duplicate network traffic.
    func fetchUsers() async {
        if case .loading = usersState {
            return   // Already loading; ignore redundant call
        }
        usersState = .loading
        await loadUsers()
    }
    
    /// Internal loader that performs the async call and updates state accordingly.
    private func loadUsers() async {
        clearErrorMessage() // reset any old error before new attempt
        do {
            let fetched: [User] = try await apiClient.fetchUsers()
            usersState = .loaded(fetched)
        } catch {
            handleError(error) // Map error to user-friendly string (fills `errorMessage`)
            usersState = .failed(errorMessage ?? "Unexpected error") // Move to failed state
        }
    }
}
