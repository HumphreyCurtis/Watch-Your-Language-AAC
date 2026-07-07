//
//  WordsView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// The word tools: browse the vocabulary, revisit favourites, and grow the
/// finder. Mirrors the iPhone app's Words screen.
struct WordsView: View {
    var body: some View {
        List {
            NavigationLink {
                WordFinderView()
            } label: {
                PhraseRow(title: "Finder", systemIcon: "magnifyingglass")
            }

            NavigationLink {
                FavouritesView()
            } label: {
                PhraseRow(title: "Favourites", systemIcon: "heart.fill")
            }

            NavigationLink {
                AddWordView()
            } label: {
                PhraseRow(title: "Add Word", systemIcon: "pencil.tip.crop.circle.badge.plus")
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Words")
    }
}

#Preview {
    NavigationStack {
        WordsView()
    }
}
