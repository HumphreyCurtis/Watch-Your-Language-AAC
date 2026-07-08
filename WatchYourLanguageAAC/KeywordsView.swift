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
                Text("Store the words that matter — your street, a family name, a place — ready to show and speak from the watch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Section {
                ForEach(keywords.words, id: \.self) { word in
                    Button {
                        Speaker.shared.speak(word)
                    } label: {
                        Text(word)
                    }
                    .tint(.primary)
                }
                .onDelete { offsets in
                    keywords.remove(atOffsets: offsets)
                }
            } footer: {
                if keywords.words.isEmpty {
                    Text("Keywords you add here or speak on the watch appear on both devices.")
                } else {
                    Text("Tap a keyword to speak it. Synced with your Apple Watch.")
                }
            }
        }
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
