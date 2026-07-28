//
//  PhrasesView.swift
//  WatchYourLanguageAAC Watch App
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
                        // Each roundel takes its phrase's own screen colour,
                        // so the list previews what the reader will see.
                        PhraseRow(
                            title: phrase.label,
                            systemIcon: phrase.systemIcon,
                            emoji: phrase.emoji,
                            tint: PhraseColor.signageColor(named: phrase.colorName)
                        )
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
