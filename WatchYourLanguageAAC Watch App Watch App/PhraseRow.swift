//
//  PhraseRow.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Standard list row: roundel badge and title, sized for glanceability.
struct PhraseRow: View {
    let title: String
    let systemIcon: String
    var emoji: String?
    var tint: SignageColor = TransportPalette.roundelBlue

    var body: some View {
        HStack(spacing: 10) {
            RoundelBadge(systemIcon: systemIcon, emoji: emoji, tint: tint, size: 30)

            Text(title)
                .font(.appTitle2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    PhraseRow(title: "Phrases", systemIcon: "text.bubble.fill", tint: TransportPalette.central)
}
