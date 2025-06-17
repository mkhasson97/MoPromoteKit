//
//  CountrySettings.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import Foundation

@MainActor
public final class CountrySettings: ObservableObject, Sendable {
    public static let shared = CountrySettings()
    
    @Published public var selectedCountry: String = "us"
    
    private init() {
        // Auto-detect user's country from locale
        if let countryCode = Locale.current.region?.identifier.lowercased(),
           Self.supportedCountries.keys.contains(countryCode) {
            selectedCountry = countryCode
        }
    }
    
    // MARK: - Major Markets for Global Ratings
    
    /// Major App Store markets used for global ratings aggregation
    public static let majorMarkets: [String] = [
        "us", "gb", "ca", "au", "de", "fr", "it", "es", "nl", "se",
        "no", "dk", "fi", "jp", "kr", "cn", "hk", "tw", "sg", "in",
        "br", "mx", "ar", "cl", "co", "pe", "ru", "tr", "il", "za"
    ]
    
    // MARK: - All Supported Countries (80+ regions)
    
    public static let supportedCountries: [String: String] = [
        // Americas
        "us": "United States",
        "ca": "Canada",
        "mx": "Mexico",
        "br": "Brazil",
        "ar": "Argentina",
        "cl": "Chile",
        "co": "Colombia",
        "pe": "Peru",
        "uy": "Uruguay",
        "py": "Paraguay",
        "bo": "Bolivia",
        "ec": "Ecuador",
        "ve": "Venezuela",
        "cr": "Costa Rica",
        "gt": "Guatemala",
        "hn": "Honduras",
        "ni": "Nicaragua",
        "pa": "Panama",
        "sv": "El Salvador",
        "do": "Dominican Republic",
        "jm": "Jamaica",
        "tt": "Trinidad and Tobago",
        "bb": "Barbados",
        
        // Europe
        "gb": "United Kingdom",
        "de": "Germany",
        "fr": "France",
        "it": "Italy",
        "es": "Spain",
        "nl": "Netherlands",
        "be": "Belgium",
        "at": "Austria",
        "ch": "Switzerland",
        "se": "Sweden",
        "no": "Norway",
        "dk": "Denmark",
        "fi": "Finland",
        "ie": "Ireland",
        "pt": "Portugal",
        "lu": "Luxembourg",
        "gr": "Greece",
        "cy": "Cyprus",
        "mt": "Malta",
        "pl": "Poland",
        "cz": "Czech Republic",
        "sk": "Slovakia",
        "hu": "Hungary",
        "si": "Slovenia",
        "hr": "Croatia",
        "bg": "Bulgaria",
        "ro": "Romania",
        "ee": "Estonia",
        "lv": "Latvia",
        "lt": "Lithuania",
        "ru": "Russia",
        "ua": "Ukraine",
        "by": "Belarus",
        "md": "Moldova",
        "tr": "Turkey",
        
        // Asia Pacific
        "jp": "Japan",
        "kr": "South Korea",
        "cn": "China",
        "hk": "Hong Kong",
        "tw": "Taiwan",
        "sg": "Singapore",
        "my": "Malaysia",
        "th": "Thailand",
        "ph": "Philippines",
        "id": "Indonesia",
        "vn": "Vietnam",
        "in": "India",
        "lk": "Sri Lanka",
        "pk": "Pakistan",
        "bd": "Bangladesh",
        "np": "Nepal",
        "au": "Australia",
        "nz": "New Zealand",
        "fj": "Fiji",
        
        // Middle East & Africa
        "ae": "United Arab Emirates",
        "sa": "Saudi Arabia",
        "kw": "Kuwait",
        "qa": "Qatar",
        "bh": "Bahrain",
        "om": "Oman",
        "jo": "Jordan",
        "lb": "Lebanon",
        "il": "Israel",
        "eg": "Egypt",
        "za": "South Africa",
        "ke": "Kenya",
        "ng": "Nigeria",
        "gh": "Ghana",
        "ug": "Uganda",
        "tz": "Tanzania",
        "ma": "Morocco",
        "tn": "Tunisia",
        "dz": "Algeria",
        "mz": "Mozambique",
        "zm": "Zambia",
        "zw": "Zimbabwe",
        "bw": "Botswana",
        "na": "Namibia",
        "sz": "Eswatini",
        "mw": "Malawi",
        "mg": "Madagascar"
    ]
    
    // MARK: - Public Methods
    
    /// Get country name for code
    public static func countryName(for code: String) -> String {
        return supportedCountries[code.lowercased()] ?? code.uppercased()
    }
    
    /// Check if country is supported
    public static func isSupported(countryCode: String) -> Bool {
        return supportedCountries.keys.contains(countryCode.lowercased())
    }
    
    /// Get all country codes sorted by name
    public static var sortedCountryCodes: [String] {
        return supportedCountries.keys.sorted { code1, code2 in
            let name1 = supportedCountries[code1] ?? code1
            let name2 = supportedCountries[code2] ?? code2
            return name1 < name2
        }
    }
    
    /// Get major markets info
    public static var majorMarketsInfo: [(code: String, name: String)] {
        return majorMarkets.compactMap { code in
            guard let name = supportedCountries[code] else { return nil }
            return (code, name)
        }.sorted { $0.name < $1.name }
    }
    
    /// Set country code
    public func setCountry(_ countryCode: String) {
        guard Self.isSupported(countryCode: countryCode) else { return }
        selectedCountry = countryCode.lowercased()
    }
    
    /// Reset to auto-detected country
    public func resetToAutoDetected() {
        if let countryCode = Locale.current.region?.identifier.lowercased(),
           Self.supportedCountries.keys.contains(countryCode) {
            selectedCountry = countryCode
        } else {
            selectedCountry = "us" // Fallback to US
        }
    }
}

// MARK: - Thread-Safe Access Helper

extension CountrySettings {
    /// Get current selected country in a thread-safe way
    public static func getCurrentCountry() async -> String {
        await shared.selectedCountry
    }
    
    /// Set country in a thread-safe way
    public static func setCurrentCountry(_ countryCode: String) async {
        await shared.setCountry(countryCode)
    }
}
