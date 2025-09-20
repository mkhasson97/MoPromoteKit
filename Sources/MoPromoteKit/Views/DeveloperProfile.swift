//
//  DeveloperProfile.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 20.09.25.
//

import SwiftUI

public struct DeveloperProfile {
    public enum ImageSource {
        case url(String)
        case asset(String)
        case none
    }
    
    public let imageSource: ImageSource
    public let showImage: Bool
    public let imageSize: CGFloat
    
    public init(
        imageSource: ImageSource = .none,
        showImage: Bool = true,
        imageSize: CGFloat = 40
    ) {
        self.imageSource = imageSource
        self.showImage = showImage
        self.imageSize = imageSize
    }
    
    // Convenience initializers
    public static func url(_ urlString: String, size: CGFloat = 40) -> DeveloperProfile {
        DeveloperProfile(imageSource: .url(urlString), imageSize: size)
    }
    
    public static func asset(_ imageName: String, size: CGFloat = 40) -> DeveloperProfile {
        DeveloperProfile(imageSource: .asset(imageName), imageSize: size)
    }
    
    public static var none: DeveloperProfile {
        DeveloperProfile(imageSource: .none, showImage: false)
    }
}

// MARK: - Developer Profile Image View

public struct DeveloperProfileImageView: View {
    let profile: DeveloperProfile
    
    public var body: some View {
        Group {
            switch profile.imageSource {
            case .url(let urlString):
                AsyncImage(url: URL(string: urlString)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: profile.imageSize * 0.4))
                        )
                }
                .frame(width: profile.imageSize, height: profile.imageSize)
                .clipShape(Circle())
                
            case .asset(let imageName):
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: profile.imageSize, height: profile.imageSize)
                    .clipShape(Circle())
                
            case .none:
                EmptyView()
            }
        }
    }
}
