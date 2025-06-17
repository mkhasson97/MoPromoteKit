//
//  CategoryIcons.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 17.06.25.
//


import Foundation

public struct CategoryIcons {
    
    // MARK: - App Categories
    private static let appCategories: [String: String] = [
        "Books": "book.closed",
        "Business": "briefcase.fill",
        "Developer Tools": "hammer.fill",
        "Education": "graduationcap.fill",
        "Entertainment": "theatermasks.fill",
        "Finance": "dollarsign.circle.fill",
        "Food & Drink": "fork.knife",
        "Games": "gamecontroller.fill",
        "Graphics & Design": "swatchpalette.fill",
        "Health & Fitness": "heart.fill",
        "Lifestyle": "leaf.fill",
        "Magazines & Newspapers": "magazine", //Check
        "Medical": "cross.case.fill",
        "Music": "music.note",
        "Navigation": "location.north.line.fill",
        "News": "newspaper.fill",
        "Photo & Video": "photo.on.rectangle.angled",
        "Productivity": "paperplane.fill",
        "Reference": "quote.bubble.fill",
        "Shopping": "cart.fill", //Check
        "Social Networking": "bubble.left.and.bubble.right.fill",
        "Sports": "sportscourt.fill",
        "Stickers": "face.smiling",
        "Travel": "airplane",
        "Utilities": "wrench.and.screwdriver",
        "Weather": "cloud.sun.fill"
    ]
    
    // MARK: - Game Subcategories
    
    private static let gameSubcategories: [String: String] = [
        "Action": "burst.fill",
        "Adventure": "map.fill",
        "Arcade": "gamecontroller.fill",
        "Board": "checkerboard.rectangle",
        "Card": "rectangle.on.rectangle.angled",
        "Casino": "die.face.5.fill",
        "Casual": "face.smiling",
        "Dice": "die.face.6.fill",
        "Educational": "text.book.closed.fill",
        "Family": "person.3.fill",
        "Music": "music.note.list",
        "Puzzle": "puzzlepiece.fill",
        "Racing": "car.fill",
        "Role Playing": "person.crop.rectangle",
        "Simulation": "cube.fill",
        "Sports": "sportscourt.fill",
        "Strategy": "brain.head.profile",
        "Trivia": "questionmark.circle.fill",
        "Word": "textformat",
        "Books": "books.vertical.fill",
        "Business": "briefcase.fill",
        "Developer Tools": "wrench.and.screwdriver.fill",
        "Education": "graduationcap.fill",
        "Entertainment": "popcorn.fill",
        "Finance": "creditcard.fill",
        "Food & Drink": "fork.knife",
        "Graphics & Design": "paintpalette.fill",
        "Health & Fitness": "figure.run",
        "Kids": "balloon.2.fill",
        "Lifestyle": "chair.fill",
        "Magazines & Newspapers": "magazine.fill",
        "Medical": "cross.case.fill",
        "Navigation": "location.north.circle.fill",
        "News": "newspaper",
        "Photo & Video": "camera.fill",
        "Productivity": "paperplane.fill",
        "Reference": "quote.bubble.fill",
        "Shopping": "bag.fill",
        "Social Networking": "bubble.left.and.bubble.right.fill",
        "Travel": "airplane",
        "Utilities": "slider.horizontal.3",
        "Weather": "cloud.sun.fill"
    ]
    
    // MARK: - Public Methods
    
    /// Get SF Symbol name for a category
    public static func iconForCategory(_ category: String) -> String {
        // First check game subcategories
        if let gameIcon = gameSubcategories[category] {
            return gameIcon
        }
        
        // Then check app categories
        if let appIcon = appCategories[category] {
            return appIcon
        }
        
        // Fallback for unknown categories
        return "app.fill"
    }
    
    /// Check if category has a custom icon
    public static func hasIcon(for category: String) -> Bool {
        return appCategories.keys.contains(category) || gameSubcategories.keys.contains(category)
    }
    
    /// Get all available app categories
    public static var allAppCategories: [String] {
        return Array(appCategories.keys).sorted()
    }
    
    /// Get all available game subcategories
    public static var allGameSubcategories: [String] {
        return Array(gameSubcategories.keys).sorted()
    }
    
    /// Get category with icon info
    public static func categoryInfo(for category: String) -> (name: String, icon: String, isGame: Bool) {
        let icon = iconForCategory(category)
        let isGame = gameSubcategories.keys.contains(category)
        return (category, icon, isGame)
    }
}
