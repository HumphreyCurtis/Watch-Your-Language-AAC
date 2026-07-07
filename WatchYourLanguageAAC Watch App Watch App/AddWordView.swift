//
//  AddWordView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Adds a word to the word finder's vocabulary.
struct AddWordView: View {
    @State private var text = ""
    @State private var confirmation: String?

    private let wordList = WordListStore.shared

    var body: some View {
        VStack {
            Text("Add word to finder:")

            TextField("Input word", text: $text)
                .autocorrectionDisabled()

            Button("Add") {
                let word = text
                confirmation = wordList.add(word) ? "Added \"\(word)\"" : "Already in finder"
                text = ""
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)

            if let confirmation {
                Text(confirmation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Add Word")
    }
}

#Preview {
    NavigationStack {
        AddWordView()
    }
}
