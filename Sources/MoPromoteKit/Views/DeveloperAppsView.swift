//
//  DeveloperAppsView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import SwiftUI

public struct DeveloperAppsView: View {
    @StateObject private var searchManager = AppSearchManager()
    let developerProfile: DeveloperProfile
    @State private var developerApps: [AppResult] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var developerName: String = ""
    @State private var totalGlobalRatings: Int = 0
    @State private var loadingProgress: Double = 0.0
    
    /// Internal identifier for dual App ID / Bundle ID support
    enum AppIdentifier {
        case appId(Int)
        case bundleId(String)
    }
    
    let appIdentifier: AppIdentifier
    let excludeAppIds: [Int]
    let excludeBundleIds: [String]
    let maxApps: Int
    let showTitle: Bool
    let cardStyle: CardStyle
    let includeCurrentApp: Bool
    let sortingOrder: SortingOrder
    let showAnalytics: Bool
    
    public enum CardStyle {
        case regular
        case compact
        case featured
    }
    
    public enum SortingOrder {
        case alphabetical
        case rating
        case releaseDate
        case downloads
        case random
    }
    
    // MARK: - Initializers (App ID)
    
    public init(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 10,
        showTitle: Bool = true,
        cardStyle: CardStyle = .regular,
        includeCurrentApp: Bool = false,
        sortingOrder: SortingOrder = .alphabetical,
        showAnalytics: Bool = false,
        developerProfile: DeveloperProfile = .none
    ) {
        self.appIdentifier = .appId(currentAppId)
        self.excludeAppIds = excludeAppIds
        self.excludeBundleIds = []
        self.maxApps = maxApps
        self.showTitle = showTitle
        self.cardStyle = cardStyle
        self.includeCurrentApp = includeCurrentApp
        self.sortingOrder = sortingOrder
        self.showAnalytics = showAnalytics
        self.developerProfile = developerProfile
    }
    
    // MARK: - Initializers (Bundle ID)
    
    public init(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 10,
        showTitle: Bool = true,
        cardStyle: CardStyle = .regular,
        includeCurrentApp: Bool = false,
        sortingOrder: SortingOrder = .alphabetical,
        showAnalytics: Bool = false,
        developerProfile: DeveloperProfile = .none
    ) {
        self.appIdentifier = .bundleId(currentBundleId)
        self.excludeAppIds = []
        self.excludeBundleIds = excludeBundleIds
        self.maxApps = maxApps
        self.showTitle = showTitle
        self.cardStyle = cardStyle
        self.includeCurrentApp = includeCurrentApp
        self.sortingOrder = sortingOrder
        self.showAnalytics = showAnalytics
        self.developerProfile = developerProfile
    }
    
    // MARK: - Body
    
