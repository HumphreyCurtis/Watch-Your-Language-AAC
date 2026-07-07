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
                NavigationLink {
                    PhrasesView()
                } label: {
                    PhraseRow(title: "Phrases", systemIcon: "text.bubble.fill")
                }

                NavigationLink {
                    WordsView()
                } label: {
                    PhraseRow(title: "Words", systemIcon: "scroll.fill")
                }

                NavigationLink {
                    BreatheView()
                } label: {
                    PhraseRow(title: "Breathing", systemIcon: "lungs")
                }

                NavigationLink {
                    AphasiaInfoView()
                } label: {
                    PhraseRow(title: "Aphasia", systemIcon: "person.fill.questionmark")
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    PhraseRow(title: "Settings", systemIcon: "gear")
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
