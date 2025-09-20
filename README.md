# MoPromoteKit
<div align="center">
<img src="https://github.com/user-attachments/assets/92d23a4b-e681-4786-9683-1795fcf53138" width="300" alt="Before">
</div>
  
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**MoPromoteKit** is a powerful and easy-to-use Swift Package that helps iOS developers cross-promote their other apps. It fetches all apps from the same developer using the iTunes Search API and displays them with beautiful SwiftUI cards, featuring global ratings aggregation from 80+ countries.

## ✨ Features

- 🌍 **Global Ratings Aggregation** - Combines ratings from 80+ App Store regions for more accurate data
- 🎯 **Manual App Selection** - Promote specific apps by their IDs for curated collections
- 🎨 **Beautiful SwiftUI Cards** - Ready-to-use cards with SF Symbol category icons
- 👤 **Developer Profile Images** - Add developer avatars from URLs or local assets
- 🔀 **Hybrid Promotion** - Combine featured apps with automatic developer discovery
- 🚀 **Performance Optimized** - Concurrent API calls for fast loading
- 🔧 **Highly Configurable** - Customize appearance, limits, and behavior
- 📱 **Multiple Card Styles** - Regular, compact, and featured layouts
- 📊 **Analytics Insights** - Built-in analytics for app performance tracking
- 🌐 **80+ Country Support** - All major App Store regions included
- 🧩 **Clean Architecture** - Modular, testable, and maintainable code
- 📋 **Zero Dependencies** - Lightweight package with no external dependencies

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center">
        <h3>Full</h3>
        <img src="https://github.com/user-attachments/assets/42a371ba-36c7-4093-be84-b2da7797115f" width="200" alt="Before">
      </td>
      <td align="center">
        <h3>Compact</h3>
        <img src="https://github.com/user-attachments/assets/08692ce6-25db-4be2-ac12-b3ffba42325e" width="200" alt="After">
      </td>
    </tr>
  </table>
</div>

## 🚀 Quick Start

## 🚀 Installation

### Swift Package Manager

#### Xcode

1. **File → Add Package Dependencies**
2. **Enter URL**: `https://github.com/mkhasson97/MoPromoteKit.git`
3. **Add Package**

#### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/mkhasson97/MoPromoteKit", from: "1.0.0")
]
```

## 💡 Usage

### Basic Example

```swift
import SwiftUI
import MoPromoteKit

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Your existing settings content
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Add developer apps section
                MoPromoteKit.developerAppsView(currentAppId: 1234567890)
            }
        }
    }
}
```

### Configuration

Configure MoPromoteKit globally in your App file:

```swift
import SwiftUI
import MoPromoteKit

