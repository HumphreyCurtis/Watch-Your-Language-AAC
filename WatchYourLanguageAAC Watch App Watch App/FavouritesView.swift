//
//  FavouritesView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Recently used favourite words, most recent first, synced with the iPhone.
struct FavouritesView: View {
    @State private var searchText = ""

    private var favourites: FavouritesStore { .shared }

    private var searchResults: [String] {
        if searchText.isEmpty {
            return favourites.words
        }
        return favourites.words
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
    }

    var body: some View {
        List {
            if favourites.words.isEmpty {
                Text("Words you speak from the word finder appear here.")
                    .foregroundStyle(.secondary)
            }

            ForEach(searchResults, id: \.self) { word in
                NavigationLink {
                    WordDetailView(word: word)
                } label: {
                    Text(word)
                }
            }
            .onDelete { offsets in
                favourites.remove(atOffsets: offsets)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Favourites")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FavouritesView()
    }
}
