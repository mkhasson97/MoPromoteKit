//
//  AppStoreProductView.swift
//  MoPromoteKit
//
//  Created by Mohammad Alhasson on 01.04.26.
//

#if canImport(UIKit)
import SwiftUI
import StoreKit

/// A SwiftUI wrapper for SKStoreProductViewController that shows an App Store product page inline.
/// This keeps users inside the app instead of opening the App Store externally.
struct AppStoreProductView: UIViewControllerRepresentable {
    let appId: Int
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> SKStoreProductViewController {
        let controller = SKStoreProductViewController()
        controller.delegate = context.coordinator
        
        let parameters: [String: Any] = [
            SKStoreProductParameterITunesItemIdentifier: appId
        ]
        
        controller.loadProduct(withParameters: parameters) { success, error in
            if !success {
                // If loading fails, dismiss the sheet
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SKStoreProductViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, SKStoreProductViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
            dismiss()
        }
    }
}

/// View modifier that adds in-app App Store sheet presentation to any view.
/// Attach this to views that contain app cards to enable in-app product pages.
struct AppStoreSheetModifier: ViewModifier {
    @Binding var selectedApp: AppResult?
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $selectedApp) { app in
                AppStoreProductView(appId: app.trackId)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    /// Present an in-app App Store sheet for the selected app
    func appStoreSheet(selectedApp: Binding<AppResult?>) -> some View {
        modifier(AppStoreSheetModifier(selectedApp: selectedApp))
    }
}
#endif
