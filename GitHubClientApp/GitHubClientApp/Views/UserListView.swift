//
//  UserListView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import SwiftUI

/// A view that displays a list of GitHub users.
///
/// - Uses `UserListViewModel` to handle data fetching and state management.
/// - Automatically fetches users when the view appears.
/// - Displays loading, error, or user list states accordingly.
struct UserListView: View {
    /// The ViewModel that manages user data and network calls.
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("GitHub Users")
                .task {
                    // Automatically fetch users when the view appears.
                    await viewModel.fetchUsers()
                }
        }
    }
    
    // MARK: - Main Content
    
    /// Determines which content to display based on the current `usersState`.
    @ViewBuilder
    private var content: some View {
        switch viewModel.usersState {
        case .idle, .loading:
            // Show a loading spinner while data is being fetched.
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, minHeight: 200)
            
        case .failed(let message):
            // Show an error view when the fetch fails.
            // Includes a retry button that triggers another `fetchUsers()` call.
            ErrorView(errorMessage: message) {
                await viewModel.fetchUsers()
            }
            
        case .loaded:
            // Display the list of users when data has successfully loaded.
            userList
        }
    }
    
    // MARK: - User List View
    
    /// Displays a list of users. Each row navigates to `UserDetailView` for the selected user.
    private var userList: some View {
        List(viewModel.users) { user in
            NavigationLink(destination: UserDetailView(username: user.login)) {
                UserRowView(user: user) // A row displaying basic user info.
            }
        }
        // Adds pull-to-refresh functionality to reload the user list.
        .refreshable {
            await viewModel.fetchUsers()
        }
    }
}

#Preview {
    UserListView()
}
