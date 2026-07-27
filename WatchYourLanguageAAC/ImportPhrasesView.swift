//
//  ImportPhrasesView.swift
//  WatchYourLanguageAAC
//

import SwiftUI
import UIKit

/// Builds phrases by chatting with an AI assistant: copy a prompt, paste it
/// into Claude or ChatGPT, paste the reply back.
///
/// Nothing an assistant writes reaches the library unreviewed — the paste is
/// parsed into a list of proposed changes, each one switchable, and only
/// then saved. The raw JSON editor sits behind this screen for the rarer
/// case of rewriting the whole library.
struct ImportPhrasesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var pastedText = ""
    @State private var changes: [PhraseTransfer.Change] = []
    @State private var selected: Set<UUID> = []
    @State private var errorMessage: String?
    @State private var didCopyPrompt = false

    private var store: PhraseStore { .shared }

    var body: some View {
        Form {
            promptSection
            pasteSection

            if !changes.isEmpty {
                previewSection
            }

            Section {
                NavigationLink {
                    PhraseJSONEditorView()
                } label: {
                    Label("Edit raw JSON data", systemImage: "curlybraces")
                }
            } footer: {
                Text("Replaces the whole library.")
                    .font(.appFootnote)
            }
        }
        .signageSurface()
        .navigationTitle("Import")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !changes.isEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { apply() }
                        .disabled(applicableSelection.isEmpty)
                }
            }
        }
    }

    // MARK: - Sections

    private var promptSection: some View {
        Section {
            Button {
                UIPasteboard.general.string = PhraseTransfer.exportPrompt(phrases: store.phrases)
                didCopyPrompt = true
            } label: {
                Label(
                    didCopyPrompt ? "Prompt copied" : "Copy prompt",
                    systemImage: didCopyPrompt ? "checkmark.circle.fill" : "doc.on.doc.fill"
                )
            }

            ShareLink(item: PhraseTransfer.exportPrompt(phrases: store.phrases)) {
                Label("Share prompt", systemImage: "square.and.arrow.up")
            }
        } header: {
            PlatformHeader(text: "1. Ask an assistant", tint: TransportPalette.central)
        } footer: {
            Text("Paste the prompt into Claude or ChatGPT, then ask for the phrases you want.")
                .font(.appFootnote)
        }
    }

    private var pasteSection: some View {
        Section {
            Button {
                pastedText = UIPasteboard.general.string ?? ""
                parse()
            } label: {
                Label("Paste reply", systemImage: "doc.on.clipboard")
            }

            TextEditor(text: $pastedText)
                .font(.system(.footnote, design: .monospaced))
                .frame(minHeight: 90)
                .onChange(of: pastedText) { _, _ in
                    // Re-check as the text changes, so the preview below
                    // always matches what is in the box.
                    if !pastedText.isEmpty { parse() }
                }

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.appFootnote)
                    .foregroundStyle(TransportPalette.central.color)
            }
        } header: {
            PlatformHeader(text: "2. Paste the reply", tint: TransportPalette.piccadilly)
        }
    }

    private var previewSection: some View {
        Section {
            ForEach(changes) { change in
                changeRow(change)
            }
        } header: {
            PlatformHeader(text: "3. Review", tint: TransportPalette.district)
        } footer: {
            Text(summary)
                .font(.appFootnote)
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func changeRow(_ change: PhraseTransfer.Change) -> some View {
        HStack(spacing: 12) {
            RoundelBadge(
                systemIcon: change.phrase.systemIcon,
                emoji: change.phrase.emoji,
                tint: PhraseColor.signageColor(named: change.phrase.colorName),
                size: 30
            )

            VStack(alignment: .leading, spacing: 1) {
                Text(change.phrase.label)
                    .font(.appHeadline)

                Text(change.phrase.spokenText)
                    .font(.appSubheadline)
                    .foregroundStyle(TransportPalette.corporateGrey.color)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            if change.kind == .unchanged {
                Image(systemName: "equal")
                    .font(.appFootnote)
                    .foregroundStyle(TransportPalette.corporateGrey.color)
                    .accessibilityLabel("Already in your library")
            } else {
                Toggle(
                    label(for: change.kind),
                    isOn: Binding(
                        get: { selected.contains(change.id) },
                        set: { isOn in
                            if isOn { selected.insert(change.id) } else { selected.remove(change.id) }
                        }
                    )
                )
                .labelsHidden()
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label(for: change.kind)): \(change.phrase.label). \(change.phrase.spokenText)")
    }

    private func label(for kind: PhraseTransfer.Change.Kind) -> String {
        switch kind {
        case .added: "New"
        case .updated: "Updates an existing phrase"
        case .unchanged: "Already in your library"
        }
    }

    private var summary: String {
        let added = applicableSelection.filter { $0.kind == .added }.count
        let updated = applicableSelection.filter { $0.kind == .updated }.count

        var parts: [String] = []
        if added > 0 { parts.append("\(added) new") }
        if updated > 0 { parts.append("\(updated) updated") }
        return parts.isEmpty ? "Nothing selected." : parts.joined(separator: ", ") + "."
    }

    // MARK: - Actions

    private var applicableSelection: [PhraseTransfer.Change] {
        changes.filter { $0.kind != .unchanged && selected.contains($0.id) }
    }

    private func parse() {
        do {
            let incoming = try PhraseTransfer.parseImport(pastedText)
            let merged = PhraseTransfer.merge(incoming: incoming, into: store.phrases)
            changes = merged
            // Everything that would actually change is on by default.
            selected = Set(merged.filter { $0.kind != .unchanged }.map(\.id))
            errorMessage = nil
        } catch {
            changes = []
            selected = []
            errorMessage = error.localizedDescription
        }
    }

    private func apply() {
        for change in applicableSelection {
            store.save(change.phrase)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ImportPhrasesView()
    }
}
