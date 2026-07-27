//
//  PhraseEditorView.swift
//  WatchYourLanguageAAC
//

import SwiftUI
import UIKit

/// Edits one phrase (or creates a new one), with a Play tab previewing how
/// the phrase appears and behaves on the watch. The preview reflects
/// unsaved edits, so changes can be tried before saving.
struct PhraseEditorView: View {
    private enum Mode: String, CaseIterable {
        case edit = "Edit"
        case play = "Play"
    }

    @Environment(\.dismiss) private var dismiss

    @State private var draft: Phrase
    @State private var mode: Mode = .edit

    private let isNew: Bool
    private var store: PhraseStore { .shared }

    init(phrase: Phrase? = nil) {
        _draft = State(initialValue: phrase ?? Phrase(label: "", spokenText: "", systemIcon: "text.bubble.fill"))
        isNew = phrase == nil
    }

    /// The phrase's own screen colour, so the editor's headings carry the
    /// colour the phrase will be shown in — and change with it as the
    /// colour picker below is used.
    private var tint: SignageColor {
        PhraseColor.signageColor(named: draft.colorName)
    }

    private var canSave: Bool {
        !draft.label.trimmingCharacters(in: .whitespaces).isEmpty
            && !draft.spokenText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack {
            Picker("View", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch mode {
            case .edit:
                editForm
            case .play:
                PhrasePlayView(phrase: draft)
            }
        }
        // On the whole stack, not just the form: `scrollContentBackground`
        // travels down through the environment to the `Form`, so the picker
        // strip and the form end up on one surface instead of the form
        // keeping the system's cool grey against the app's warmer one.
        .signageSurface()
        // `TextField`, `Picker` and `Button` labels are system controls and
        // default to SF.
        .font(.appBody)
        .navigationTitle(isNew ? "New Phrase" : draft.label)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    store.save(draft)
                    dismiss()
                }
                .disabled(!canSave)
            }

