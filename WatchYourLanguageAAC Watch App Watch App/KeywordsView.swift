//
//  KeywordsView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// The user's keywords — names, addresses, place names — most recently used
/// first, synced with the iPhone. Tap one to show it large and speak it.
struct KeywordsView: View {
    @State private var searchText = ""

    private var keywords: KeywordsStore { .shared }

    private var searchResults: [String] {
        if searchText.isEmpty {
            return keywords.words
        }
        return keywords.words
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .sorted()
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    AddKeywordView()
                } label: {
                    PhraseRow(title: "Add Keyword", systemIcon: "plus.circle.fill", tint: TransportPalette.district)
                }
            }

            Section {
                if keywords.words.isEmpty {
                    Text("Store the words that matter — names, addresses, places. Synced with your iPhone.")
                        .font(.appFootnote)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                }

                ForEach(searchResults, id: \.self) { word in
                    NavigationLink {
                        KeywordDetailView(word: word)
                    } label: {
                        Text(word)
                            .font(.appBody)
                    }
                }
                .onDelete { offsets in
                    keywords.remove(atOffsets: offsets)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Keywords")
    }
}

#Preview {
    NavigationStack {
        KeywordsView()
    }
}
