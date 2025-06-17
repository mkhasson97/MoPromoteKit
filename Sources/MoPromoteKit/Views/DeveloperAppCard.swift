//
//  DeveloperAppCard.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//

import SwiftUI

public struct DeveloperAppCard: View {
    let app: Result
    let onDownloadTapped: () -> Void
    
    public init(app: Result, onDownloadTapped: @escaping () -> Void) {
        self.app = app
        self.onDownloadTapped = onDownloadTapped
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // App Icon
            AsyncImage(url: URL(string: app.artworkUrl512)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "app.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary, lineWidth: 0.23)
            )
            
            // App Info
            VStack(alignment: .leading, spacing: 4) {
                Text(app.trackName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Rating Section
                if app.hasRating {
                    HStack(spacing: 4) {
                        // Star Rating
                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: "star.fill")
                                    .foregroundColor(index < app.starRating ? .yellow : .gray.opacity(0.3))
                                    .font(.caption)
                            }
                        }
                        
                        Text(String(format: "%.1f", app.displayRating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("(\(app.displayRatingCount.formatted()))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No ratings yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Genre with icon
                HStack(spacing: 4) {
                    Image(systemName: CategoryIcons.iconForCategory(app.displayGenre))
                        .font(.caption)
                    
                    Text(app.displayGenre)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Download Button
            Button(action: onDownloadTapped) {
                Text(app.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Compact Version

public struct DeveloperAppCompactCard: View {
    let app: Result
    let onDownloadTapped: () -> Void
    
    public init(app: Result, onDownloadTapped: @escaping () -> Void) {
        self.app = app
        self.onDownloadTapped = onDownloadTapped
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // App Icon (smaller)
            AsyncImage(url: URL(string: app.artworkUrl100)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "app.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // App Info (condensed)
            VStack(alignment: .leading, spacing: 2) {
                Text(app.trackName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if app.hasRating {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption2)
                        
                        Text(String(format: "%.1f", app.displayRating))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: CategoryIcons.iconForCategory(app.displayGenre))
                            .foregroundColor(.blue)
                            .font(.caption2)
                        
                        Text(app.displayGenre)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Download Button (smaller)
            Button(action: onDownloadTapped) {
                Text(app.displayPrice)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview Support

#if DEBUG
#Preview("Regular Card") {
    VStack(spacing: 12) {
        DeveloperAppCard(app: Result.sample) {
            print("Download tapped")
        }
        
        DeveloperAppCard(app: {
            var sample = Result.sample
            // Simulate paid app
            return Result(
                trackId: sample.trackId,
                trackViewUrl: sample.trackViewUrl,
                trackName: "Pro App with Long Name That Might Wrap",
                artistName: sample.artistName,
                artworkUrl100: sample.artworkUrl100,
                formattedPrice: "$2.99",
                price: 2.99,
                ipadScreenshotUrls: sample.ipadScreenshotUrls,
                averageUserRating: nil,
                userRatingCount: nil,
                description: sample.description,
                genres: ["Games", "Action"],
                bundleId: sample.bundleId,
                version: sample.version,
                releaseDate: sample.releaseDate,
                currentVersionReleaseDate: sample.currentVersionReleaseDate,
                fileSizeBytes: sample.fileSizeBytes,
                contentAdvisoryRating: sample.contentAdvisoryRating,
                artistId: sample.artistId,
                artistViewUrl: sample.artistViewUrl,
                screenshotUrls: sample.screenshotUrls,
                supportedDevices: sample.supportedDevices,
                minimumOsVersion: sample.minimumOsVersion,
                languageCodesISO2A: sample.languageCodesISO2A,
                trackContentRating: sample.trackContentRating,
                sellerName: sample.sellerName,
                currency: sample.currency,
                primaryGenreName: "Games",
                primaryGenreId: sample.primaryGenreId,
                isGameCenterEnabled: sample.isGameCenterEnabled,
                advisories: sample.advisories,
                features: sample.features,
                releaseNotes: sample.releaseNotes
            )
        }()) {
            print("Pro app download tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Compact Card") {
    VStack(spacing: 8) {
        DeveloperAppCompactCard(app: Result.sample) {
            print("Compact download tapped")
        }
        
        DeveloperAppCompactCard(app: Result.sample) {
            print("Compact download tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
#endif
