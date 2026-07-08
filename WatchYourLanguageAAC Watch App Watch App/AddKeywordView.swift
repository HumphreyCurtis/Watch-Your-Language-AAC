//
//  AddKeywordView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Adds a keyword — a name, address or place name — synced to the iPhone.
struct AddKeywordView: View {
    @State private var text = ""
    @State private var confirmation: String?

    private var keywords: KeywordsStore { .shared }

    var body: some View {
        VStack {
            Text("Add a keyword:")

            TextField("Name, address, place…", text: $text)
                .autocorrectionDisabled()

            Button("Add") {
                let word = text.trimmingCharacters(in: .whitespacesAndNewlines)
                keywords.noteUsed(word)
                confirmation = "Added \"\(word)\""
                text = ""
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)

            if let confirmation {
                Text(confirmation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Add Keyword")
    }
}

#Preview {
    NavigationStack {
        AddKeywordView()
    }
}
