//
//  ManualAppsView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 20.09.25.
//

import SwiftUI

public struct ManualAppsView: View {
    @StateObject private var searchManager = AppSearchManager()
    @State private var apps: [Result] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let appIds: [Int]
    let maxApps: Int
    let showTitle: Bool
    let cardStyle: MoPromoteKit.CardStyle
    let sortingOrder: MoPromoteKit.SortingOrder
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        .task {
            await loadApps()
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading selected apps...")
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
            Text("No apps found")
                .font(.subheadline)
                .foregroundColor(.secondary)
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
            VStack(alignment: .leading, spacing: 2) {
                Text(MoPromoteKit.configuration.customTitle ?? "Featured Apps")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(apps.count) selected app\(apps.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var sortedApps: [Result] {
        switch sortingOrder {
        case .alphabetical:
            return apps.sorted { $0.trackName < $1.trackName }
        case .rating:
            return apps.sorted { $0.displayRating > $1.displayRating }
        case .releaseDate:
            return apps.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        case .custom(let order):
            return apps.sorted { app1, app2 in
                let index1 = order.firstIndex(of: app1.trackId) ?? Int.max
                let index2 = order.firstIndex(of: app2.trackId) ?? Int.max
                return index1 < index2
            }
        case .downloads:
            return apps.sorted { $0.displayRatingCount > $1.displayRatingCount }
        case .random:
            return apps.shuffled()
        }
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
        case .featured:
            FeaturedAppCard(app: app) {
                openAppInAppStore(app: app)
            }
        }
    }
    
    private func loadApps() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let results = try await searchManager.fetchSpecificApps(appIds: appIds)
            apps = Array(results.results.prefix(maxApps))
            isLoading = false
        } catch {
            errorMessage = "Failed to load apps: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func openAppInAppStore(app: Result) {
        guard let url = app.appStoreURL else { return }
        
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #endif
    }
}


// MARK: - Preview Support for ManualAppsView
#if DEBUG
#Preview("Manual Apps - Regular Cards") {
    ScrollView {
        ManualAppsView(
            appIds: [1577859348, 123456789, 987654321],
            maxApps: 10,
            showTitle: true,
            cardStyle: .regular,
            sortingOrder: .alphabetical
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - Featured Cards") {
    ScrollView {
        ManualAppsView(
            appIds: [1577859348, 123456789, 987654321, 456789123],
            maxApps: 10,
            showTitle: true,
            cardStyle: .featured,
            sortingOrder: .rating
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - Compact") {
    ScrollView {
        ManualAppsView(
            appIds: [1577859348, 123456789, 987654321, 456789123, 789123456],
            maxApps: 5,
            showTitle: false,
            cardStyle: .compact,
            sortingOrder: .releaseDate
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - Custom Title") {
    NavigationView {
        ScrollView {
            VStack {
                // Configure custom title before showing the view
                let _ = {
                    MoPromoteKit.configuration.customTitle = "Our Best Apps"
                }()
                
                ManualAppsView(
                    appIds: [1577859348, 123456789, 987654321],
                    maxApps: 10,
                    showTitle: true,
                    cardStyle: .regular,
                    sortingOrder: .rating
                )
            }
            .padding(.top)
        }
        .navigationTitle("Manual Selection")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Manual Apps - Single App") {
    ScrollView {
        ManualAppsView(
            appIds: [1577859348],
            maxApps: 10,
            showTitle: true,
            cardStyle: .featured,
            sortingOrder: .alphabetical
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - No Title") {
    VStack(spacing: 0) {
        // Some other content
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .frame(height: 100)
            .overlay(
                Text("Other Content Above")
                    .font(.headline)
            )
        
        // Manual apps without title
        ManualAppsView(
            appIds: [1577859348, 123456789, 987654321],
            maxApps: 10,
            showTitle: false,
            cardStyle: .compact,
            sortingOrder: .alphabetical
        )
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - Custom Order") {
    ScrollView {
        ManualAppsView(
            appIds: [987654321, 1577859348, 123456789], // Specific order
            maxApps: 10,
            showTitle: true,
            cardStyle: .regular,
            sortingOrder: .custom([987654321, 1577859348, 123456789]) // Same order as appIds
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Manual Apps - Release Date Sorting") {
    ScrollView {
        ManualAppsView(
            appIds: [1577859348, 123456789, 987654321, 456789123, 789123456, 321654987],
            maxApps: 10,
            showTitle: true,
            cardStyle: .regular,
            sortingOrder: .releaseDate
        )
        .padding(.top)
    }
    .background(Color(.systemGroupedBackground))
}
#endif
