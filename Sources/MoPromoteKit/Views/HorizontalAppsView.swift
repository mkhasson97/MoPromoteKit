//
//  HorizontalAppsView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 12.11.25.
//

import SwiftUI

public struct HorizontalAppsView: View {
    @StateObject private var searchManager = AppSearchManager()
    @State private var apps: [AppResult] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var developerName: String = ""
    
    /// Internal identifier for dual App ID / Bundle ID support
    enum AppIdentifier {
        case appId(Int)
        case bundleId(String)
    }
    
    let appIdentifier: AppIdentifier
    let excludeAppIds: [Int]
    let excludeBundleIds: [String]
    let maxApps: Int
    let showDeveloperName: Bool
    let iconSizeOption: IconSize
    let spacing: CGFloat
    
    // Computed property to get the actual size value
    private var iconSize: CGFloat {
        iconSizeOption.value
    }
    
    // MARK: - Initializers (App ID)
    
    public init(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 6,
        showDeveloperName: Bool = true,
        iconSize: IconSize = .medium,
        spacing: CGFloat? = nil
    ) {
        self.appIdentifier = .appId(currentAppId)
        self.excludeAppIds = excludeAppIds
        self.excludeBundleIds = []
        self.maxApps = maxApps
        self.showDeveloperName = showDeveloperName
        self.iconSizeOption = iconSize
        self.spacing = spacing ?? iconSize.defaultSpacing
    }
    
    // MARK: - Initializers (Bundle ID)
    
    public init(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 6,
        showDeveloperName: Bool = true,
        iconSize: IconSize = .medium,
        spacing: CGFloat? = nil
    ) {
        self.appIdentifier = .bundleId(currentBundleId)
        self.excludeAppIds = []
        self.excludeBundleIds = excludeBundleIds
        self.maxApps = maxApps
        self.showDeveloperName = showDeveloperName
        self.iconSizeOption = iconSize
        self.spacing = spacing ?? iconSize.defaultSpacing
    }
    
    // MARK: - Icon Size Options
    
    public enum IconSize {
        case small
        case medium
        case large
        case custom(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .small:
                return 60
            case .medium:
                return 80
            case .large:
                return 100
            case .custom(let size):
                return size
            }
        }
        
        var defaultSpacing: CGFloat {
            switch self {
            case .small:
                return 12
            case .medium:
                return 16
            case .large:
                return 20
            case .custom(let size):
                return size * 0.2 // 20% of icon size
            }
        }
    }
    
    #if canImport(UIKit)
    @State private var selectedApp: AppResult?
    #endif
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(message: errorMessage)
            } else if apps.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        #if canImport(UIKit)
        .appStoreSheet(selectedApp: $selectedApp)
        #endif
        .task {
            await loadApps()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text(L10n.loadingApps)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title3)
                .foregroundColor(.orange)
            
            Text(L10n.errorFailedToLoad)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "app.badge")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text(L10n.emptyNoAppsFound)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
