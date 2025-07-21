
# GitHub Client App

A SwiftUI-based iOS app that displays GitHub users and their repositories using the GitHub REST API.  
The app follows the **MVVM (Model-View-ViewModel)** architecture with async/await for modern concurrency, and includes proper error handling, loading states, clean UI components, and unit tests.

---

## Requirements

### User List Screen
* Display a list of GitHub users.
* Each row must contain:
    * Profile image (avatar)
    * Username
* When a row is selected, navigate to the User Repository Screen.
  
### User Repository Screen (Details)
* Display user details at the top:
    * Profile image
    * Username
    * Full name
    * Followers count
    * Following count
* Below that, display a list of the user’s repositories (excluding forked repositories), with:
    * Repository name
    * Programming language
    * Star count
    * Description
* When a repository row is tapped, open the repository’s URL in a WebView.


## ✨ Features

- **User List**: Fetches and displays a list of GitHub users.
- **User Detail**: Shows detailed user information (Avatar, Full name, Username, Followers, Following, etc.).
- **Repositories**: Lists repositories of a selected user, sorted by star count.
- **Error Handling**: Friendly error messages with retry options.
- **Pull-to-Refresh**: Refresh user list using `.refreshable`.
- **Swift Concurrency**: Uses `async/await` for network calls.
- **Reusable UI Components**: Components like `ErrorView`, `UserRowView`, `RepositoryRowView`.
- **Clean Architecture**: Separation of concerns with protocols for `UserFetching` and `UserDetailFetching`.
- **Unit Test**: Includes unit tests for ViewModels using mock APIs.
  
---

## 🛠 Tech Stack

- **SwiftUI**: Declarative UI framework for iOS.
- **Combine / @StateObject**: Data binding between ViewModels and Views.
- **URLSession**: Native networking with `async/await`.
- **JSONDecoder**: For decoding GitHub API responses with snake_case to camelCase conversion.
- **MVVM Pattern**: Ensures clean separation between UI and business logic.
- **Unit Test**: Provides testability through `XCTest`.
  
---

### ⚠️ Add a GitHub Personal Access Token in `AppConstants.swift` to avoid rate-limiting for unauthenticated requests.

