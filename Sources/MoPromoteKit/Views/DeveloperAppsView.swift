//
//  DeveloperAppsView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import SwiftUI

public struct DeveloperAppsView: View {
    @StateObject private var searchManager = AppSearchManager()
    @State private var developerApps: [Result] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var developerName: String = ""
    @State private var totalGlobalRatings: Int = 0
    
    let currentAppId: Int
    let maxApps: Int
    let showTitle: Bool
    let cardStyle: CardStyle
    
    public enum CardStyle {
        case regular
        case compact
    }
    
    // MARK: - Initializers
    
    public init(
        currentAppId: Int,
        maxApps: Int = 10,
        showTitle: Bool = true,
        cardStyle: CardStyle = .regular
    ) {
        self.currentAppId = currentAppId
        self.maxApps = maxApps
        self.showTitle = showTitle
        self.cardStyle = cardStyle
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if developerApps.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .task {
            await loadDeveloperApps()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading global ratings...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await loadDeveloperApps()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "app.badge")
                .font(.title2)
                .foregroundColor(.gray)
            
            if developerName.isEmpty {
                Text("No other apps found from this developer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 4) {
                    Text("No other apps found")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text("from \(developerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                titleView
            }
            
            LazyVStack(spacing: cardStyle == .regular ? 12 : 8) {
                ForEach(developerApps) { app in
                    appCard(for: app)
                        .padding(.horizontal, showTitle ? 0 : 16)
                }
            }
            .padding(.horizontal, showTitle ? 16 : 0)
        }
    }
    
    @ViewBuilder
    private var titleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("More Apps")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !developerName.isEmpty {
                    Text("from \(developerName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if developerApps.count > 0 {
                Text("\(developerApps.count) app\(developerApps.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func appCard(for app: Result) -> some View {
        switch cardStyle {
        case .regular:
            DeveloperAppCard(app: app) {
                openAppInAppStore(app: app)
            }
        case .compact:
            DeveloperAppCompactCard(app: app) {
                openAppInAppStore(app: app)
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadDeveloperApps() async {
        isLoading = true
        errorMessage = nil
        developerName = ""
        totalGlobalRatings = 0
        
        do {
            let results = try await searchManager.fetchDeveloperApps(appId: currentAppId)
            
            // Get developer name from current app lookup
            let currentAppResults = try await getCurrentAppInfo()
            if let currentApp = currentAppResults.results.first {
                developerName = currentApp.artistName
            }
            
            developerApps = Array(results.results.prefix(maxApps))
            
            // Calculate total global ratings
            totalGlobalRatings = developerApps.reduce(0) { total, app in
                total + (app.userRatingCount ?? 0)
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load developer apps: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func getCurrentAppInfo() async throws -> SearchResults {
        let urlString = "https://itunes.apple.com/\(searchManager.countryCode)/lookup?id=\(currentAppId)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SearchResults.self, from: data)
    }
    
    private func openAppInAppStore(app: Result) {
        guard let url = app.appStoreURL else { return }
        
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}

// MARK: - Convenience Initializers

public extension DeveloperAppsView {
    /// Create a view for settings page
    static func forSettings(currentAppId: Int) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            maxApps: 6,
            showTitle: true,
            cardStyle: .regular
        )
    }
    
    /// Create a compact view for smaller spaces
    static func compact(currentAppId: Int, maxApps: Int = 5) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            maxApps: maxApps,
            showTitle: false,
            cardStyle: .compact
        )
    }
    
    /// Create a view for full screen presentation
    static func fullScreen(currentAppId: Int) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            maxApps: 20,
            showTitle: true,
            cardStyle: .regular
        )
    }
}

// MARK: - Preview Support

#if DEBUG
#Preview("Regular View") {
    ScrollView {
        DeveloperAppsView.forSettings(currentAppId: 1577859348)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact View") {
    ScrollView {
        DeveloperAppsView.compact(currentAppId: 1577859348, maxApps: 3)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Full Screen") {
    NavigationView {
        ScrollView {
            DeveloperAppsView.fullScreen(currentAppId: 1577859348)
                .padding(.top)
        }
        .navigationTitle("More Apps")
        .navigationBarTitleDisplayMode(.large)
    }
}
#endif
