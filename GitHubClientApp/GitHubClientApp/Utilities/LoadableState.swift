//
//  LoadableState.swift
//  GitHubClientApp
//
//  Created by Al-Amin on 2025/07/20.
//

import Foundation

/// A simple load lifecycle container used throughout the app.
/// `.idle`    → nothing has started yet
/// `.loading` → in-flight network call
/// `.failed`  → user-displayable error message
/// `.loaded`  → data successfully loaded
enum LoadableState<Data: Equatable>: Equatable {
    case idle
    case loading
    case failed(String)
    case loaded(Data)
}
