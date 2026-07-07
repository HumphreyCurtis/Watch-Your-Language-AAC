//
//  WordFinderView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Browse the vocabulary by first letter and open a word to speak it.
struct WordFinderView: View {
    @State private var selectedLetter = "a"

    private let wordList = WordListStore.shared

    private static let alphabet = (UnicodeScalar("a").value...UnicodeScalar("z").value)
        .compactMap { UnicodeScalar($0).map(String.init) }

    private var matchingWords: [String] {
        wordList.allWords
            .filter { $0.lowercased().hasPrefix(selectedLetter) }
            .sorted()
    }

    var body: some View {
        List {
            Picker("Word starts with:", selection: $selectedLetter) {
                ForEach(Self.alphabet, id: \.self) {
                    Text($0)
                }
            }

            ForEach(matchingWords, id: \.self) { word in
                NavigationLink {
                    WordDetailView(word: word)
                } label: {
                    Text(word)
                }
            }
        }
        .navigationTitle("Finder")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WordFinderView()
    }
}
