//
//  Phrase.swift
//  WatchYourLanguageAAC
//

import Foundation

/// A phrase the wearer can display on screen and speak aloud.
struct Phrase: Identifiable, Codable, Hashable {
    var id = UUID()

    /// Short label shown in lists (one or two words).
    var label: String

    /// Full sentence spoken aloud and displayed word by word.
    var spokenText: String

    /// SF Symbol name shown alongside the phrase.
    var systemIcon: String

    /// Emoji shown in place of `systemIcon` when set.
    var emoji: String?

    /// Display background colour name (see `PhraseColor`). `nil` means red.
    var colorName: String?

    /// BCP 47 language tag (e.g. "en-GB", "fr-FR"). `nil` follows the device language.
    var languageCode: String?
}

/// The set of phrases available in the app.
///
/// Currently a fixed default set; `Phrase` is `Codable` so this can later be
/// user-edited from the iOS companion app and synced to the watch.
enum PhraseLibrary {

    /// Icon for the "show a disability card" affordance. Kept as data rather
    /// than baked into views so it can become user-configurable.
    static let disabilityCardIcon = "figure.roll"

    /// Each example takes a different screen colour, so a new user sees the
    /// range on first launch and can tell phrases apart at a glance on the
    /// watch. "Help" keeps the high-visibility red default (`nil`).
    static let defaults: [Phrase] = [
        Phrase(label: "Help", spokenText: "Please can you help, it's hard to speak", systemIcon: "questionmark.circle.fill"),
        Phrase(label: "Stroke", spokenText: "I have had a stroke", systemIcon: "exclamationmark.shield", colorName: "purple"),
        Phrase(label: "Slower", spokenText: "Please speak more slowly", systemIcon: "tortoise.fill", colorName: "teal"),
        Phrase(label: "Seat", spokenText: "Could you please let me have your seat?", systemIcon: "chair.fill", colorName: "green"),
        Phrase(label: "Time", spokenText: "Please give me time to answer", systemIcon: "clock.badge.exclamationmark.fill", colorName: "indigo"),
        // Blue to match the disability card the watch can show.
        Phrase(label: "Disability", spokenText: "I have got a hidden disability", systemIcon: "figure.roll", colorName: "blue"),
        Phrase(label: "Toilet", spokenText: "Do you have a public or disabled toilet?", systemIcon: "toilet.fill", colorName: "orange"),
        Phrase(label: "Thanks", spokenText: "Thank you very much", systemIcon: "hand.thumbsup", colorName: "pink"),
    ] + multilingualExamples

    /// Example multilingual phrases — spoken with a voice matching their
    /// language. Templates to edit or copy for travel and language support.
    /// New in seed version 2: `PhraseStore` appends these once to phrase
    /// lists saved by earlier versions.
    static let multilingualExamples: [Phrase] = [
        Phrase(label: "Perdu", spokenText: "Je suis perdu, pouvez-vous m'aider ?", systemIcon: "map.fill", emoji: "🇫🇷", colorName: "teal", languageCode: "fr-FR"),
        Phrase(label: "Metro", spokenText: "¿Dónde está la estación de metro?", systemIcon: "tram.fill", emoji: "🇪🇸", colorName: "orange", languageCode: "es-ES"),
    ]
}

enum SettingsKeys {
    static let prefersFemaleVoice = "prefersFemaleVoice"
    static let showsDisabilityBadge = "showsDisabilityBadge"
    static let speechRate = "speechRate"
    static let wordInterval = "wordInterval"
}

/// How long each word of a phrase stays on the watch screen, in seconds.
///
/// Reading one word at a time is the whole mechanic of the phrase screen, and
/// the right pace is personal: an unhurried reader, or someone being shown a
/// phrase in a second language, needs longer than the original fixed 0.5s.
enum WordPace {
    static let `default`: Double = 0.5
    static let slowest: Double = 1.5
    static let fastest: Double = 0.3

    /// The stored value, clamped, with the default when nothing is set.
    ///
    /// Read straight from `UserDefaults` rather than `SettingsStore` so the
    /// timeline views can pick it up without observing the store.
    static var current: Double {
        guard let stored = UserDefaults.standard.object(forKey: SettingsKeys.wordInterval) as? Double else {
            return `default`
        }
        return min(max(stored, fastest), slowest)
    }
}
