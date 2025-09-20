//
//  HybridAppsView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 20.09.25.
//

import SwiftUI

public struct HybridAppsView: View {
    @StateObject private var searchManager = AppSearchManager()
    @State private var featuredApps: [Result] = []
    @State private var developerApps: [Result] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var developerName: String = ""
    @State private var loadingProgress: Double = 0.0
    
    let featuredAppIds: [Int]
    let currentAppId: Int
    let maxAdditional: Int
    let showTitle: Bool
    let cardStyle: MoPromoteKit.CardStyle
    let showSectionHeaders: Bool
    let featuredCardStyle: MoPromoteKit.CardStyle
    
    // MARK: - Initializers
    
    public init(
        featuredAppIds: [Int],
        currentAppId: Int,
        maxAdditional: Int = 5,
        showTitle: Bool = true,
        cardStyle: MoPromoteKit.CardStyle = .regular,
        showSectionHeaders: Bool = true,
        featuredCardStyle: MoPromoteKit.CardStyle = .featured
    ) {
        self.featuredAppIds = featuredAppIds
        self.currentAppId = currentAppId
        self.maxAdditional = maxAdditional
        self.showTitle = showTitle
        self.cardStyle = cardStyle
        self.showSectionHeaders = showSectionHeaders
        self.featuredCardStyle = featuredCardStyle
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if featuredApps.isEmpty && developerApps.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .task {
            await loadHybridApps()
        }
        .refreshable {
            await loadHybridApps()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Loading apps...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if loadingProgress > 0 {
                ProgressView(value: loadingProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(maxWidth: 200)
                
                Text("\(Int(loadingProgress * 100))% complete")
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
            
            Text("Failed to Load Apps")
                .font(.headline)
                .fontWeight(.medium)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await loadHybridApps()
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
            Image(systemName: "app.badge.checkmark")
                .font(.largeTitle)
                .foregroundColor(.gray)
                .imageScale(.large)
            
            Text("No Apps Available")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Unable to load featured apps or find additional apps from this developer.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if showTitle {
                mainTitleView
            }
            
            // Featured Apps Section
            if !featuredApps.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    if showSectionHeaders {
                        sectionHeader(
                            title: "Featured Apps",
                            subtitle: "\(featuredApps.count) handpicked app\(featuredApps.count == 1 ? "" : "s")",
                            icon: "star.fill",
                            color: .yellow
                        )
                    }
                    
                    LazyVStack(spacing: featuredCardStyle == .featured ? 16 : 12) {
                        ForEach(featuredApps) { app in
                            featuredAppCard(for: app)
                        }
                    }
                    .padding(.horizontal, showTitle ? 16 : 0)
                }
            }
            
            // Developer Apps Section
            if !developerApps.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    if showSectionHeaders {
                        sectionHeader(
                            title: "More from \(developerName.isEmpty ? "Developer" : developerName)",
                            subtitle: "\(developerApps.count) additional app\(developerApps.count == 1 ? "" : "s")",
                            icon: "person.crop.rectangle",
                            color: .blue
                        )
                    }
                    
                    LazyVStack(spacing: cardStyle == .regular ? 12 : 8) {
                        ForEach(developerApps) { app in
                            developerAppCard(for: app)
                        }
                    }
                    .padding(.horizontal, showTitle ? 16 : 0)
                }
            }
            
