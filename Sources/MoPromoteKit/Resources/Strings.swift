//
//  Strings.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 01.04.26.
//

import Foundation

/// Centralized localization helper for MoPromoteKit
/// Uses Bundle.module to access the package's localized strings
enum L10n {
    
    // MARK: - Loading States
    
    static var loadingDeveloperApps: String {
        NSLocalizedString("loading.developer.apps", bundle: .module, comment: "Loading developer apps message")
    }
    
    static var loadingApps: String {
        NSLocalizedString("loading.apps", bundle: .module, comment: "Loading apps message")
    }
    
    static var loadingSelectedApps: String {
        NSLocalizedString("loading.selected.apps", bundle: .module, comment: "Loading selected apps message")
    }
    
    static func loadingPercentComplete(_ percent: Int) -> String {
        String(format: NSLocalizedString("loading.percent.complete", bundle: .module, comment: "Loading progress percentage"), percent)
    }
    
    // MARK: - Error States
    
    static var errorFailedToLoadApps: String {
        NSLocalizedString("error.failed.to.load.apps", bundle: .module, comment: "Failed to load apps title")
    }
    
    static var errorFailedToLoad: String {
        NSLocalizedString("error.failed.to.load", bundle: .module, comment: "Failed to load title")
    }
    
    static var errorTryAgain: String {
        NSLocalizedString("error.try.again", bundle: .module, comment: "Try again button")
    }
    
    // MARK: - Empty States
    
    static var emptyNoOtherAppsFound: String {
        NSLocalizedString("empty.no.other.apps.found", bundle: .module, comment: "No other apps found title")
    }
    
    static var emptyNoOtherAppsDescription: String {
        NSLocalizedString("empty.no.other.apps.description", bundle: .module, comment: "No other apps found description")
    }
    
    static var emptyNoAdditionalAppsFrom: String {
        NSLocalizedString("empty.no.additional.apps.from", bundle: .module, comment: "No additional apps found from developer")
    }
    
    static var emptyNoAppsFound: String {
        NSLocalizedString("empty.no.apps.found", bundle: .module, comment: "No apps found text")
    }
    
    static var emptyNoAppsAvailable: String {
        NSLocalizedString("empty.no.apps.available", bundle: .module, comment: "No apps available title")
    }
    
    static var emptyNoAppsAvailableDescription: String {
        NSLocalizedString("empty.no.apps.available.description", bundle: .module, comment: "No apps available description")
    }
    
    // MARK: - Section Titles
    
    static var titleMoreApps: String {
        NSLocalizedString("title.more.apps", bundle: .module, comment: "More Apps section title")
    }
    
    static var titleFeaturedApps: String {
        NSLocalizedString("title.featured.apps", bundle: .module, comment: "Featured Apps section title")
    }
    
    static var titleRecommendedApps: String {
        NSLocalizedString("title.recommended.apps", bundle: .module, comment: "Recommended Apps section title")
    }
    
    // MARK: - Labels
    
    static func fromDeveloper(_ name: String) -> String {
        String(format: NSLocalizedString("label.from.developer", bundle: .module, comment: "from developer name"), name)
    }
    
    static func appCount(_ count: Int) -> String {
        let key = count == 1 ? "label.app.count" : "label.apps.count"
        return String(format: NSLocalizedString(key, bundle: .module, comment: "App count"), count)
    }
    
    static func reviews(_ count: String) -> String {
        String(format: NSLocalizedString("label.reviews", bundle: .module, comment: "Reviews count"), count)
    }
    
    static func selectedApps(_ count: Int) -> String {
        let key = count == 1 ? "label.selected.app" : "label.selected.apps"
        return String(format: NSLocalizedString(key, bundle: .module, comment: "Selected apps count"), count)
    }
    
    static func handpickedApps(_ count: Int) -> String {
        let key = count == 1 ? "label.handpicked.app" : "label.handpicked.apps"
        return String(format: NSLocalizedString(key, bundle: .module, comment: "Handpicked apps count"), count)
    }
    
    static func additionalApps(_ count: Int) -> String {
        let key = count == 1 ? "label.additional.app" : "label.additional.apps"
        return String(format: NSLocalizedString(key, bundle: .module, comment: "Additional apps count"), count)
    }
    
    static func moreFrom(_ name: String) -> String {
        String(format: NSLocalizedString("label.more.from", bundle: .module, comment: "More from developer"), name)
    }
    
    static func curatedSelection(_ name: String) -> String {
        String(format: NSLocalizedString("label.curated.selection", bundle: .module, comment: "Curated selection subtitle"), name)
    }
    
    static func totalApps(_ count: Int) -> String {
        let key = count == 1 ? "label.total.apps" : "label.total.apps.plural"
        return String(format: NSLocalizedString(key, bundle: .module, comment: "Total apps count"), count)
    }
    
    static var noRatingsYet: String {
        NSLocalizedString("label.no.ratings.yet", bundle: .module, comment: "No ratings yet label")
    }
    
    // MARK: - Analytics
    
    static var analyticsAvgRating: String {
        NSLocalizedString("analytics.avg.rating", bundle: .module, comment: "Average rating label")
    }
    
    static var analyticsTotalReviews: String {
        NSLocalizedString("analytics.total.reviews", bundle: .module, comment: "Total reviews label")
    }
    
    static var analyticsCategories: String {
        NSLocalizedString("analytics.categories", bundle: .module, comment: "Categories label")
    }
    
    static var analyticsCombinedRating: String {
        NSLocalizedString("analytics.combined.rating", bundle: .module, comment: "Combined rating label")
    }
    
    // MARK: - Pricing
    
    static var priceGet: String {
        NSLocalizedString("price.get", bundle: .module, comment: "GET button for free apps")
    }
}
