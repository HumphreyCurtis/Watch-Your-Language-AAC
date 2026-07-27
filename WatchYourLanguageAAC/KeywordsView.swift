//
//  KeywordsView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The user's keywords — names, addresses, place names — most recently used
/// first, synced with the watch. Keywords can be added, spoken, and removed
/// from here.
struct KeywordsView: View {
    @State private var newKeyword = ""

    private var keywords: KeywordsStore { .shared }

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Add a name, address or place", text: $newKeyword)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .onSubmit(addKeyword)

                    Button("Add", action: addKeyword)
                        .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            } header: {
                PlatformHeader(text: "Your words", tint: TransportPalette.piccadilly)
            }

            Section {
                ForEach(keywords.words, id: \.self) { word in
                    Button {
                        Speaker.shared.speak(word)
                    } label: {
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(TransportPalette.piccadilly.color)
                                .frame(width: 4, height: 22)
                            Text(word)
                                .font(.appBody)
                        }
                    }
                    .tint(.primary)
                }
                .onDelete { offsets in
                    keywords.remove(atOffsets: offsets)
                }
            } footer: {
                Text(keywords.words.isEmpty
                     ? "Names, addresses, places — ready on your watch."
                     : "Tap to speak.")
                    .font(.appFootnote)
            }
        }
        .signageSurface()
        .navigationTitle("Keywords")
    }

    private func addKeyword() {
        keywords.noteUsed(newKeyword)
        newKeyword = ""
    }
}

#Preview {
    NavigationStack {
        KeywordsView()
    }
}