            // Summary Analytics
            if !featuredApps.isEmpty || !developerApps.isEmpty {
                summaryAnalyticsView
                    .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    private var mainTitleView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recommended Apps")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !developerName.isEmpty {
                    Text("Curated selection and more from \(developerName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                let totalApps = featuredApps.count + developerApps.count
                if totalApps > 0 {
                    Text("\(totalApps) app\(totalApps == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func sectionHeader(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.callout)
                .imageScale(.medium)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var summaryAnalyticsView: some View {
        let allApps = featuredApps + developerApps
        let avgRating = allApps.isEmpty ? 0.0 : allApps.reduce(0.0) { $0 + $1.displayRating } / Double(allApps.count)
        let totalReviews = allApps.reduce(0) { $0 + $1.displayRatingCount }
        let categories = Set(allApps.map { $0.displayGenre }).count
        
        HStack(spacing: 12) {
            summaryCard(
                title: "Combined Rating",
                value: String(format: "%.1f", avgRating),
                icon: "star.fill",
                color: .yellow
            )
            
            summaryCard(
                title: "Total Reviews",
                value: totalReviews.formatted(.number.notation(.compactName)),
                icon: "person.3.fill",
                color: .blue
            )
            
            summaryCard(
                title: "Categories",
                value: "\(categories)",
                icon: "folder.fill",
                color: .green
            )
        }
    }
    
    @ViewBuilder
    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption2)
                
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
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private func featuredAppCard(for app: Result) -> some View {
        switch featuredCardStyle {
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
    
    @ViewBuilder
    private func developerAppCard(for app: Result) -> some View {
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
    
    private func loadHybridApps() async {
        isLoading = true
        errorMessage = nil
        developerName = ""
        loadingProgress = 0.0
        
        do {
            // Step 1: Load featured apps
            await MainActor.run { loadingProgress = 0.1 }
            
            let featuredResults = try await searchManager.fetchSpecificApps(appIds: featuredAppIds)
            featuredApps = featuredResults.results
            
            await MainActor.run { loadingProgress = 0.4 }
            
            // Step 2: Get developer info
            let currentAppResults = try await getCurrentAppInfo()
            if let currentApp = currentAppResults.results.first {
                developerName = currentApp.artistName
            }
            
            await MainActor.run { loadingProgress = 0.6 }
            
            // Step 3: Load additional developer apps (excluding featured ones and current app)
            var excludeIds = featuredAppIds
            excludeIds.append(currentAppId)
            
            let developerResults = try await searchManager.fetchDeveloperApps(
                appId: currentAppId,
                excludeAppIds: excludeIds,
                includeCurrentApp: false
            )
            
            await MainActor.run { loadingProgress = 0.9 }
            
            developerApps = Array(developerResults.results.prefix(maxAdditional))
            
            await MainActor.run { loadingProgress = 1.0 }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
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

public extension HybridAppsView {
    /// Create a hybrid view for settings pages
    static func forSettings(
        featuredAppIds: [Int],
        currentAppId: Int,
        maxAdditional: Int = 3
    ) -> HybridAppsView {
        HybridAppsView(
            featuredAppIds: featuredAppIds,
            currentAppId: currentAppId,
            maxAdditional: maxAdditional,
            showTitle: true,
            cardStyle: .compact,
            showSectionHeaders: true,
            featuredCardStyle: .featured
        )
    }
    
    /// Create a compact hybrid view
    static func compact(
        featuredAppIds: [Int],
        currentAppId: Int,
        maxAdditional: Int = 2
    ) -> HybridAppsView {
        HybridAppsView(
            featuredAppIds: featuredAppIds,
            currentAppId: currentAppId,
            maxAdditional: maxAdditional,
            showTitle: false,
            cardStyle: .compact,
            showSectionHeaders: false,
            featuredCardStyle: .compact
        )
    }
    
    /// Create a full-screen hybrid view
    static func fullScreen(
        featuredAppIds: [Int],
        currentAppId: Int,
        maxAdditional: Int = 8
    ) -> HybridAppsView {
        HybridAppsView(
            featuredAppIds: featuredAppIds,
            currentAppId: currentAppId,
            maxAdditional: maxAdditional,
            showTitle: true,
            cardStyle: .regular,
            showSectionHeaders: true,
            featuredCardStyle: .featured
        )
    }
    
    /// Create a featured-only view (no additional developer apps)
    static func featuredOnly(
        featuredAppIds: [Int],
        currentAppId: Int
    ) -> HybridAppsView {
        HybridAppsView(
            featuredAppIds: featuredAppIds,
            currentAppId: currentAppId,
            maxAdditional: 0,
            showTitle: true,
            cardStyle: .regular,
            showSectionHeaders: false,
            featuredCardStyle: .featured
        )
    }
}

// MARK: - Preview Support

#if DEBUG
#Preview("Hybrid Settings View") {
    ScrollView {
        HybridAppsView.forSettings(
            featuredAppIds: [123456789, 987654321],
            currentAppId: 1577859348,
            maxAdditional: 3
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Hybrid View") {
    ScrollView {
        HybridAppsView.compact(
            featuredAppIds: [123456789, 987654321],
            currentAppId: 1577859348,
            maxAdditional: 2
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Featured Only View") {
    ScrollView {
        HybridAppsView.featuredOnly(
            featuredAppIds: [123456789, 987654321, 456789123],
            currentAppId: 1577859348
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Full Screen Hybrid") {
    NavigationView {
        ScrollView {
            HybridAppsView.fullScreen(
                featuredAppIds: [123456789, 987654321],
                currentAppId: 1577859348,
                maxAdditional: 5
            )
            .padding(.top)
        }
        .navigationTitle("Recommended Apps")
        .navigationBarTitleDisplayMode(.large)
    }
}
#endif
