//
//  Apps.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import Foundation

public struct SearchResults: Decodable, Sendable {
    public let resultCount: Int
    public let results: [Result]
    
    public init(resultCount: Int, results: [Result]) {
        self.resultCount = resultCount
        self.results = results
    }
}

public struct Result: Decodable, Hashable, Identifiable, Sendable {
    public let trackId: Int
    public let trackViewUrl: String
    public let trackName: String
    public let artistName: String
    public let artworkUrl100: String
    public let formattedPrice: String
    public let price: Double
    public let ipadScreenshotUrls: [String]
    
    // Enhanced fields for better app information
    public let averageUserRating: Double?
    public let userRatingCount: Int?
    public let description: String?
    public let genres: [String]?
    public let bundleId: String?
    public let version: String?
    public let releaseDate: String?
    public let currentVersionReleaseDate: String?
    public let fileSizeBytes: String?
    public let contentAdvisoryRating: String?
    public let artistId: Int?
    public let artistViewUrl: String?
    public let screenshotUrls: [String]?
    public let supportedDevices: [String]?
    public let minimumOsVersion: String?
    public let languageCodesISO2A: [String]?
    public let trackContentRating: String?
    public let sellerName: String?
    public let currency: String?
    public let primaryGenreName: String?
    public let primaryGenreId: Int?
    public let isGameCenterEnabled: Bool?
    public let advisories: [String]?
    public let features: [String]?
    public let releaseNotes: String?
    
    // Public initializer
    public init(
        trackId: Int,
        trackViewUrl: String,
        trackName: String,
        artistName: String,
        artworkUrl100: String,
        formattedPrice: String,
        price: Double,
        ipadScreenshotUrls: [String],
        averageUserRating: Double? = nil,
        userRatingCount: Int? = nil,
        description: String? = nil,
        genres: [String]? = nil,
        bundleId: String? = nil,
        version: String? = nil,
        releaseDate: String? = nil,
        currentVersionReleaseDate: String? = nil,
        fileSizeBytes: String? = nil,
        contentAdvisoryRating: String? = nil,
        artistId: Int? = nil,
        artistViewUrl: String? = nil,
        screenshotUrls: [String]? = nil,
        supportedDevices: [String]? = nil,
        minimumOsVersion: String? = nil,
        languageCodesISO2A: [String]? = nil,
        trackContentRating: String? = nil,
        sellerName: String? = nil,
        currency: String? = nil,
        primaryGenreName: String? = nil,
        primaryGenreId: Int? = nil,
        isGameCenterEnabled: Bool? = nil,
        advisories: [String]? = nil,
        features: [String]? = nil,
        releaseNotes: String? = nil
    ) {
        self.trackId = trackId
        self.trackViewUrl = trackViewUrl
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl100 = artworkUrl100
        self.formattedPrice = formattedPrice
        self.price = price
        self.ipadScreenshotUrls = ipadScreenshotUrls
        self.averageUserRating = averageUserRating
        self.userRatingCount = userRatingCount
        self.description = description
        self.genres = genres
        self.bundleId = bundleId
        self.version = version
        self.releaseDate = releaseDate
        self.currentVersionReleaseDate = currentVersionReleaseDate
        self.fileSizeBytes = fileSizeBytes
        self.contentAdvisoryRating = contentAdvisoryRating
        self.artistId = artistId
        self.artistViewUrl = artistViewUrl
        self.screenshotUrls = screenshotUrls
        self.supportedDevices = supportedDevices
        self.minimumOsVersion = minimumOsVersion
        self.languageCodesISO2A = languageCodesISO2A
        self.trackContentRating = trackContentRating
        self.sellerName = sellerName
        self.currency = currency
        self.primaryGenreName = primaryGenreName
        self.primaryGenreId = primaryGenreId
        self.isGameCenterEnabled = isGameCenterEnabled
        self.advisories = advisories
        self.features = features
        self.releaseNotes = releaseNotes
    }
    
    // Conformance to Identifiable
    public var id: Int { trackId }
    
    // MARK: - Computed Properties
    
    /// Rating for display (0.0 if no rating)
    public var displayRating: Double {
        return averageUserRating ?? 0.0
    }
    
    /// Rating count for display (0 if no ratings)
    public var displayRatingCount: Int {
        return userRatingCount ?? 0
    }
    
    /// Check if app has valid ratings
    public var hasRating: Bool {
        return averageUserRating != nil && userRatingCount != nil && userRatingCount! > 0
    }
    
