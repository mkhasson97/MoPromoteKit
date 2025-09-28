//
//  MoPromoteKit.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import SwiftUI

// MARK: - Main Public API

/// MoPromoteKit - Easy cross-promotion of your iOS apps
///
/// MoPromoteKit helps iOS developers cross-promote their other apps by fetching them
/// from the iTunes Search API and displaying them with global ratings aggregation.
///
/// Features:
/// - Fetches all apps from the same developer using iTunes Search API
/// - Aggregates ratings from 80+ countries for more accurate data
/// - Beautiful SwiftUI cards with SF Symbol category icons
/// - Support for all major App Store regions
/// - Performance optimized with concurrent API calls
/// - Clean, modular architecture
///
/// ## Basic Usage
/// ```swift
/// import MoPromoteKit
///
/// struct SettingsView: View {
///     var body: some View {
///         VStack {
///             // Your settings content
///
///             MoPromoteKit.developerAppsView(currentAppId: 1234567890)
///         }
///     }
/// }
/// ```
@MainActor
public struct MoPromoteKit {
    
    // MARK: - App Selection Mode
    
    /// How apps should be selected for promotion
    public enum AppSelectionMode {
        /// Automatically fetch all apps from the same developer
        case allFromDeveloper(currentAppId: Int)
        /// Manually specify exact app IDs to promote
        case manual(appIds: [Int])
        /// Hybrid: specific apps + other developer apps (excluding specified ones)
        case hybrid(featuredAppIds: [Int], currentAppId: Int, maxAdditional: Int = 5)
    }
    
    // MARK: - Configuration
    
    /// Global configuration for MoPromoteKit
    public struct Configuration {
        /// Maximum number of apps to display (default: 10)
        public var maxApps: Int = 10
        /// Country code for App Store region (default: auto-detected)
        public var countryCode: String?
        /// Whether to show the "More Apps" title (default: true)
        public var showTitle: Bool = true
    
        public var cardStyle: CardStyle = .regular
        public var enableGlobalRatings: Bool = true
        public var cacheDuration: TimeInterval = 300
        
        // New properties
        public var appSelectionMode: AppSelectionMode = .allFromDeveloper(currentAppId: 0)
        public var sortingOrder: SortingOrder = .alphabetical
        public var showDeveloperBranding: Bool = true
        public var customTitle: String?
        
        public init() {}
    }
    
    /// Card display styles
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
        case custom([Int]) // Custom order by app IDs
    }
    
    /// Shared configuration instance
    public static var configuration = Configuration()
    
    // MARK: - SwiftUI Views
    
    /// Create a developer apps view for settings pages
    /// - Parameter currentAppId: The App Store ID of your current app
    /// - Returns: A SwiftUI view displaying other apps from the same developer
    public static func developerAppsView(
        currentAppId: Int,
        excludeAppIds: [Int] = []
    ) -> some View {
        DeveloperAppsView(
            currentAppId: currentAppId,
            excludeAppIds: excludeAppIds,
            maxApps: configuration.maxApps,
            showTitle: configuration.showTitle,
            cardStyle: configuration.cardStyle == .regular ? .regular : .compact
        )
    }
    
    /// Create a compact developer apps view
    /// - Parameters:
    ///   - currentAppId: The App Store ID of your current app
    ///   - maxApps: Maximum number of apps to show (default: 5)
    /// - Returns: A compact SwiftUI view for smaller spaces
    public static func compactDeveloperAppsView(
        currentAppId: Int,
        maxApps: Int = 5
    ) -> some View {
        DeveloperAppsView.compact(currentAppId: currentAppId, maxApps: maxApps)
    }
    
    /// Create a full-screen developer apps view
    /// - Parameter currentAppId: The App Store ID of your current app
    /// - Returns: A SwiftUI view for full-screen presentation
    public static func fullScreenDeveloperAppsView(currentAppId: Int) -> some View {
        DeveloperAppsView.fullScreen(currentAppId: currentAppId)
    }
    
    /// Create a view with manual app selection
        public static func manualAppsView(appIds: [Int]) -> some View {
            ManualAppsView(
                appIds: appIds,
                maxApps: configuration.maxApps,
                showTitle: configuration.showTitle,
                cardStyle: configuration.cardStyle,
                sortingOrder: configuration.sortingOrder
            )
        }
        
        /// Create a hybrid view (featured + developer apps)
        public static func hybridAppsView(
            featuredAppIds: [Int],
            currentAppId: Int,
            maxAdditional: Int = 5
        ) -> some View {
            HybridAppsView(
                featuredAppIds: featuredAppIds,
                currentAppId: currentAppId,
                maxAdditional: maxAdditional,
                showTitle: configuration.showTitle,
                cardStyle: configuration.cardStyle
            )
        }
    
    // MARK: - Programmatic API
    
    /// Get apps from the same developer programmatically
    /// - Parameter currentAppId: The App Store ID of your current app
    /// - Returns: Search results with enhanced global ratings
    public static func fetchDeveloperApps(currentAppId: Int) async throws -> SearchResults {
        let manager = AppSearchManager(countryCode: configuration.countryCode)
        return try await manager.fetchDeveloperApps(appId: currentAppId)
    }
    
    /// Get global ratings debug information
    /// - Parameter appId: The App Store ID to analyze
    /// - Returns: Detailed global ratings analysis string
