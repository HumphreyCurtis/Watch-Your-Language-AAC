//
//  WordDetailView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Shows a single word large enough to read across a table; tap to speak it.
/// Speaking a word records it in the synced favourites list.
struct WordDetailView: View {
    let word: String

    var body: some View {
        Text(word)
            .font(.title)
            .fontWeight(.bold)
            .minimumScaleFactor(0.5)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                Speaker.shared.speak(word)
                FavouritesStore.shared.noteUsed(word)
            }
    }
}

#Preview {
    NavigationStack {
        WordDetailView(word: "aphasia")
    }
}
