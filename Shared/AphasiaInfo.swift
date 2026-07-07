//
//  AphasiaInfo.swift
//  WatchYourLanguageAAC
//

import Foundation

/// Content for the aphasia explainer screens; the watch and iPhone present
/// it with layouts suited to each screen.
enum AphasiaInfo {
    static let explainers = [
        "Aphasia is a communication disability",
        "It can make it hard to speak, read or write",
    ]

    static let tips = [
        "Use gesture",
        "Use eye contact",
        "Use drawing",
        "Use writing",
        "Take your time",
        "Use symbols",
    ]

    static var tipsSpokenText: String {
        "Tips for communication: \(tips.joined(separator: ", "))"
    }

    /// Destination of the QR code shown on both platforms.
    static let learnMoreURL = URL(string: "https://www.stroke.org.uk/what-is-aphasia/aphasia-and-its-effects")!
}
