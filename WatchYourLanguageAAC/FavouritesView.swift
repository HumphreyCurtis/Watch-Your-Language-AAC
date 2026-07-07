//
//  FavouritesView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The favourite words list, synced with the watch. Words can be added,
/// removed, and spoken from here; changes appear on the watch and vice versa.
struct FavouritesView: View {
    @State private var newWord = ""

    private var favourites: FavouritesStore { .shared }

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Add a word", text: $newWord)
                        .autocorrectionDisabled()
                        .onSubmit(addWord)

                    Button("Add", action: addWord)
                        .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section {
                ForEach(favourites.words, id: \.self) { word in
                    Button {
                        Speaker.shared.speak(word)
                    } label: {
                        Text(word)
                    }
                    .tint(.primary)
                }
                .onDelete { offsets in
                    favourites.remove(atOffsets: offsets)
                }
            } footer: {
                if favourites.words.isEmpty {
                    Text("Words you speak on the watch appear here, and words you add here appear on the watch.")
                } else {
                    Text("Tap a word to speak it. Synced with your Apple Watch.")
                }
            }
        }
        .navigationTitle("Favourites")
    }

    private func addWord() {
        favourites.noteUsed(newWord)
        newWord = ""
    }
}

#Preview {
    NavigationStack {
        FavouritesView()
    }
}