    #if canImport(UIKit)
    @State private var selectedApp: AppResult?
    #endif
    
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
        #if canImport(UIKit)
        .appStoreSheet(selectedApp: $selectedApp)
        #endif
        .task {
            await loadDeveloperApps()
        }
        .refreshable {
            await loadDeveloperApps()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text(L10n.loadingDeveloperApps)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if loadingProgress > 0 {
                ProgressView(value: loadingProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(maxWidth: 200)
                
                Text(L10n.loadingPercentComplete(Int(loadingProgress * 100)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
                .imageScale(.large)
            
            Text(L10n.errorFailedToLoadApps)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(L10n.errorTryAgain) {
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
        VStack(spacing: 12) {
            Image(systemName: "app.badge")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .imageScale(.large)
            
            if developerName.isEmpty {
                Text(L10n.emptyNoOtherAppsFound)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(L10n.emptyNoOtherAppsDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(L10n.emptyNoOtherAppsFound)
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(spacing: 4) {
                    Text(L10n.emptyNoAdditionalAppsFrom)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(developerName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
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
            
            if showAnalytics && !developerApps.isEmpty {
                analyticsView
            }
            
            LazyVStack(spacing: cardStyle == .regular ? 12 : cardStyle == .featured ? 16 : 8) {
                ForEach(sortedApps) { app in
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
            HStack(spacing: 12) {
                // Developer profile image
                if developerProfile.showImage {
                    DeveloperProfileImageView(profile: developerProfile)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.titleMoreApps)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !developerName.isEmpty {
                        Text(L10n.fromDeveloper(developerName))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if developerApps.count > 0 {
                    Text(L10n.appCount(developerApps.count))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                
                if totalGlobalRatings > 0 {
                    Text(L10n.reviews(totalGlobalRatings.formatted(.number.notation(.compactName))))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    
    @ViewBuilder
    private var analyticsView: some View {
        HStack(spacing: 16) {
            analyticsCard(
                title: L10n.analyticsAvgRating,
                value: String(format: "%.1f", averageRating),
                icon: "star.fill",
                color: .yellow
            )
            
            analyticsCard(
                title: L10n.analyticsTotalReviews,
                value: totalGlobalRatings.formatted(.number.notation(.compactName)),
                icon: "person.3.fill",
                color: .blue
            )
            
            analyticsCard(
                title: L10n.analyticsCategories,
                value: "\(uniqueCategories.count)",
                icon: "folder.fill",
                color: .green
            )
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func analyticsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var sortedApps: [AppResult] {
        switch sortingOrder {
        case .alphabetical:
            return developerApps.sorted { $0.trackName < $1.trackName }
        case .rating:
            return developerApps.sorted { $0.displayRating > $1.displayRating }
        case .releaseDate:
            return developerApps.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        case .downloads:
            return developerApps.sorted { $0.displayRatingCount > $1.displayRatingCount }
        case .random:
            return developerApps.shuffled()
        }
    }
    
    private var averageRating: Double {
        guard !developerApps.isEmpty else { return 0.0 }
        let validRatings = developerApps.compactMap { $0.averageUserRating }
        guard !validRatings.isEmpty else { return 0.0 }
        return validRatings.reduce(0, +) / Double(validRatings.count)
    }
    
    private var uniqueCategories: Set<String> {
        return Set(developerApps.map { $0.displayGenre })
    }
    
    @ViewBuilder
    private func appCard(for app: AppResult) -> some View {
        switch cardStyle {
        case .regular:
            DeveloperAppCard(app: app) {
                openAppInAppStore(app: app)
            }
        case .compact:
            DeveloperAppCompactCard(app: app) {
                openAppInAppStore(app: app)
            }
        case .featured:
            FeaturedAppCard(app: app) {
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
        loadingProgress = 0.0
        
        // Clear cache for fresh data
        searchManager.clearCache()
        
        do {
            // Update progress
            await MainActor.run {
                loadingProgress = 0.2
            }
            
            let results: SearchResults
            
            switch appIdentifier {
            case .appId(let currentAppId):
                results = try await searchManager.fetchDeveloperApps(
                    appId: currentAppId,
                    excludeAppIds: excludeAppIds,
                    includeCurrentApp: includeCurrentApp
                )
                
                // Get developer name from current app lookup
                let urlString = "https://itunes.apple.com/\(searchManager.countryCode)/lookup?id=\(currentAppId)"
                if let url = URL(string: urlString) {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let currentAppResults = try JSONDecoder().decode(SearchResults.self, from: data)
                    if let currentApp = currentAppResults.results.first {
                        developerName = currentApp.artistName
                    }
                }
                
            case .bundleId(let currentBundleId):
                results = try await searchManager.fetchDeveloperApps(
                    bundleId: currentBundleId,
                    excludeBundleIds: excludeBundleIds,
                    includeCurrentApp: includeCurrentApp
                )
                
                // Get developer name from bundle ID lookup
                let currentAppResults = try await searchManager.fetchAppDetails(bundleId: currentBundleId)
                if let currentApp = currentAppResults.results.first {
                    developerName = currentApp.artistName
                }
            }
            
            // Update progress
            await MainActor.run {
                loadingProgress = 0.8
            }
            
            developerApps = Array(results.results.prefix(maxApps))
            
            // Calculate total global ratings
            totalGlobalRatings = developerApps.reduce(0) { total, app in
                total + (app.userRatingCount ?? 0)
            }
            
            // Final progress update
            await MainActor.run {
                loadingProgress = 1.0
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load developer apps: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func openAppInAppStore(app: AppResult) {
        #if canImport(UIKit)
        selectedApp = app
        #endif
    }
}

// MARK: - Convenience Initializers

public extension DeveloperAppsView {
    // MARK: - Convenience Initializers (App ID)
    
    /// Create a view for settings page using App Store ID
    static func forSettings(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: 6,
            showTitle: true,
            cardStyle: .regular,
            showAnalytics: true,
            developerProfile: developerProfile
        )
    }
    
    /// Create a compact view using App Store ID
    static func compact(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 5,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showTitle: false,
            cardStyle: .compact,
            developerProfile: developerProfile
        )
    }
    
    /// Create a full screen view using App Store ID
    static func fullScreen(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        sortingOrder: SortingOrder = .rating,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: 20,
            showTitle: true,
            cardStyle: .regular,
            sortingOrder: sortingOrder,
            showAnalytics: true,
            developerProfile: developerProfile
        )
    }
    
    /// Create a featured apps view using App Store ID
    static func featured(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 4,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showTitle: true,
            cardStyle: .featured,
            sortingOrder: .rating,
            showAnalytics: false,
            developerProfile: developerProfile
        )
    }
    
    /// Create a random discovery view using App Store ID
    static func discovery(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 3
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showTitle: true,
            cardStyle: .compact,
            sortingOrder: .random,
            showAnalytics: false
        )
    }
    
    // MARK: - Convenience Initializers (Bundle ID)
    
    /// Create a view for settings page using Bundle ID
    static func forSettings(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: 6,
            showTitle: true,
            cardStyle: .regular,
            showAnalytics: true,
            developerProfile: developerProfile
        )
    }
    
    /// Create a compact view using Bundle ID
    static func compact(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 5,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showTitle: false,
            cardStyle: .compact,
            developerProfile: developerProfile
        )
    }
    
    /// Create a full screen view using Bundle ID
    static func fullScreen(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        sortingOrder: SortingOrder = .rating,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: 20,
            showTitle: true,
            cardStyle: .regular,
            sortingOrder: sortingOrder,
            showAnalytics: true,
            developerProfile: developerProfile
        )
    }
    
    /// Create a featured apps view using Bundle ID
    static func featured(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 4,
        developerProfile: DeveloperProfile = .none
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showTitle: true,
            cardStyle: .featured,
            sortingOrder: .rating,
            showAnalytics: false,
            developerProfile: developerProfile
        )
    }
    
    /// Create a random discovery view using Bundle ID
    static func discovery(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 3
    ) -> DeveloperAppsView {
        DeveloperAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showTitle: true,
            cardStyle: .compact,
            sortingOrder: .random,
            showAnalytics: false
        )
    }
}

// MARK: - Featured App Card
public struct FeaturedAppCard: View {
    let app: AppResult
    let onDownloadTapped: () -> Void
    
    public init(app: AppResult, onDownloadTapped: @escaping () -> Void) {
        self.app = app
        self.onDownloadTapped = onDownloadTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Large App Icon
                AsyncImage(url: URL(string: app.artworkUrl512)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "app.fill")
                                .foregroundColor(.gray)
                                .font(.title)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.secondary, lineWidth: 0.5)
                )
                
                // App Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(app.trackName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    // Enhanced Rating Section
                    if app.hasRating {
                        HStack(spacing: 6) {
                            HStack(spacing: 2) {
                                ForEach(0..<5, id: \.self) { index in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(index < app.starRating ? .yellow : .gray.opacity(0.3))
                                        .font(.subheadline)
                                }
                            }
                            
                            Text(String(format: "%.1f", app.displayRating))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("(\(app.displayRatingCount.formatted(.number.notation(.compactName))))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Category and File Size
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: CategoryIcons.iconForCategory(app.displayGenre))
                                .font(.caption)
                            Text(app.displayGenre)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(app.displayFileSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Description Preview
            if !app.shortDescription.isEmpty {
                Text(app.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.horizontal, 4)
            }
            
            // Action Button
            Button(action: onDownloadTapped) {
                Text(app.displayPrice)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Preview Support
#if DEBUG
#Preview("Regular View with Picture") {
    ScrollView {
        DeveloperAppsView.forSettings(currentAppId: 1577859348, developerProfile: .url("https://mkhasson97.com/assets/Profile.png"))
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Featured View") {
    ScrollView {
        DeveloperAppsView.featured(currentAppId: 1577859348, maxApps: 3)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Discovery View") {
    ScrollView {
        DeveloperAppsView.discovery(currentAppId: 1577859348, maxApps: 10)
            .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}
#endif
