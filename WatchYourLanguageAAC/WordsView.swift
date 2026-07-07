//
//  WordsView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The word tools: browse the vocabulary, revisit favourites, and grow the
/// finder. Mirrors the watch app's Words screen.
struct WordsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    WordFinderView()
                } label: {
                    Label("Finder", systemImage: "magnifyingglass")
                        .padding(.vertical, 4)
                }

                NavigationLink {
                    FavouritesView()
                } label: {
                    Label("Favourites", systemImage: "heart.fill")
                        .padding(.vertical, 4)
                }

                NavigationLink {
                    AddWordView()
                } label: {
                    Label("Add Word", systemImage: "pencil.tip.crop.circle.badge.plus")
                        .padding(.vertical, 4)
                }
            } header: {
                Text("Find, favourite and speak single words when a full phrase isn't needed.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .navigationTitle("Words")
    }
}

#Preview {
    NavigationStack {
        WordsView()
    }
}
