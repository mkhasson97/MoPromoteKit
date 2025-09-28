//
//  AppSearchManager.swift
//  MoPromoteKit - Cleaned and Optimized
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import Foundation
import Combine

@MainActor
public class AppSearchManager: ObservableObject {
    private let primaryCountryCode: String
    private var cache: [String: (data: SearchResults, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    public var countryCode: String {
        return primaryCountryCode
    }
    
    public init(countryCode: String? = nil) {
        self.primaryCountryCode = countryCode ?? CountrySettings.shared.selectedCountry
    }
    
    // MARK: - Main API
    
    /// Fetch all apps from the same developer
    public func fetchDeveloperApps(
        appId: Int,
        excludeAppIds: [Int] = [],
        includeCurrentApp: Bool = false,
        maxApps: Int? = nil
    ) async throws -> SearchResults {
        let cacheKey = "developer_\(appId)_exclude_\(excludeAppIds.sorted().map(String.init).joined(separator: "_"))"
        if let cached = getCachedResult(key: cacheKey) {
            return cached
        }
        
        // Get the app details to find the developer
        let appDetails = try await fetchAppDetails(appId: appId)
        guard let app = appDetails.results.first else {
            throw AppSearchError.noAppFound
        }
        
        // Get all apps from the same developer
        var excludeIds = excludeAppIds
        if !includeCurrentApp {
            excludeIds.append(appId)
        }
        
        let developerApps = try await searchByArtistId(
            artistId: app.artistId ?? 0,
            excludingAppIds: excludeIds
        )
        
        // Enhance each app with global ratings
        let enhancedApps = await withTaskGroup(of: AppResult.self, returning: [AppResult].self) { group in
            var results: [AppResult] = []
            
            for app in developerApps.results {
                group.addTask { [weak self] in
                    guard let self = self else { return app }
                    return await self.enhanceAppWithGlobalRatings(app: app)
                }
            }
            
            for await enhancedApp in group {
                results.append(enhancedApp)
            }
            
            return results.sorted { $0.trackName < $1.trackName }
        }
        
        // Apply maxApps limit if specified
        let finalApps = if let maxApps = maxApps {
            Array(enhancedApps.prefix(maxApps))
        } else {
            enhancedApps
        }
        
        let searchResults = SearchResults(resultCount: finalApps.count, results: finalApps)
        setCachedResult(key: cacheKey, data: searchResults)
        return searchResults
    }
    
    // MARK: - Core Search Method
    
    private func searchByArtistId(artistId: Int, excludingAppIds: [Int]) async throws -> SearchResults {
        guard artistId > 0 else {
            throw AppSearchError.noAppFound
        }
        
        let directUrl = "https://itunes.apple.com/lookup?id=\(artistId)&entity=software&country=\(primaryCountryCode)"
        
        guard let url = URL(string: directUrl) else {
            throw AppSearchError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw AppSearchError.networkError("HTTP \(httpResponse.statusCode)")
            }
            
            // Parse JSON manually to handle mixed response types (artist + apps)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let rawResults = json["results"] as? [[String: Any]] else {
                throw AppSearchError.decodingError("Invalid JSON structure")
            }
            
            // Filter and decode only app entries
            var appResults: [AppResult] = []
            for rawResult in rawResults {
                // Skip artist entries - they don't have trackId
                guard rawResult["trackId"] != nil else { continue }
                
                do {
                    let resultData = try JSONSerialization.data(withJSONObject: rawResult)
                    let appResult = try JSONDecoder().decode(AppResult.self, from: resultData)
                    
                    // Filter by artist ID and excluded apps
                    if appResult.artistId == artistId && !excludingAppIds.contains(appResult.trackId) {
                        appResults.append(appResult)
                    }
                } catch {
                    continue // Skip invalid entries
                }
            }
            
            return SearchResults(resultCount: appResults.count, results: appResults)
            
        } catch {
            throw AppSearchError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Global Ratings Enhancement
    
    private func enhanceAppWithGlobalRatings(app: AppResult) async -> AppResult {
        let globalRatings = await fetchGlobalRatingsData(appId: app.trackId)
        
        let bestRating = globalRatings.isEmpty ? app.averageUserRating : globalRatings.max(by: { $0.rating < $1.rating })?.rating
        let totalReviews = globalRatings.reduce(0) { $0 + $1.count }
        let weightedAverage = calculateWeightedAverage(ratings: globalRatings)
        
        return AppResult(
            trackId: app.trackId,
            trackViewUrl: app.trackViewUrl,
            trackName: app.trackName,
            artistName: app.artistName,
            artworkUrl100: app.artworkUrl100,
            formattedPrice: app.formattedPrice,
            price: app.price,
            ipadScreenshotUrls: app.ipadScreenshotUrls,
            averageUserRating: weightedAverage ?? bestRating ?? app.averageUserRating,
            userRatingCount: totalReviews > 0 ? totalReviews : app.userRatingCount,
            description: app.description,
            genres: app.genres,
            bundleId: app.bundleId,
            version: app.version,
            releaseDate: app.releaseDate,
            currentVersionReleaseDate: app.currentVersionReleaseDate,
            fileSizeBytes: app.fileSizeBytes,
            contentAdvisoryRating: app.contentAdvisoryRating,
            artistId: app.artistId,
            artistViewUrl: app.artistViewUrl,
            screenshotUrls: app.screenshotUrls,
            supportedDevices: app.supportedDevices,
            minimumOsVersion: app.minimumOsVersion,
            languageCodesISO2A: app.languageCodesISO2A,
            trackContentRating: app.trackContentRating,
            sellerName: app.sellerName,
            currency: app.currency,
            primaryGenreName: app.primaryGenreName,
            primaryGenreId: app.primaryGenreId,
            isGameCenterEnabled: app.isGameCenterEnabled,
            advisories: app.advisories,
            features: app.features,
            releaseNotes: app.releaseNotes
        )
    }
    
    private func fetchGlobalRatingsData(appId: Int) async -> [(rating: Double, count: Int)] {
        return await withTaskGroup(of: (Double, Int)?.self, returning: [(rating: Double, count: Int)].self) { group in
            var ratings: [(rating: Double, count: Int)] = []
            
            // Fetch from all major markets for comprehensive data
            for countryCode in CountrySettings.majorMarkets {
                group.addTask { [weak self] in
                    guard let self = self else { return nil }
                    return await self.fetchRatingForCountry(appId: appId, countryCode: countryCode)
                }
            }
            
            for await result in group {
                if let result = result {
                    ratings.append(result)
                }
            }
            
            return ratings
        }
    }
    
    private func fetchRatingForCountry(appId: Int, countryCode: String) async -> (rating: Double, count: Int)? {
        do {
            let urlString = "https://itunes.apple.com/\(countryCode)/lookup?id=\(appId)"
            guard let url = URL(string: urlString) else { return nil }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(SearchResults.self, from: data)
            
            guard let app = results.results.first,
                  let rating = app.averageUserRating,
                  let count = app.userRatingCount,
                  count > 0 else {
                return nil
            }
            
            return (rating, count)
        } catch {
            return nil
        }
    }
    
    private func calculateWeightedAverage(ratings: [(rating: Double, count: Int)]) -> Double? {
        guard !ratings.isEmpty else { return nil }
        
        let totalWeightedSum = ratings.reduce(0.0) { $0 + ($1.rating * Double($1.count)) }
        let totalCount = ratings.reduce(0) { $0 + $1.count }
        
        return totalCount > 0 ? totalWeightedSum / Double(totalCount) : nil
    }
    
    // MARK: - Additional API Methods
    
    /// Fetch specific apps by their IDs
    public func fetchSpecificApps(appIds: [Int]) async throws -> SearchResults {
        let cacheKey = "manual_\(appIds.sorted().map(String.init).joined(separator: "_"))"
        if let cached = getCachedResult(key: cacheKey) {
            return cached
        }
        
        let enhancedApps = await withTaskGroup(of: AppResult?.self, returning: [AppResult].self) { group in
            var results: [AppResult] = []
            
            for appId in appIds {
                group.addTask { [weak self] in
                    guard let self = self else { return nil }
                    do {
                        let appDetails = try await self.fetchAppDetails(appId: appId)
                        guard let app = appDetails.results.first else { return nil }
                        return await self.enhanceAppWithGlobalRatings(app: app)
                    } catch {
                        return nil
                    }
                }
            }
            
            for await app in group {
                if let app = app {
                    results.append(app)
                }
            }
            
            return appIds.compactMap { targetId in
                results.first { $0.trackId == targetId }
            }
        }
        
        let searchResults = SearchResults(resultCount: enhancedApps.count, results: enhancedApps)
        setCachedResult(key: cacheKey, data: searchResults)
        return searchResults
    }
    
    /// Get promotion insights for specific apps
    public func getPromotionInsights(appIds: [Int]) async -> PromotionInsights {
        do {
            let results = try await fetchSpecificApps(appIds: appIds)
            let apps = results.results
            
            let totalDownloads = apps.reduce(0) { $0 + ($1.userRatingCount ?? 0) }
            let avgRating = apps.isEmpty ? 0.0 : apps.reduce(0.0) { $0 + $1.displayRating } / Double(apps.count)
            let topApp = apps.max(by: { $0.displayRating < $1.displayRating })
            
            var categoryBreakdown: [String: Int] = [:]
            for app in apps {
                let category = app.displayGenre
                categoryBreakdown[category, default: 0] += 1
            }
            
            let recommendedOrder = apps
                .sorted { app1, app2 in
                    let score1 = app1.displayRating * Double(app1.displayRatingCount)
                    let score2 = app2.displayRating * Double(app2.displayRatingCount)
                    return score1 > score2
                }
                .map { $0.trackId }
            
            return PromotionInsights(
                totalDownloadPotential: totalDownloads,
                averageRating: avgRating,
                topPerformingApp: topApp,
                categoryBreakdown: categoryBreakdown,
                recommendedPromotionOrder: recommendedOrder
            )
        } catch {
            return PromotionInsights(
                totalDownloadPotential: 0,
                averageRating: 0.0,
                topPerformingApp: nil,
                categoryBreakdown: [:],
                recommendedPromotionOrder: []
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchAppDetails(appId: Int) async throws -> SearchResults {
        let countries = [primaryCountryCode, "us", "gb"]
        
        for country in countries {
            let urlString = "https://itunes.apple.com/\(country)/lookup?id=\(appId)"
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let result = try JSONDecoder().decode(SearchResults.self, from: data)
                    if !result.results.isEmpty {
                        return result
                    }
                }
            } catch {
                continue
            }
        }
        
        throw AppSearchError.noAppFound
    }
    
    // MARK: - Cache Management
    
    private func getCachedResult(key: String) -> SearchResults? {
        guard let cached = cache[key] else { return nil }
        
        let timeElapsed = Date().timeIntervalSince(cached.timestamp)
        if timeElapsed > cacheTimeout {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return cached.data
    }
    
    private func setCachedResult(key: String, data: SearchResults) {
        cache[key] = (data: data, timestamp: Date())
    }
    
    public func clearCache() {
        cache.removeAll()
    }
    
    // MARK: - Legacy Compatibility
    
    public func fetchDeveloperApps(appId: Int) async throws -> SearchResults {
        return try await fetchDeveloperApps(appId: appId, excludeAppIds: [], includeCurrentApp: false, maxApps: nil)
    }
    
    /// Legacy method for backward compatibility
    public func fetchAppsFromAppstore(
        software: String,
        searchText: String,
        completion: @escaping @Sendable (SearchResults) -> Void
    ) {
        let urlString = "https://itunes.apple.com/\(primaryCountryCode)/search?term=\(searchText)&entity=\(software)"
        guard let safeURL = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
              let url = URL(string: safeURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let apps = try JSONDecoder().decode(SearchResults.self, from: data)
                Task { @MainActor in
                    completion(apps)
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - Error Types

public enum AppSearchError: LocalizedError, Sendable {
    case noAppFound
    case invalidURL
    case networkError(String)
    case decodingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .noAppFound:
            return "No app found with the provided ID"
        case .invalidURL:
            return "Invalid URL provided"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data decoding error: \(message)"
        }
    }
}
