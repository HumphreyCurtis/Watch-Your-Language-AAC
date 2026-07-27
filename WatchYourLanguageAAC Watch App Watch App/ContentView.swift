//
//  ContentView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Home screen: the app's five main features, mirroring the iPhone app.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                // Line colours match the iPhone home screen, so a feature
                // keeps the same colour on both devices.
                NavigationLink {
                    PhrasesView()
                } label: {
                    PhraseRow(title: "Phrases", systemIcon: "text.bubble.fill", tint: TransportPalette.central)
                }

                NavigationLink {
                    KeywordsView()
                } label: {
                    PhraseRow(title: "Keywords", systemIcon: "key.fill", tint: TransportPalette.piccadilly)
                }

                NavigationLink {
                    BreatheView()
                } label: {
                    PhraseRow(title: "Breathing", systemIcon: "lungs", tint: TransportPalette.victoria)
                }

                NavigationLink {
                    AphasiaInfoView()
                } label: {
                    PhraseRow(title: "Aphasia", systemIcon: "person.fill.questionmark", tint: TransportPalette.district)
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    PhraseRow(title: "Settings", systemIcon: "gear", tint: TransportPalette.corporateGrey)
                }

                NavigationLink {
                    AboutView()
                } label: {
                    PhraseRow(title: "About", systemIcon: "info.circle.fill", tint: TransportPalette.elizabeth)
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
