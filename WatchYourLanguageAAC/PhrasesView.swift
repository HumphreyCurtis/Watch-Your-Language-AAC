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
                        SignageRow(
                            title: phrase.label,
                            subtitle: phrase.spokenText,
                            systemIcon: phrase.systemIcon,
                            emoji: phrase.emoji,
                            tint: PhraseColor.signageColor(named: phrase.colorName)
                        )
                    }
                    .signageRowStyle()
                    .swipeActions(edge: .leading) {
                        Button {
                            Speaker.shared.speak(phrase)
                        } label: {
                            Label("Speak", systemImage: "speaker.wave.2.fill")
                        }
                        .tint(TransportPalette.piccadilly.color)
                    }
                }
                .onDelete { offsets in
                    store.remove(atOffsets: offsets)
                }
            } footer: {
                Text("Swipe a phrase right to speak it.")
                    .font(.appFootnote)
            }

            librarySection
        }
        .listStyle(.plain)
        .signageSurface()
        .navigationTitle("Phrases")
        .navigationBarTitleDisplayMode(.inline)
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

    /// The way into building phrases with an AI assistant. The raw JSON
    /// editor lives behind it, since it is the rarer and riskier of the two.
    private var librarySection: some View {
        Section {
            NavigationLink {
                ImportPhrasesView()
            } label: {
                SignageRow(
                    title: "Import with AI",
                    systemIcon: "sparkles",
                    tint: TransportPalette.elizabeth
                )
            }
            .signageRowStyle()
        }
    }
}

#Preview {
    NavigationStack {
        PhrasesView()
    }
}
