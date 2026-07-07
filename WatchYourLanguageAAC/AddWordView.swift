//
//  AddWordView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Adds a word to the word finder's vocabulary; new words sync to the watch.
struct AddWordView: View {
    @State private var text = ""
    @State private var confirmation: String?

    private var wordList: WordListStore { .shared }

    var body: some View {
        Form {
            Section {
                TextField("Input word", text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit(addWord)

                Button("Add", action: addWord)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            } header: {
                Text("Add word to finder")
            } footer: {
                if let confirmation {
                    Text(confirmation)
                } else {
                    Text("New words appear in the finder on both this phone and your watch.")
                }
            }
        }
        .navigationTitle("Add Word")
    }

    private func addWord() {
        let word = text
        confirmation = wordList.add(word) ? "Added \"\(word)\"" : "Already in finder"
        text = ""
    }
}

#Preview {
    NavigationStack {
        AddWordView()
    }
}
