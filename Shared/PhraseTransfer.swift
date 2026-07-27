//
//  PhraseTransfer.swift
//  WatchYourLanguageAAC
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Moves phrases in and out of the app as JSON, so a phrase library can be
/// built by chatting with an AI assistant.
///
/// The round trip is deliberately clipboard-based: the user pastes a prompt
/// into whichever assistant they already pay for, and pastes the reply back.
/// No API key, no account linking, no network code in the app.
///
/// Everything here treats its input as untrusted and malformed. Assistants
/// wrap JSON in code fences, add explanation before and after, invent colour
/// names, and omit fields — so parsing repairs what it can rather than
/// refusing the batch, and the result is always reviewed before it is saved.
enum PhraseTransfer {

    // MARK: - Export

    /// A self-contained prompt: what the app is, the schema, the allowed
    /// values, and the user's current library.
    ///
    /// Self-contained because it has to survive being pasted into a fresh
    /// chat with no other context.
    static func exportPrompt(phrases: [Phrase]) -> String {
        """
        I use an app called Watch Your Language. It is a communication aid \
        (AAC) for people with aphasia — it shows a phrase on an Apple Watch \
        one large word at a time and speaks it aloud, so someone who finds \
        speaking hard can be understood.

        Help me write phrases for it. Reply with a JSON array of phrase \
        objects and nothing else — no explanation, no commentary.

        Each object has these fields:
          "label"        Required. One or two words, shown in lists. Keep it short.
          "spokenText"   Required. The full sentence spoken aloud and shown word by word.
          "systemIcon"   Required. An SF Symbol name from the list below.
          "emoji"        Optional. A single emoji shown instead of the icon. Good for flags.
          "colorName"    Optional. The screen colour, from the list below. Omit for red.
          "languageCode" Optional. A BCP 47 tag such as "fr-FR" or "es-ES", when the \
        phrase is not in the device language. Set this whenever spokenText is not English, \
        so it is spoken in the right accent.

        Allowed colorName values (they are named after London Underground lines):
        \(PhraseColor.names.map { "  \"\($0)\" — \(PhraseColor.lineName(for: $0))" }.joined(separator: "\n"))

        Allowed systemIcon values:
        \(curatedSymbols.map { "  \"\($0)\"" }.joined(separator: "\n"))

        Writing guidance:
          - Write the sentence the person would say themselves, in the first person.
          - Keep sentences short and plain. They are read aloud to a stranger, \
        often in a shop, a station or a waiting room.
          - Be direct and polite, never apologetic.

        This is my current library. Keep the "id" field on any phrase you are \
        changing, so it updates instead of being duplicated. Leave "id" out \
        for new phrases.

        \(prettyJSON(phrases) ?? "[]")
        """
    }

    /// The icon set the phrase editor offers and the prompt suggests.
    ///
    /// One list, used by both, so the picker and the prompt cannot drift
    /// apart — and so every icon used by `PhraseLibrary.defaults` is
    /// offerable.
    ///
    /// Kept at 30. The picker lays these out in an adaptive grid, and 30
    /// divides by 2, 3, 5 and 6, so it fills whole rows at every column
    /// count a phone is likely to choose rather than leaving one icon
    /// stranded on a line of its own. Add icons in pairs or not at all.
    static let curatedSymbols = [
        "text.bubble.fill", "questionmark.circle.fill", "exclamationmark.shield", "tortoise.fill",
        "chair.fill", "clock.badge.exclamationmark.fill", "figure.roll", "toilet.fill",
        "hand.thumbsup", "hand.raised.fill", "heart.fill", "cross.case.fill",
        "pills.fill", "drop.fill", "fork.knife", "cup.and.saucer.fill",
        "bed.double.fill", "house.fill", "car.fill", "bus",
        "tram.fill", "map.fill", "phone.fill", "envelope.fill",
        "creditcard.fill", "key.fill", "sun.max.fill", "cloud.rain.fill",
        "star.fill", "ear",
    ]

    /// Whether a symbol name will actually draw.
    ///
    /// Real SF Symbols outside the curated set are kept — a phrase may come
    /// from a newer version of the app, and the icon picker already tolerates
    /// that. Only names that would render as nothing are replaced.
    static func isUsableSymbol(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        #if canImport(UIKit)
        return UIImage(systemName: name) != nil
        #else
        return curatedSymbols.contains(name)
        #endif
    }

