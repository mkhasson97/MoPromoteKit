//
//  AppSearchManager.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import Foundation
import Combine

@MainActor
public class AppSearchManager: ObservableObject {
    private let primaryCountryCode: String
    public var countryCode: String {
        return primaryCountryCode
    }
    
    public init(countryCode: String? = nil) {
        self.primaryCountryCode = countryCode ?? CountrySettings.shared.selectedCountry
    }
    
    // MARK: - Public API
    
    /// Fetch all apps from the same developer with enhanced global ratings
    public func fetchDeveloperApps(appId: Int) async throws -> SearchResults {
        // Get the app details to find the developer
        let appDetails = try await fetchAppDetails(appId: appId)
        guard let app = appDetails.results.first else {
            throw AppSearchError.noAppFound
        }
        
        // Search for all apps by this developer
        let developerApps = try await searchAppsByDeveloper(
            developerName: app.artistName,
            excludingAppId: appId
        )
        
        // Enhance each app with global ratings
        let enhancedApps = await withTaskGroup(of: Result.self, returning: [Result].self) { group in
            var results: [Result] = []
            
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
        
        return SearchResults(resultCount: enhancedApps.count, results: enhancedApps)
    }
    
    /// Legacy method for backward compatibility with @Sendable closure
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
    
    // MARK: - Private Implementation
    
    private func fetchAppDetails(appId: Int) async throws -> SearchResults {
        let urlString = "https://itunes.apple.com/\(primaryCountryCode)/lookup?id=\(appId)"
        guard let url = URL(string: urlString) else {
            throw AppSearchError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SearchResults.self, from: data)
    }
    
    private func searchAppsByDeveloper(developerName: String, excludingAppId: Int) async throws -> SearchResults {
        let searchStrategies = [
            "\(developerName)&entity=software&attribute=softwareDeveloper",
            "\(developerName)&entity=software",
            "\"" + developerName + "\"" + "&entity=software"
        ]
        
        var allResults: [Result] = []
        var seenIds = Set<Int>()
        
        for strategy in searchStrategies {
            let urlString = "https://itunes.apple.com/\(primaryCountryCode)/search?term=\(strategy)"
            guard let safeURL = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
                  let url = URL(string: safeURL) else {
                continue
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                
                for result in searchResults.results {
                    if result.artistName.lowercased() == developerName.lowercased() &&
                       !seenIds.contains(result.trackId) &&
                       result.trackId != excludingAppId {
                        allResults.append(result)
                        seenIds.insert(result.trackId)
                    }
                }
            } catch {
                continue // Try next strategy
            }
        }
        
        return SearchResults(resultCount: allResults.count, results: allResults)
    }
    
    private func enhanceAppWithGlobalRatings(app: Result) async -> Result {
        let globalRatings = await fetchGlobalRatingsData(appId: app.trackId)
        
        let bestRating = globalRatings.isEmpty ? app.averageUserRating : globalRatings.max(by: { $0.rating < $1.rating })?.rating
        let totalReviews = globalRatings.reduce(0) { $0 + $1.count }
        let weightedAverage = calculateWeightedAverage(ratings: globalRatings)
        
        return Result(
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
    
    // MARK: - Debug Methods
    
    public func debugGlobalRatings(appId: Int) async -> String {
        var output = "🌍 Global Ratings Analysis for App ID: \(appId)\n"
        output += String(repeating: "=", count: 50) + "\n\n"
        
        let ratings = await fetchGlobalRatingsData(appId: appId)
        
        if ratings.isEmpty {
            output += "❌ No ratings found in any major market\n"
            return output
        }
        
        let sortedRatings = ratings.sorted { $0.count > $1.count }
        let weightedAverage = calculateWeightedAverage(ratings: ratings)
        let totalReviews = ratings.reduce(0) { $0 + $1.count }
        
        output += "📊 Summary:\n"
        output += "   • Total Reviews: \(totalReviews.formatted())\n"
        output += "   • Weighted Average: \(String(format: "%.2f", weightedAverage ?? 0))⭐\n"
        output += "   • Markets with data: \(ratings.count)/\(CountrySettings.majorMarkets.count)\n\n"
        
        output += "🌟 Top Markets:\n"
        for (index, rating) in sortedRatings.prefix(10).enumerated() {
            output += "   \(index + 1). \(String(format: "%.1f", rating.rating))⭐ (\(rating.count.formatted()) reviews)\n"
        }
        
        return output
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
