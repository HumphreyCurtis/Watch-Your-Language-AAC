//
//  PhraseColor.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Background colours a phrase screen can use, stored by name so the
/// `Phrase` model stays Codable and platform-independent. Red (the
/// high-visibility default from the original research app) is `nil`.
enum PhraseColor {
    static let names = ["red", "orange", "pink", "purple", "indigo", "blue", "teal", "green"]

    static func color(named name: String?) -> Color {
        switch name {
        case "orange": .orange
        case "pink": .pink
        case "purple": .purple
        case "indigo": .indigo
        case "blue": .blue
        case "teal": .teal
        case "green": .green
        default: .red
        }
    }
}
