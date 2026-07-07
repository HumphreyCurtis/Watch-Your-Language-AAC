//
//  PhrasesView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// The phrase library, mirroring the iPhone app's Phrases screen.
/// Phrases are edited on the iPhone and sync automatically.
struct PhrasesView: View {
    private var store: PhraseStore { .shared }

    var body: some View {
        List {
            Section {
                ForEach(store.phrases) { phrase in
                    NavigationLink {
                        DetailView(phrase: phrase)
                    } label: {
                        PhraseRow(title: phrase.label, systemIcon: phrase.systemIcon, emoji: phrase.emoji)
                    }
                }
            } footer: {
                Text("Add and edit phrases in the iPhone app.")
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Phrases")
    }
}

#Preview {
    NavigationStack {
        PhrasesView()
    }
}
