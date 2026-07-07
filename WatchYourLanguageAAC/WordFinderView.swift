//
//  WordFinderView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Browse the vocabulary by first letter and tap a word to speak it,
/// mirroring the watch's word finder.
struct WordFinderView: View {
    @State private var selectedLetter = "a"

    private var wordList: WordListStore { .shared }

    private static let alphabet = (UnicodeScalar("a").value...UnicodeScalar("z").value)
        .compactMap { UnicodeScalar($0).map(String.init) }

    private var matchingWords: [String] {
        wordList.allWords
            .filter { $0.lowercased().hasPrefix(selectedLetter) }
            .sorted()
    }

    var body: some View {
        List {
            Section {
                Picker("Word starts with:", selection: $selectedLetter) {
                    ForEach(Self.alphabet, id: \.self) {
                        Text($0)
                    }
                }

                ForEach(matchingWords, id: \.self) { word in
                    Button {
                        Speaker.shared.speak(word)
                        FavouritesStore.shared.noteUsed(word)
                    } label: {
                        Text(word)
                    }
                    .tint(.primary)
                }
            } footer: {
                Text("Tap a word to speak it aloud and add it to your favourites.")
            }
        }
        .navigationTitle("Finder")
    }
}

#Preview {
    NavigationStack {
        WordFinderView()
    }
}
