//
//  WatchYourLanguageAACApp.swift
//  WatchYourLanguageAAC
//
//  Created by Humphrey Curtis on 06/07/2026.
//

import SwiftUI

@main
struct WatchYourLanguageAACApp: App {
    init() {
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
}