//    public static func debugGlobalRatings(appId: Int) async -> String {
//        let manager = AppSearchManager(countryCode: configuration.countryCode)
//        return await manager.debugGlobalRatings(appId: appId)
//    }
    
    // MARK: - Configuration Methods
    
    /// Configure MoPromoteKit globally
    /// - Parameter config: Configuration object with your preferences
    public static func configure(_ config: Configuration) {
        configuration = config
    }
    
    /// Configure MoPromoteKit with a builder pattern
    /// - Parameter builder: Configuration builder closure
    public static func configure(_ builder: (inout Configuration) -> Void) {
        builder(&configuration)
    }
    
    // MARK: - Utility Methods
    
    /// Check if a country code is supported
    /// - Parameter countryCode: Two-letter country code
    /// - Returns: Whether the country is supported
    public static func isCountrySupported(_ countryCode: String) -> Bool {
        return CountrySettings.isSupported(countryCode: countryCode)
    }
    
    /// Get all supported countries
    /// - Returns: Dictionary of country codes to names
    public static var supportedCountries: [String: String] {
        return CountrySettings.supportedCountries
    }
    
    /// Get major App Store markets used for global ratings
    /// - Returns: Array of country codes
    public static var majorMarkets: [String] {
        return CountrySettings.majorMarkets
    }
}

// MARK: - Convenience Extensions

public extension MoPromoteKit.Configuration {
    /// Configuration for settings pages
    static var forSettings: MoPromoteKit.Configuration {
        var config = MoPromoteKit.Configuration()
        config.maxApps = 60
        config.showTitle = true
        config.cardStyle = .regular
        return config
    }
    
    /// Configuration for compact displays
    static var compact: MoPromoteKit.Configuration {
        var config = MoPromoteKit.Configuration()
        config.maxApps = 5
        config.showTitle = false
        config.cardStyle = .compact
        return config
    }
    
    /// Configuration for full-screen displays
    static var fullScreen: MoPromoteKit.Configuration {
        var config = MoPromoteKit.Configuration()
        config.maxApps = 20
        config.showTitle = true
        config.cardStyle = .regular
        return config
    }
}

// MARK: - SwiftUI Convenience Modifiers

public extension View {
    /// Add a developer apps section to your view
    /// - Parameter currentAppId: The App Store ID of your current app
    /// - Returns: Modified view with developer apps section
    func withDeveloperApps(currentAppId: Int) -> some View {
        VStack(spacing: 16) {
            self
            MoPromoteKit.developerAppsView(currentAppId: currentAppId)
        }
    }
}
