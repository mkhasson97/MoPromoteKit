//
//  PromotionInsights.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 20.09.25.
//

import SwiftUI

public struct PromotionInsights {
    public let totalDownloadPotential: Int
    public let averageRating: Double
    public let topPerformingApp: Result?
    public let categoryBreakdown: [String: Int]
    public let recommendedPromotionOrder: [Int]
    
    public init(
        totalDownloadPotential: Int,
        averageRating: Double,
        topPerformingApp: Result?,
        categoryBreakdown: [String: Int],
        recommendedPromotionOrder: [Int]
    ) {
        self.totalDownloadPotential = totalDownloadPotential
        self.averageRating = averageRating
        self.topPerformingApp = topPerformingApp
        self.categoryBreakdown = categoryBreakdown
        self.recommendedPromotionOrder = recommendedPromotionOrder
    }
}
