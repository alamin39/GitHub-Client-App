//
//  UserDetailView.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/18.
//

import SwiftUI

/// Displays a GitHub user's profile details and repositories.
/// Loads data via `UserDetailViewModel`, shows loading / error / success states.
struct UserDetailView: View {
    // Owns the lifecycle of the view model (created in init).
    @StateObject private var viewModel: UserDetailViewModel
    
    // Username whose details will be fetched from the API.
    let username: String
    
    // Custom init needed so we can pass username into the view model.
    init(username: String) {
        self.username = username
        _viewModel = StateObject(wrappedValue: UserDetailViewModel(username: username))
    }
    
    var body: some View {
        ScrollView {
            content  // Rendered based on LoadableState
        }
        // Initial load when the view appears.
        .task {
            await viewModel.fetchDetails()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Content State Switch
    @ViewBuilder
    private var content: some View {
        switch viewModel.userState {
        case .idle, .loading:
            // Loading indicator while fetching profile + repos.
            ProgressView("Loading details...")
                .frame(maxWidth: .infinity, minHeight: 200)
            
        case .failed(let message):
            // Show error + retry action.
            ErrorView(errorMessage: message) {
                await viewModel.fetchDetails()
            }
            
        case .loaded(let user):
            // Success: show profile header + repositories section.
            VStack(spacing: 16) {
                UserProfileHeaderView(user: user, username: username)
                headerTitleView
                
                if viewModel.hasNoRepositories {
                    noRepositoriesView
                } else {
                    repositoryView
                }
            }
        }
    }
    
    // MARK: - Repositories Section Header
    private var headerTitleView: some View {
        HStack {
            Text("Repositories")
                .font(.title).bold()
            Spacer()
        }
        .padding(.leading)
    }
    
    // MARK: - Repository List
    private var repositoryView: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.repositories) { repo in
                // Tapping opens a WebView showing the repo page.
                NavigationLink(destination: RepositoryWebView(url: repo.htmlUrl)) {
                    RepositoryRowView(repository: repo)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Empty State
    private var noRepositoriesView: some View {
        Text("'\(username)' has no repositories!")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(.secondary)
            .padding()
    }
}

#Preview {
    UserDetailView(username: "alamin39")
}
