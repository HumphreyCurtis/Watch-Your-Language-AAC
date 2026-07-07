//
//  PhrasesView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The phrase library, mirroring the watch app's Phrases screen. Tap a
/// phrase to edit it or preview how it plays on the watch; changes sync
/// to the watch automatically.
struct PhrasesView: View {
    @State private var isAddingPhrase = false

    private var store: PhraseStore { .shared }

    var body: some View {
        List {
            Section {
                ForEach(store.phrases) { phrase in
                    NavigationLink {
                        PhraseEditorView(phrase: phrase)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(phrase.label)
                                    .font(.headline)
                                Text(phrase.spokenText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            if let emoji = phrase.emoji {
                                Text(emoji)
                            } else {
                                Image(systemName: phrase.systemIcon)
                            }
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            Speaker.shared.speak(phrase)
                        } label: {
                            Label("Speak", systemImage: "speaker.wave.2.fill")
                        }
                        .tint(.blue)
                    }
                }
                .onDelete { offsets in
                    store.remove(atOffsets: offsets)
                }
            } header: {
                Text("Ready-made sentences the watch displays and speaks aloud for you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            } footer: {
                Text("Tap a phrase to edit it and preview it on the watch. Swipe right to speak it from this phone.")
            }
        }
        .navigationTitle("Phrases")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingPhrase = true
                } label: {
                    Label("Add Phrase", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingPhrase) {
            NavigationStack {
                PhraseEditorView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhrasesView()
    }
}