    /// Primary genre for display
    public var displayGenre: String {
        if let primary = primaryGenreName {
            return primary
        }
        return genres?.first ?? "Apps"
    }
    
    /// File size in readable format
    public var displayFileSize: String {
        guard let fileSizeBytes = fileSizeBytes,
              let bytes = Double(fileSizeBytes) else {
            return "Unknown"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// App Store URL for opening
    public var appStoreURL: URL? {
        return URL(string: trackViewUrl)
    }
    
    /// High resolution artwork URL (512x512)
    public var artworkUrl512: String {
        return artworkUrl100.replacingOccurrences(of: "100x100", with: "512x512")
    }
    
    /// Is this a free app?
    public var isFree: Bool {
        return price == 0.0
    }
    
    /// Display price text
    public var displayPrice: String {
        if isFree {
            return "GET"
        }
        return formattedPrice
    }
    
    /// Star rating as integer (for star display)
    public var starRating: Int {
        return Int(round(displayRating))
    }
    
    /// App age rating for display
    public var displayAgeRating: String {
        return trackContentRating ?? contentAdvisoryRating ?? "4+"
    }
    
    /// Languages supported (formatted)
    public var displayLanguages: String {
        guard let languages = languageCodesISO2A, !languages.isEmpty else {
            return "English"
        }
        
        if languages.count == 1 {
            return languageDisplayName(for: languages[0])
        } else if languages.count <= 3 {
            return languages.map { languageDisplayName(for: $0) }.joined(separator: ", ")
        } else {
            return "\(languages.count) languages"
        }
    }
    
    /// Convert language code to display name
    private func languageDisplayName(for code: String) -> String {
        let locale = Locale(identifier: "en")
        return locale.localizedString(forLanguageCode: code) ?? code.uppercased()
    }
    
    /// Short description (first 100 characters)
    public var shortDescription: String {
        guard let desc = description else { return "" }
        if desc.count <= 100 {
            return desc
        }
        return String(desc.prefix(100)) + "..."
    }
    
    /// Check if app supports current device
    public var supportsCurrentDevice: Bool {
        // Simple check - if no device restrictions specified, assume it's supported
        return supportedDevices?.isEmpty != false
    }
}

// MARK: - Extensions for easier handling

public extension Result {
    /// Create a sample app for previews and testing
    static var sample: Result {
        return Result(
            trackId: 123456789,
            trackViewUrl: "https://apps.apple.com/app/id123456789",
            trackName: "Sample App Name",
            artistName: "Sample Developer",
            artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/sample.jpg",
            formattedPrice: "Free",
            price: 0.0,
            ipadScreenshotUrls: [],
            averageUserRating: 4.5,
            userRatingCount: 1234,
            description: "This is a sample app description for testing purposes.",
            genres: ["Productivity", "Utilities"],
            bundleId: "com.example.sampleapp",
            version: "1.0.0",
            releaseDate: "2023-01-01T00:00:00Z",
            currentVersionReleaseDate: "2023-01-01T00:00:00Z",
            fileSizeBytes: "50000000",
            contentAdvisoryRating: "4+",
            artistId: 987654321,
            artistViewUrl: "https://apps.apple.com/developer/sample-developer/id987654321",
            screenshotUrls: [],
            supportedDevices: ["iPhone", "iPad"],
            minimumOsVersion: "15.0",
            languageCodesISO2A: ["EN"],
            trackContentRating: "4+",
            sellerName: "Sample Developer Inc.",
            currency: "USD",
            primaryGenreName: "Productivity",
            primaryGenreId: 6007,
            isGameCenterEnabled: false,
            advisories: [],
            features: ["iosUniversal"],
            releaseNotes: "Initial release"
        )
    }
}

public extension SearchResults {
    /// Create sample search results for testing
    static var sample: SearchResults {
        return SearchResults(
            resultCount: 1,
            results: [Result.sample]
        )
    }
    
    /// Filter results by developer name
    func filterByDeveloper(_ developerName: String) -> SearchResults {
        let filteredResults = results.filter {
            $0.artistName.lowercased() == developerName.lowercased()
        }
        return SearchResults(resultCount: filteredResults.count, results: filteredResults)
    }
    
    /// Exclude specific app ID
    func excludingApp(withId appId: Int) -> SearchResults {
        let filteredResults = results.filter { $0.trackId != appId }
        return SearchResults(resultCount: filteredResults.count, results: filteredResults)
    }
}