@main
struct MyApp: App {
    init() {
        // Configure MoPromoteKit
        MoPromoteKit.configure { config in
            config.maxApps = 6
            config.cardStyle = .regular
            config.showTitle = true
            config.countryCode = "us" // Optional: force specific country
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## 📖 Usage Examples

### 1. Auto-Discovery (Original Feature)

Perfect for adding a "More Apps" section to your settings:

```swift
struct SettingsView: View {
    var body: some View {
        List {
            Section("General") {
                // Your settings
            }
            
            Section {
                MoPromoteKit.developerAppsView(currentAppId: 1234567890)
            } header: {
                Text("More Apps")
            }
        }
    }
}
```

### 2. Manual App Selection (New!)

Promote specific apps by their IDs for curated collections:

```swift
struct FeaturedAppsView: View {
    var body: some View {
        ScrollView {
            // Manually select which apps to promote
            MoPromoteKit.manualAppsView(appIds: [
                1234567890,  // Your productivity app
                9876543210,  // Your game
                5555555555   // Your utility app
            ])
        }
    }
}
```

### 3. Hybrid Approach (New!)

Combine featured apps with automatic developer discovery:

```swift
struct RecommendedAppsView: View {
    var body: some View {
        ScrollView {
            MoPromoteKit.hybridAppsView(
                featuredAppIds: [1234567890, 9876543210], // Featured prominently
                currentAppId: 5555555555,                  // Your current app
                maxAdditional: 3                           // Max additional developer apps
            )
        }
    }
}
```

### 4. Developer Profile Integration (New!)

Add developer profile images to enhance branding:

```swift
struct SettingsView: View {
    var body: some View {
        ScrollView {
            // With URL profile image
            DeveloperAppsView.forSettings(
                currentAppId: 1234567890,
                developerProfile: .url("https://yoursite.com/developer-avatar.jpg")
            )
            
            // Or with local asset
            DeveloperAppsView.forSettings(
                currentAppId: 1234567890,
                developerProfile: .asset("developer_avatar")
            )
        }
    }
}
```

### 5. Compact View for Smaller Spaces

Use the compact style for sidebars or smaller sections:

```swift
struct SidebarView: View {
    var body: some View {
        VStack {
            // Main content
            
            MoPromoteKit.compactDeveloperAppsView(
                currentAppId: 1234567890,
                maxApps: 3
            )
        }
    }
}
```

### 6. Full-Screen Presentation

For dedicated "More Apps" screens:

```swift
struct MoreAppsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                MoPromoteKit.fullScreenDeveloperAppsView(currentAppId: 1234567890)
                    .padding()
            }
            .navigationTitle("More Apps")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

### 7. Advanced Configuration (New!)

Exclude specific apps and customize sorting:

```swift
struct CustomAppsView: View {
    var body: some View {
        ScrollView {
            DeveloperAppsView(
                currentAppId: 1234567890,
                excludeAppIds: [9999999999], // Exclude competitor or deprecated apps
                maxApps: 8,
                cardStyle: .featured,
                sortingOrder: .rating,       // Sort by highest rated
                showAnalytics: true,         // Show analytics cards
                developerProfile: .url("https://yoursite.com/avatar.jpg", size: 50)
            )
        }
    }
}
```

### 8. Programmatic Usage & Analytics (Enhanced!)

Access the data programmatically for custom implementations:

```swift
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                // Fetch specific apps
                let specificApps = try await MoPromoteKit.fetchApps(appIds: [
                    1234567890, 9876543210, 5555555555
                ])
                
                // Fetch all developer apps with exclusions
                let developerApps = try await MoPromoteKit.fetchDeveloperApps(
                    currentAppId: 1234567890,
                    excludeAppIds: [9999999999],
                    includeCurrentApp: false
                )
                
                // Get promotion insights
                let insights = await MoPromoteKit.getPromotionInsights(appIds: [
                    1234567890, 9876543210, 5555555555
                ])
                
                print("Total download potential: \(insights.totalDownloadPotential)")
                print("Average rating: \(insights.averageRating)")
                print("Top performing app: \(insights.topPerformingApp?.trackName ?? "None")")
                print("Recommended order: \(insights.recommendedPromotionOrder)")
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

## ⚙️ Configuration Options

### MoPromoteKit.Configuration

```swift
public struct Configuration {
    /// Maximum number of apps to display (default: 10)
    public var maxApps: Int = 10
    
    /// Country code for App Store region (default: auto-detected)
    public var countryCode: String?
    
    /// Whether to show the "More Apps" title (default: true)
    public var showTitle: Bool = true
    
    /// Card display style (default: .regular)
    public var cardStyle: CardStyle = .regular
    
    /// Enable global ratings aggregation (default: true)
    public var enableGlobalRatings: Bool = true
    
    /// Cache duration for search results in seconds (default: 300)
    public var cacheDuration: TimeInterval = 300
    
    /// App selection mode (default: .allFromDeveloper)
    public var appSelectionMode: AppSelectionMode = .allFromDeveloper(currentAppId: 0)
    
    /// Sorting order for apps (default: .alphabetical)
    public var sortingOrder: SortingOrder = .alphabetical
    
    /// Custom title override
    public var customTitle: String?
}
```

### Card Styles (Enhanced!)

```swift
public enum CardStyle {
    case regular   // Standard detailed cards
    case compact   // Smaller cards for tight spaces
    case featured  // Large prominent cards with descriptions
}
```

### Sorting Options (New!)

```swift
public enum SortingOrder {
    case alphabetical  // Sort by app name A-Z
    case rating       // Sort by highest rating first
    case releaseDate  // Sort by newest first
    case downloads    // Sort by most reviews/downloads
    case random       // Random shuffle
    case custom([Int]) // Custom order by app IDs
}
```

### App Selection Modes (New!)

```swift
public enum AppSelectionMode {
    case allFromDeveloper(currentAppId: Int)
    case manual(appIds: [Int])
    case hybrid(featuredAppIds: [Int], currentAppId: Int, maxAdditional: Int)
}
```

### Quick Configurations

```swift
// Manual app promotion
MoPromoteKit.configureForManualPromotion(
    appIds: [1234567890, 9876543210],
    title: "Our Best Apps",
    cardStyle: .featured
)

// Hybrid promotion
MoPromoteKit.configureForHybridPromotion(
    featuredAppIds: [1234567890, 9876543210],
    currentAppId: 5555555555,
    maxAdditional: 3
)

// Predefined configurations
MoPromoteKit.configure(.forSettings)  // For settings pages
MoPromoteKit.configure(.compact)      // For compact displays
MoPromoteKit.configure(.fullScreen)   // For full-screen displays
```

## 🌍 Global Ratings Feature

MoPromoteKit's standout feature is global ratings aggregation. Instead of showing ratings from just one country, it:

1. **Fetches ratings from 30+ major markets** concurrently
2. **Calculates weighted averages** based on review counts
3. **Shows total global review counts** for better social proof
4. **Provides more accurate ratings** especially for international apps

### Debug Global Ratings

You can debug the global ratings feature:

```swift
Task {
    let debug = await MoPromoteKit.debugGlobalRatings(appId: 1234567890)
    print(debug)
}
```

Output example:
```
🌍 Global Ratings Analysis for App ID: 1234567890
==================================================

📊 Summary:
   • Total Reviews: 45,234
   • Weighted Average: 4.3⭐
   • Markets with data: 28/30

🌟 Top Markets:
   1. 4.5⭐ (12,543 reviews)
   2. 4.4⭐ (8,921 reviews)
   3. 4.2⭐ (6,432 reviews)
   ...
```

## 👤 Developer Profile Images (New!)

Add professional developer branding with profile images:

### From URL
```swift
DeveloperAppsView.forSettings(
    currentAppId: 1234567890,
    developerProfile: .url("https://yoursite.com/developer-avatar.jpg")
)
```

### From Local Assets
```swift
DeveloperAppsView.forSettings(
    currentAppId: 1234567890,
    developerProfile: .asset("developer_avatar") // Image in your app bundle
)
```

### Custom Size
```swift
DeveloperAppsView.forSettings(
    currentAppId: 1234567890,
    developerProfile: .url("https://yoursite.com/avatar.jpg", size: 60)
)
```

## 📊 Analytics & Insights (New!)

Get detailed insights about your app promotion performance:

```swift
let insights = await MoPromoteKit.getPromotionInsights(appIds: [
    1234567890, 9876543210, 5555555555
])

// Access insights data
print("Total reviews across all apps: \(insights.totalDownloadPotential)")
print("Combined average rating: \(insights.averageRating)")
print("Best performing app: \(insights.topPerformingApp?.trackName ?? "None")")
print("Categories represented: \(insights.categoryBreakdown)")
print("Recommended promotion order: \(insights.recommendedPromotionOrder)")
```

## 🎨 Customization

### Custom Card Styling

You can customize the appearance by modifying the configuration:

```swift
MoPromoteKit.configure { config in
    config.cardStyle = .featured
    config.maxApps = 5
    config.showTitle = false
    config.sortingOrder = .rating
}
```

### SwiftUI Modifiers

Use the convenience modifier for quick integration:

```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Welcome")
            // Other content
        }
        .withDeveloperApps(currentAppId: 1234567890)
    }
}
```

## 📊 Supported Countries

MoPromoteKit supports 80+ App Store regions including:

**Major Markets:** US, UK, Canada, Australia, Germany, France, Italy, Spain, Netherlands, Sweden, Norway, Denmark, Finland, Japan, South Korea, China, Hong Kong, Taiwan, Singapore, India, Brazil, Mexico...

**Complete list available via:**
```swift
let countries = MoPromoteKit.supportedCountries
let majorMarkets = MoPromoteKit.majorMarkets
```

## 🔧 Requirements

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## 📝 How to Get Your App ID

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **App Information**
4. Find **Apple ID** (e.g., 1234567890)

Or extract it from your App Store URL:
```
https://apps.apple.com/app/id1234567890
                              ↑
                         This is your App ID
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

MoPromoteKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

```
MIT License

Copyright (c) 2025 Mohammad Alhasson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Author

**Mohammad Alhasson**

- Website: [mkhasson97.com](https://mkhasson97.com)
- GitHub: [@mkhasson97](https://github.com/mkhasson97)
- X: [@mkhasson97](https://x.com/mkhasson97)

## 🙏 Acknowledgments

- Apple's iTunes Search API
- SF Symbols for beautiful category icons
- The iOS developer community for feedback and suggestions

## 📊 Usage Stats

If you're using MoPromoteKit in your project, I'd love to hear about it! Feel free to:

- ⭐ Star this repository
- 🐛 Report issues
- 💡 Suggest new features
- 📢 Share your implementations

---

**Made with ❤️ in Swift**

**Made with ❤️ for the iOS developer community**
