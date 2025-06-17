# MoPromoteKit

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**MoPromoteKit** is a powerful and easy-to-use Swift Package that helps iOS developers cross-promote their other apps. It fetches all apps from the same developer using the iTunes Search API and displays them with beautiful SwiftUI cards, featuring global ratings aggregation from 80+ countries.

## ✨ Features

- 🌍 **Global Ratings Aggregation** - Combines ratings from 80+ App Store regions for more accurate data
- 🎨 **Beautiful SwiftUI Cards** - Ready-to-use cards with SF Symbol category icons
- 🚀 **Performance Optimized** - Concurrent API calls for fast loading
- 🔧 **Highly Configurable** - Customize appearance, limits, and behavior
- 📱 **Multiple Card Styles** - Regular and compact layouts
- 🌐 **80+ Country Support** - All major App Store regions included
- 🧩 **Clean Architecture** - Modular, testable, and maintainable code
- 📋 **Zero Dependencies** - Lightweight package with no external dependencies

## 📱 Screenshots

*Add your screenshots here showing the cards in action*

## 🚀 Quick Start

### Installation

Add MoPromoteKit to your project using Swift Package Manager:

```
https://github.com/mkhasson97/MoPromoteKit.git
```

### Basic Usage

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

### 1. Settings Page Integration

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

### 2. Compact View for Smaller Spaces

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

### 3. Full-Screen Presentation

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

### 4. Programmatic Usage

Access the data programmatically for custom implementations:

```swift
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let apps = try await MoPromoteKit.fetchDeveloperApps(currentAppId: 1234567890)
                print("Found \(apps.results.count) apps")
                
                // Process the apps data
                for app in apps.results {
                    print("\(app.trackName): \(app.displayRating)⭐ (\(app.displayRatingCount) reviews)")
                }
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
}
```

### Predefined Configurations

```swift
// For settings pages
MoPromoteKit.configure(.forSettings)

// For compact displays
MoPromoteKit.configure(.compact)

// For full-screen displays
MoPromoteKit.configure(.fullScreen)
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

## 🎨 Customization

### Custom Card Styling

You can customize the appearance by modifying the configuration:

```swift
MoPromoteKit.configure { config in
    config.cardStyle = .compact
    config.maxApps = 5
    config.showTitle = false
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