    /// The library as indented JSON, for the editor and the prompt.
    static func prettyJSON(_ phrases: [Phrase]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(phrases) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Import

    enum ImportError: LocalizedError {
        case noJSONFound
        case malformed(String)
        case empty

        var errorDescription: String? {
            switch self {
            case .noJSONFound:
                "No JSON found. Paste the assistant's reply, including the square brackets."
            case .malformed(let detail):
                "That JSON could not be read. \(detail)"
            case .empty:
                "That JSON contains no phrases."
            }
        }
    }

    /// Reads phrases out of whatever an assistant replied with.
    ///
    /// Accepts a bare array, a single object, or either buried in prose and
    /// code fences. Missing optional fields take defaults; invalid colour
    /// and icon names are repaired rather than rejected, because one bad
    /// value should not cost the user the whole batch.
    static func parseImport(_ text: String) throws -> [Phrase] {
        guard let json = extractJSON(from: text) else { throw ImportError.noJSONFound }
        guard let data = json.data(using: .utf8) else { throw ImportError.noJSONFound }

        let decoder = JSONDecoder()
        let incoming: [LenientPhrase]

        if let array = try? decoder.decode([LenientPhrase].self, from: data) {
            incoming = array
        } else if let single = try? decoder.decode(LenientPhrase.self, from: data) {
            incoming = [single]
        } else {
            // Decode once more to surface the real reason to the user.
            do {
                _ = try decoder.decode([LenientPhrase].self, from: data)
                throw ImportError.malformed("Unexpected structure.")
            } catch let error as DecodingError {
                throw ImportError.malformed(Self.describe(error))
            }
        }

        let phrases = incoming.compactMap { $0.resolved() }
        guard !phrases.isEmpty else { throw ImportError.empty }
        return phrases
    }

    /// Finds the first complete JSON array or object in a block of text,
    /// ignoring surrounding prose and code fences.
    ///
    /// Brace counting is string- and escape-aware, so a `{` inside a spoken
    /// sentence does not end the scan early.
    static func extractJSON(from text: String) -> String? {
        let stripped = text.replacingOccurrences(
            of: "```(?:json)?",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )

        let characters = Array(stripped)
        guard let start = characters.firstIndex(where: { $0 == "[" || $0 == "{" }) else { return nil }

        let opening = characters[start]
        let closing: Character = opening == "[" ? "]" : "}"

        var depth = 0
        var insideString = false
        var isEscaped = false

        for index in start..<characters.count {
            let character = characters[index]

            if isEscaped {
                isEscaped = false
                continue
            }
            if character == "\\" && insideString {
                isEscaped = true
                continue
            }
            if character == "\"" {
                insideString.toggle()
                continue
            }
            guard !insideString else { continue }

            if character == opening {
                depth += 1
            } else if character == closing {
                depth -= 1
                if depth == 0 {
                    return String(characters[start...index])
                }
            }
        }

        return nil
    }

    private static func describe(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            context.debugDescription
        case .keyNotFound(let key, _):
            "Missing field \"\(key.stringValue)\"."
        case .typeMismatch(_, let context), .valueNotFound(_, let context):
            context.debugDescription
        @unknown default:
            "Unexpected structure."
        }
    }

    // MARK: - Merge

    /// What importing one phrase would do to the library.
    struct Change: Identifiable {
        enum Kind {
            case added, updated, unchanged
        }

        let id = UUID()
        let kind: Kind
        /// The phrase as it would be saved, carrying the existing id when
        /// this updates a phrase already in the library.
        let phrase: Phrase
        let existing: Phrase?
    }

    /// Works out what an import would change, without changing anything.
    ///
    /// Matches on `id` first, then on a case-insensitive label — the same
    /// convention `PhraseStore.seedNewDefaultsIfNeeded` uses — so a phrase
    /// an assistant rewrote without keeping its id still updates in place
    /// rather than arriving as a duplicate.
    static func merge(incoming: [Phrase], into existing: [Phrase]) -> [Change] {
        incoming.map { candidate in
            let match = existing.first { $0.id == candidate.id }
                ?? existing.first { $0.label.caseInsensitiveCompare(candidate.label) == .orderedSame }

            guard let match else {
                return Change(kind: .added, phrase: candidate, existing: nil)
            }

            // Keep the stored id so this updates the existing phrase.
            var resolved = candidate
            resolved.id = match.id

            return Change(
                kind: resolved == match ? .unchanged : .updated,
                phrase: resolved,
                existing: match
            )
        }
    }
}

/// A phrase as an assistant might actually write it: every field optional,
/// nothing trusted.
private struct LenientPhrase: Decodable {
    var id: UUID?
    var label: String?
    var spokenText: String?
    var systemIcon: String?
    var emoji: String?
    var colorName: String?
    var languageCode: String?

    /// Builds a valid `Phrase`, or `nil` if there is nothing usable here.
    ///
    /// A phrase needs something to say, so a missing `spokenText` falls back
    /// to the label and vice versa; only an entry with neither is dropped.
    func resolved() -> Phrase? {
        let cleanedLabel = label?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanedSpoken = spokenText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanedLabel.isEmpty || !cleanedSpoken.isEmpty else { return nil }

        let finalLabel = cleanedLabel.isEmpty ? String(cleanedSpoken.prefix(20)) : cleanedLabel
        let finalSpoken = cleanedSpoken.isEmpty ? cleanedLabel : cleanedSpoken

        // Repair rather than reject: an invented icon or colour name costs
        // the user a default, not the whole import.
        let icon = systemIcon.flatMap { PhraseTransfer.isUsableSymbol($0) ? $0 : nil }
            ?? "text.bubble.fill"

        let colour = colorName
            .map { $0.lowercased() }
            .flatMap { PhraseColor.names.contains($0) ? $0 : nil }

        let emoji = emoji?.trimmingCharacters(in: .whitespacesAndNewlines)

        return Phrase(
            id: id ?? UUID(),
            label: finalLabel,
            spokenText: finalSpoken,
            systemIcon: icon,
            emoji: (emoji?.isEmpty ?? true) ? nil : emoji.map { String($0.prefix(2)) },
            // Red is the default and is stored as nil.
            colorName: colour == "red" ? nil : colour,
            languageCode: languageCode?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
