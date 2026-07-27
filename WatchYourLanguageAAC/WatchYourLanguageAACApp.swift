//
//  WatchYourLanguageAACApp.swift
//  WatchYourLanguageAAC
//
//  Created by Humphrey Curtis on 06/07/2026.
//

import SwiftUI
import UIKit

@main
struct WatchYourLanguageAACApp: App {
    init() {
        // Before any view renders, or the first screens draw in the system font.
        AppFont.registerIfNeeded()

        // Must follow registration — `UIFont(name:)` cannot find Atkinson
        // until Core Text knows about it.
        Self.configureNavigationBarAppearance()

        // Create the stores at launch so WatchConnectivity activates and
        // edits made on the watch arrive even if a screen is never opened.
        _ = PhraseStore.shared
        _ = KeywordsStore.shared
        _ = SettingsStore.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    /// Puts the navigation bar's title into Atkinson.
    ///
    /// SwiftUI offers no way to restyle a system navigation title, so this
    /// goes through `UINavigationBarAppearance` — one configuration covers
    /// the app, which has a single `NavigationStack` plus the phrase-editor
    /// sheet. Screens ask for `.inline` titles, which the system centres;
    /// large titles are always left-aligned and cannot be moved.
    ///
    /// If the font is missing the bar is left alone and the system font
    /// stands in, matching how `AppFont` already treats registration failure.
    private static func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Resolved through `TransportPalette` rather than restating the hex,
        // so the bar cannot drift away from the surface under it.
        appearance.backgroundColor = UIColor { traits in
            UIColor(TransportPalette.surface(traits.userInterfaceStyle == .dark ? .dark : .light))
        }

        if let inline = UIFont(name: AppFont.bold, size: 17) {
            appearance.titleTextAttributes = [
                // Scaled, so someone running large type gets a large title
                // bar too rather than the one piece of frozen text.
                .font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: inline)
            ]
        }

        if let large = UIFont(name: AppFont.bold, size: 34) {
            appearance.largeTitleTextAttributes = [
                .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large)
            ]
        }

        let bar = UINavigationBar.appearance()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
    }
}
