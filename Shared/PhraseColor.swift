//
//  PhraseColor.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Background colours a phrase screen can use, stored by name so the
/// `Phrase` model stays Codable and platform-independent. Red (the
/// high-visibility default from the original research app) is `nil`.
///
/// The names are storage keys, written into `Phrases.json` and synced to
/// the watch, so they are fixed. Their *values* come from the transport
/// palette — retuning a shade restyles every saved phrase using it, while
/// renaming a key would orphan them.
enum PhraseColor {
    static let names = ["red", "orange", "pink", "purple", "indigo", "blue", "teal", "green"]

    /// The line colour a stored name maps to.
    static func signageColor(named name: String?) -> SignageColor {
        switch name {
        case "orange": TransportPalette.overground
        case "pink": TransportPalette.hammersmith
        case "purple": TransportPalette.metropolitan
        case "indigo": TransportPalette.elizabeth
        case "blue": TransportPalette.piccadilly
        case "teal": TransportPalette.victoria
        case "green": TransportPalette.district
        default: TransportPalette.central
        }
    }

    static func color(named name: String?) -> Color {
        signageColor(named: name).color
    }

    /// Readable text colour for a phrase screen in this colour. The light
    /// lines (Overground orange, Hammersmith pink) cannot carry white text,
    /// so this is resolved by contrast rather than assumed.
    static func foreground(named name: String?) -> Color {
        signageColor(named: name).readableForeground.color
    }

    /// The line a colour is named after, used for accessibility labels in
    /// place of the bare storage key.
    static func lineName(for name: String?) -> String {
        switch name {
        case "orange": "Overground orange"
        case "pink": "Hammersmith pink"
        case "purple": "Metropolitan magenta"
        case "indigo": "Elizabeth purple"
        case "blue": "Piccadilly blue"
        case "teal": "Victoria blue"
        case "green": "District green"
        default: "Central red"
        }
    }
}
