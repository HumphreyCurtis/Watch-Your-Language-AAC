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
        HStack(spacing: 8) {
            // Smaller than the title deserves, because the title matters
            // more: the badge gives up room so the larger type fits without
            // shrinking back to where it started.
            RoundelBadge(systemIcon: systemIcon, emoji: emoji, tint: tint, size: 26)

            Text(title)
                .font(.appTitle2)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    PhraseRow(title: "Phrases", systemIcon: "text.bubble.fill", tint: TransportPalette.central)
}
