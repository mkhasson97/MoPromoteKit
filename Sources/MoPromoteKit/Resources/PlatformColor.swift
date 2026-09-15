//
//  PlatformColor.swift
//  MoPromoteKit
//
//  Cross-platform system colors so the same views build on iOS and macOS.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    /// Primary surface color (cards, sheets).
    static var moBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .textBackgroundColor)
        #endif
    }
    
    /// Secondary surface color, one step behind ``moBackground``.
    static var moSecondaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }
    
    /// Tertiary surface color, used for inline chips and badges.
    static var moTertiaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .tertiarySystemBackground)
        #else
        Color(nsColor: .underPageBackgroundColor)
        #endif
    }
    
    /// Page background behind grouped content.
    static var moGroupedBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    /// Hairline separator / border color.
    static var moSeparator: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemGray5)
        #else
        Color(nsColor: .separatorColor)
        #endif
    }
}