//    @ViewBuilder
//    private var contentView: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            if showDeveloperName && !developerName.isEmpty {
//                developerHeader
//            }
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: spacing) {
//                    ForEach(apps) { app in
//                        AppIconButton(app: app, iconSize: iconSize) {
//                            openAppInAppStore(app: app)
//                        }
//                    }
//                }
//                .padding(.horizontal, 16)
//            }
//        }
//    }
    
    @ViewBuilder
    private var contentView: some View {
        // horizontal inset you want (same value you used previously)
        let inset: CGFloat = 16

        VStack(alignment: .leading, spacing: 12) {
            if showDeveloperName && !developerName.isEmpty {
                developerHeader
            }

            Group {
                if #available(iOS 17, *) {
                    // iOS 17+ — use contentMargins (preferred)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            ForEach(apps) { app in
                                AppIconButton(app: app, iconSize: iconSize) {
                                    openAppInAppStore(app: app)
                                }
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .contentMargins(.horizontal, inset) // keeps viewport inset and clipped
                    .frame(height: iconSize + 8) // adjust if you add labels
                } else {
                    // Fallback for iOS 16 and earlier — mask + edge spacers
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            // leading spacer so content starts after the visual inset
                            Spacer().frame(width: inset)

                            ForEach(apps) { app in
                                AppIconButton(app: app, iconSize: iconSize) {
                                    openAppInAppStore(app: app)
                                }
                            }

                            // trailing spacer so content ends before the visual inset
                            Spacer().frame(width: inset)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    // Clip the visible area by masking the ScrollView to an inset rect.
                    // The mask reduces the visible area by `inset` on both sides.
                    .mask(
                        RoundedRectangle(cornerRadius: 0)
                            .padding(.horizontal, inset)
                    )
                    .frame(height: iconSize + 8)
                }
            } // Group
        } // VStack
    }

    
    @ViewBuilder
    private var developerHeader: some View {
        Text(developerName)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
    }
    
    // MARK: - Functions
    
    private func loadApps() async {
        isLoading = true
        errorMessage = nil
        developerName = ""
        
        searchManager.clearCache()
        
        do {
            let results: SearchResults
            
            switch appIdentifier {
            case .appId(let currentAppId):
                // Get current app info to retrieve developer name
                let urlString = "https://itunes.apple.com/\(searchManager.countryCode)/lookup?id=\(currentAppId)"
                if let url = URL(string: urlString) {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let currentAppResults = try JSONDecoder().decode(SearchResults.self, from: data)
                    if let currentApp = currentAppResults.results.first {
                        developerName = currentApp.artistName
                    }
                }
                
                // Fetch developer apps
                results = try await searchManager.fetchDeveloperApps(
                    appId: currentAppId,
                    excludeAppIds: excludeAppIds,
                    includeCurrentApp: false
                )
                
            case .bundleId(let currentBundleId):
                // Get current app info to retrieve developer name
                let currentAppResults = try await searchManager.fetchAppDetails(bundleId: currentBundleId)
                if let currentApp = currentAppResults.results.first {
                    developerName = currentApp.artistName
                }
                
                // Fetch developer apps
                results = try await searchManager.fetchDeveloperApps(
                    bundleId: currentBundleId,
                    excludeBundleIds: excludeBundleIds,
                    includeCurrentApp: false
                )
            }
            
            apps = Array(results.results.prefix(maxApps))
            isLoading = false
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func openAppInAppStore(app: AppResult) {
        #if canImport(UIKit)
        selectedApp = app
        #endif
    }
}

// MARK: - App Icon Button Component

private struct AppIconButton: View {
    let app: AppResult
    let iconSize: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: app.artworkUrl512)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: iconSize * 0.225) // 22.5% corner radius
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "app.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: iconSize * 0.35))
                        )
                }
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.225))
                .overlay(
                    RoundedRectangle(cornerRadius: iconSize * 0.225)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Convenience Initializers

public extension HorizontalAppsView {
    // MARK: - Convenience Initializers (App ID)
    
    /// Create a horizontal view for settings or home pages (medium size)
    static func forSettings(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 6
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .medium
        )
    }
    
    /// Create a compact horizontal view with small icons
    static func compact(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 8
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .small
        )
    }
    
    /// Create a large horizontal view with big icons
    static func large(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 5
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .large
        )
    }
    
    /// Create a horizontal view without developer name
    static func iconsOnly(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 6,
        iconSize: IconSize = .medium
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showDeveloperName: false,
            iconSize: iconSize
        )
    }
    
    /// Create a horizontal view with custom icon size
    static func custom(
        currentAppId: Int,
        excludeAppIds: [Int] = [],
        maxApps: Int = 6,
        iconSize: CGFloat,
        spacing: CGFloat? = nil,
        showDeveloperName: Bool = true
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: maxApps,
            showDeveloperName: showDeveloperName,
            iconSize: .custom(iconSize),
            spacing: spacing
        )
    }
    
    // MARK: - Convenience Initializers (Bundle ID)
    
    /// Create a horizontal view for settings using Bundle ID
    static func forSettings(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 6
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .medium
        )
    }
    
    /// Create a compact horizontal view using Bundle ID
    static func compact(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 8
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .small
        )
    }
    
    /// Create a large horizontal view using Bundle ID
    static func large(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 5
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showDeveloperName: true,
            iconSize: .large
        )
    }
    
    /// Create a horizontal view without developer name using Bundle ID
    static func iconsOnly(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 6,
        iconSize: IconSize = .medium
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showDeveloperName: false,
            iconSize: iconSize
        )
    }
    
    /// Create a horizontal view with custom icon size using Bundle ID
    static func custom(
        currentBundleId: String,
        excludeBundleIds: [String] = [],
        maxApps: Int = 6,
        iconSize: CGFloat,
        spacing: CGFloat? = nil,
        showDeveloperName: Bool = true
    ) -> HorizontalAppsView {
        HorizontalAppsView(
            currentBundleId: currentBundleId,
            excludeBundleIds: excludeBundleIds,
            maxApps: maxApps,
            showDeveloperName: showDeveloperName,
            iconSize: .custom(iconSize),
            spacing: spacing
        )
    }
}

