//
//  WatchYourLanguageAAC_Watch_AppApp.swift
//  WatchYourLanguageAAC Watch App Watch App
//
//  Created by Humphrey Curtis on 06/07/2026.
//

import SwiftUI

@main
struct WatchYourLanguageAAC_Watch_App_Watch_AppApp: App {
    init() {
        // Before any view renders, or the first screens draw in the system font.
        AppFont.registerIfNeeded()

        // Create the stores at launch so WatchConnectivity activates and
        // edits made on the phone arrive even if a screen is never opened.
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
