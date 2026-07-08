//
//  KeywordDetailView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Shows a single keyword large enough to read across a table — a name, an
/// address, a place — and speaks it on tap. Speaking a keyword moves it to
/// the front of the synced list.
struct KeywordDetailView: View {
    let word: String

    var body: some View {
        Text(word)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.3)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                Speaker.shared.speak(word)
                KeywordsStore.shared.noteUsed(word)
            }
    }
}

#Preview {
    NavigationStack {
        KeywordDetailView(word: "12 Baker Street")
    }
}