// MARK: - Preview Support

#if DEBUG
#Preview("Default Horizontal View") {
    ScrollView {
        VStack(spacing: 24) {
            Text("My Apps")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HorizontalAppsView.forSettings(currentAppId: 1577859348)
            HorizontalAppsView.forSettings(currentAppId: 1577859348, maxApps: 3)
        }
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Horizontal View") {
    ScrollView {
        VStack(spacing: 24) {
            Text("Featured")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HorizontalAppsView.compact(currentAppId: 1577859348)
        }
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Large Icons View") {
    ScrollView {
        VStack(spacing: 24) {
            HorizontalAppsView.large(currentAppId: 1577859348, maxApps: 4)
        }
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Icons Only (No Developer Name)") {
    ScrollView {
        VStack(spacing: 24) {
            Text("Other Apps")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HorizontalAppsView.iconsOnly(currentAppId: 1577859348)
        }
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Multiple Sections") {
    ScrollView {
        VStack(spacing: 32) {
            Text("App Store")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Large featured section
            HorizontalAppsView.large(currentAppId: 1577859348, maxApps: 4)
            
            Divider()
                .padding(.horizontal)
            
            // Regular section
            HorizontalAppsView.forSettings(currentAppId: 389801252)
            
            Divider()
                .padding(.horizontal)
            
            // Compact section
            HorizontalAppsView.compact(currentAppId: 1577859348)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Custom Configuration") {
    ScrollView {
        VStack(spacing: 20) {
            // Small icons
            Text("Small Icons (60pt)")
                .font(.headline)
                .padding(.horizontal)
            
            HorizontalAppsView(
                currentAppId: 1577859348,
                maxApps: 8,
                showDeveloperName: true,
                iconSize: .small
            )
            
            Divider()
                .padding(.vertical)
            
            // Medium icons
            Text("Medium Icons (80pt)")
                .font(.headline)
                .padding(.horizontal)
            
            HorizontalAppsView(
                currentAppId: 1577859348,
                maxApps: 6,
                showDeveloperName: true,
                iconSize: .medium
            )
            
            Divider()
                .padding(.vertical)
            
            // Large icons
            Text("Large Icons (100pt)")
                .font(.headline)
                .padding(.horizontal)
            
            HorizontalAppsView(
                currentAppId: 1577859348,
                maxApps: 5,
                showDeveloperName: true,
                iconSize: .large
            )
            
            Divider()
                .padding(.vertical)
            
            // Custom size
            Text("Custom Icons (90pt)")
                .font(.headline)
                .padding(.horizontal)
            
            HorizontalAppsView.custom(
                currentAppId: 1577859348,
                maxApps: 6,
                iconSize: 90,
                spacing: 18
            )
        }
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("All Size Options") {
    ScrollView {
        VStack(spacing: 32) {
            // Small
            VStack(alignment: .leading) {
                Text("Small (60pt)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HorizontalAppsView(
                    currentAppId: 1577859348,
                    iconSize: .small
                )
            }
            
            // Medium
            VStack(alignment: .leading) {
                Text("Medium (80pt)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HorizontalAppsView(
                    currentAppId: 1577859348,
                    iconSize: .medium
                )
            }
            
            // Large
            VStack(alignment: .leading) {
                Text("Large (100pt)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HorizontalAppsView(
                    currentAppId: 1577859348,
                    iconSize: .large
                )
            }
            
            // Custom
            VStack(alignment: .leading) {
                Text("Custom (120pt)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HorizontalAppsView(
                    currentAppId: 1577859348,
                    iconSize: .custom(120),
                    spacing: 24
                )
            }
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
#endif
