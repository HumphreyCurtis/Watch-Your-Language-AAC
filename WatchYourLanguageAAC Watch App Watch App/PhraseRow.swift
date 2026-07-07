//
//  PhraseRow.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Standard list row: large icon and title, sized for glanceability.
struct PhraseRow: View {
    let title: String
    let systemIcon: String
    var emoji: String?

    var body: some View {
        Label {
            Text(title)
                .font(.title2)
                .lineLimit(1)
        } icon: {
            if let emoji {
                Text(emoji)
                    .font(.system(size: 26))
            } else {
                Image(systemName: systemIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            }
        }
        .padding(5)
    }
}

#Preview {
    PhraseRow(title: "Phrases", systemIcon: "text.bubble.fill")
}