            if isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var editForm: some View {
        Form {
            Section {
                TextField("Short label (e.g. Water)", text: $draft.label)
            } header: {
                PlatformHeader(text: "Label", tint: tint)
            }

            Section {
                TextField("Full sentence to speak", text: $draft.spokenText, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                PlatformHeader(text: "Spoken sentence", tint: tint)
            }

            Section {
                IconPicker(symbol: $draft.systemIcon, emoji: $draft.emoji)
            } header: {
                PlatformHeader(text: "Icon", tint: tint)
            }

            Section {
                ScreenColorPicker(selection: $draft.colorName)
            } header: {
                PlatformHeader(text: "Screen colour", tint: tint)
            }

            if !isNew {
                Section {
                    Button("Delete Phrase", role: .destructive) {
                        store.remove(id: draft.id)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct IconPicker: View {
    @Binding var symbol: String
    @Binding var emoji: String?

    @State private var isShowingEmoji: Bool
    @State private var customEmoji: String

    init(symbol: Binding<String>, emoji: Binding<String?>) {
        _symbol = symbol
        _emoji = emoji
        _isShowingEmoji = State(initialValue: emoji.wrappedValue != nil)
        _customEmoji = State(initialValue: emoji.wrappedValue ?? "")
    }

    /// Shared with the AI import prompt, so the icons offered here and the
    /// icons an assistant is told to use stay the same set.
    private static let symbols = PhraseTransfer.curatedSymbols

    /// Keeps a symbol visible even if it isn't in the curated set
    /// (e.g. a phrase synced from a future version).
    private var symbols: [String] {
        Self.symbols.contains(symbol) ? Self.symbols : [symbol] + Self.symbols
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
            ForEach(symbols, id: \.self) { icon in
                cell(isSelected: emoji == nil && symbol == icon, accessibilityLabel: icon) {
                    emoji = nil
                    symbol = icon
                } content: {
                    Image(systemName: icon)
                        .font(.appTitle3)
                }
            }
        }
        .padding(.vertical, 4)

        DisclosureGroup("Keyboard icons & emojis", isExpanded: $isShowingEmoji) {
            HStack {
                EmojiTextField(text: $customEmoji, placeholder: "Pick any emoji — flags too 🙂")

                if emoji != nil {
                    Button("Use symbol instead") {
                        emoji = nil
                        customEmoji = ""
                    }
                    .font(.appFootnote)
                    .buttonStyle(.borderless)
                }
            }
            .onChange(of: customEmoji) { _, newValue in
                guard let last = newValue.last else { return }
                customEmoji = String(last)
                emoji = String(last)
            }
        }
    }

    private func cell(
        isSelected: Bool,
        accessibilityLabel: String,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) -> some View {
        Button(action: action) {
            content()
                .frame(width: 44, height: 44)
                .background(
                    isSelected ? TransportPalette.roundelBlue.color.opacity(0.15) : .clear,
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? TransportPalette.roundelBlue.color : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// A text field that opens the system emoji keyboard, so any emoji —
/// including flags — can be chosen as a phrase icon.
private struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeUIView(context: Context) -> EmojiUITextField {
        let field = EmojiUITextField()
        field.placeholder = placeholder
        field.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject {
        private let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        @objc func editingChanged(_ sender: UITextField) {
            text.wrappedValue = sender.text ?? ""
        }
    }

    final class EmojiUITextField: UITextField {
        // A stable identifier makes UIKit honour our preferred input mode.
        override var textInputContextIdentifier: String? { "" }

        override var textInputMode: UITextInputMode? {
            UITextInputMode.activeInputModes.first { $0.primaryLanguage == "emoji" } ?? super.textInputMode
        }
    }
}

private struct ScreenColorPicker: View {
    @Binding var selection: String?

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
            ForEach(PhraseColor.names, id: \.self) { name in
                Button {
                    // Red is the default, stored as nil.
                    selection = name == "red" ? nil : name
                } label: {
                    Circle()
                        .fill(PhraseColor.color(named: name))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(isSelected(name) ? Color.primary : .clear, lineWidth: 3)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PhraseColor.lineName(for: name))
                .accessibilityAddTraits(isSelected(name) ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }

    private func isSelected(_ name: String) -> Bool {
        (selection ?? "red") == name
    }
}

/// Demo of how the phrase appears and behaves on the watch: the spoken
/// sentence cycles one large word at a time on the red screen, and tapping
/// speaks it aloud — just like the watch's phrase display.
struct PhrasePlayView: View {
    let phrase: Phrase

    private var words: [String] {
        phrase.spokenText.split(separator: " ").map(String.init)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                TimelineView(.periodic(from: .now, by: 0.5)) { context in
                    Text(word(at: context.date))
                        .font(.appDisplay(40))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }

                if let emoji = phrase.emoji {
                    Text(emoji)
                        .font(.title)
                } else {
                    Image(systemName: phrase.systemIcon)
                        .font(.title)
                }
            }
            .foregroundStyle(PhraseColor.foreground(named: phrase.colorName))
            .padding(24)
            .frame(width: 200, height: 240)
            .background(PhraseColor.color(named: phrase.colorName), in: RoundedRectangle(cornerRadius: 44))
            .overlay(
                RoundedRectangle(cornerRadius: 44)
                    .stroke(.black, lineWidth: 8)
            )
            .contentShape(RoundedRectangle(cornerRadius: 44))
            .onTapGesture {
                Speaker.shared.speak(phrase)
            }
            .accessibilityLabel("Watch preview of \(phrase.label)")
            .accessibilityHint("Tap to speak the phrase")

            Text("Tap the watch face to hear the phrase spoken aloud.")
                .font(.appFootnote)
                .foregroundStyle(TransportPalette.corporateGrey.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    private func word(at date: Date) -> String {
        guard !words.isEmpty else { return "…" }
        let tick = Int(date.timeIntervalSinceReferenceDate / 0.5)
        return words[tick % words.count]
    }
}

#Preview {
    NavigationStack {
        PhraseEditorView(phrase: PhraseLibrary.defaults[0])
    }
}
