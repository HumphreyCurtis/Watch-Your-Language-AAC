//
//  PhraseJSONEditorView.swift
//  WatchYourLanguageAAC
//

import SwiftUI
import UIKit

/// The phrase library as raw, editable JSON.
///
/// Where `ImportPhrasesView` adds and updates, this replaces: it is for
/// handing the whole library to an assistant ("simplify every sentence",
/// "translate these into Polish") and pasting the result back. Because that
/// is destructive and syncs straight to the watch, saving is blocked until
/// the text parses, warns before replacing, and can always be reverted.
struct PhraseJSONEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var isConfirmingReplace = false
    @State private var didCopy = false

    private var store: PhraseStore { .shared }

    /// The parse result for whatever is currently in the editor.
    private var parsed: Result<[Phrase], Error> {
        Result { try PhraseTransfer.parseImport(text) }
    }

    private var parsedPhrases: [Phrase]? {
        try? parsed.get()
    }

    var body: some View {
        VStack(spacing: 0) {
            statusBar

            TextEditor(text: $text)
                .font(.system(.footnote, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 4)
        }
        .navigationTitle("Edit JSON")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { isConfirmingReplace = true }
                    .disabled(parsedPhrases == nil)
            }

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    UIPasteboard.general.string = text
                    didCopy = true
                } label: {
                    Label(didCopy ? "Copied" : "Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                }

                ShareLink(item: text) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Spacer()

                Button {
                    if let pasted = UIPasteboard.general.string {
                        // Take just the JSON, so a reply with prose around
                        // it can be pasted wholesale.
                        text = PhraseTransfer.extractJSON(from: pasted) ?? pasted
                    }
                } label: {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }

                Button("Revert") { load() }
                    .disabled(text == currentJSON)
            }
        }
        .onAppear(perform: load)
        .alert("Replace all phrases?", isPresented: $isConfirmingReplace) {
            Button("Replace", role: .destructive) { save() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(replaceWarning)
        }
    }

    // MARK: - Status

    private var statusBar: some View {
        Group {
            switch parsed {
            case .success(let phrases):
                Label("\(phrases.count) phrase\(phrases.count == 1 ? "" : "s")", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(TransportPalette.district.color)

            case .failure(let error):
                Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(TransportPalette.central.color)
            }
        }
        .font(.appFootnote)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var replaceWarning: String {
        let before = store.phrases.count
        let after = parsedPhrases?.count ?? 0
        return "Replaces \(before) phrase\(before == 1 ? "" : "s") with \(after), here and on your watch. This cannot be undone."
    }

    // MARK: - Actions

    private var currentJSON: String {
        PhraseTransfer.prettyJSON(store.phrases) ?? "[]"
    }

    private func load() {
        text = currentJSON
        didCopy = false
    }

    private func save() {
        guard let phrases = parsedPhrases else { return }
        // The parser refuses an empty array before this point, so an empty
        // library can only be reached by deleting phrases individually.
        store.replaceAll(phrases)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        PhraseJSONEditorView()
    }
}
