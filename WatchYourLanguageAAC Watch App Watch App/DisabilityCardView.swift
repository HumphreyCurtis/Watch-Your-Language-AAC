//
//  DisabilityCardView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// A full-screen blue "card" the wearer can hold up to signal a disability,
/// echoing the blue disability badge/card.
struct DisabilityCardView: View {
    var body: some View {
        Image(systemName: PhraseLibrary.disabilityCardIcon)
            .resizable()
            .scaledToFit()
            .padding(.top, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue)
    }
}

#Preview {
    DisabilityCardView()
}
