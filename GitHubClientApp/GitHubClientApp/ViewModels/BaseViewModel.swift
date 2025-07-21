//
//  BaseViewModel.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/19.
//

import SwiftUI

/// Base class that centralizes error-to-string mapping so UI can display
/// consistent, user-friendly messages.
@MainActor
class BaseViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.errorDescription
        } else if let urlError = error as? URLError {
            errorMessage = APIError.networkError(urlError).errorDescription
        } else {
            errorMessage = APIError.unknown(error).errorDescription
        }
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
}
