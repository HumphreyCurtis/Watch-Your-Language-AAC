//
//  TransportPalette.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// A signage colour, kept as its `0xRRGGBB` value so contrast against it can
/// be computed rather than guessed.
///
/// SwiftUI's `Color` cannot be reliably decomposed back into components on
/// both iOS and watchOS, so the palette holds the numbers it was built from.
struct SignageColor: Hashable, Sendable {
    let hex: UInt32

    var color: Color {
        Color(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// WCAG 2.1 relative luminance.
    var relativeLuminance: Double {
        func linear(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(Double((hex >> 16) & 0xFF) / 255)
            + 0.7152 * linear(Double((hex >> 8) & 0xFF) / 255)
            + 0.0722 * linear(Double(hex & 0xFF) / 255)
    }

    /// WCAG contrast ratio between this colour and another, 1...21.
    func contrast(against other: SignageColor) -> Double {
        let a = relativeLuminance
        let b = other.relativeLuminance
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    /// The readable text colour to place on this one.
    ///
    /// Computed rather than hard-coded per colour, so it stays correct if
    /// the palette is retuned. Light line colours (Hammersmith pink,
    /// Overground orange) resolve to dark ink; the rest to off-white.
    var readableForeground: SignageColor {
        contrast(against: TransportPalette.signageWhite) >= contrast(against: TransportPalette.signageInk)
            ? TransportPalette.signageWhite
            : TransportPalette.signageInk
    }
}

/// The app's colour system, drawn from London transport signage.
///
/// That visual language is borrowed deliberately: it exists to be read
/// quickly, at distance, by a stranger, under pressure — which is exactly
/// what a phrase screen has to do. Flat saturated blocks, no gradients,
/// no translucency.
///
/// The line colours are *inspired by* the Underground palette rather than
/// copied from it; where a line's real colour cannot carry legible text at
/// watch size, legibility wins (see `victoria`).
enum TransportPalette {

    // MARK: - Line colours

    /// Central line red. The high-visibility default for phrase screens.
    static let central = SignageColor(hex: 0xE1251B)

    /// Piccadilly navy. Also the app's primary signage blue.
    static let piccadilly = SignageColor(hex: 0x0019A8)

    /// District green.
    static let district = SignageColor(hex: 0x007D32)

    /// Victoria blue, darkened from the line's real `#0098D8`, which reaches
    /// only 3.2:1 against white — too close to the limit for large text read
    /// outdoors on a watch.
    static let victoria = SignageColor(hex: 0x007BB8)

    /// Hammersmith & City pink. Very light: resolves to dark text.
    static let hammersmith = SignageColor(hex: 0xF4A9BE)

    /// Metropolitan magenta.
    static let metropolitan = SignageColor(hex: 0x9B0058)

    /// Overground orange. Resolves to dark text, as on real signage.
    static let overground = SignageColor(hex: 0xEE7C0E)

    /// Elizabeth line purple.
    static let elizabeth = SignageColor(hex: 0x6950A1)

    // MARK: - Signage neutrals

    /// The blue of station signs and the roundel bar.
    static let roundelBlue = piccadilly

    /// Signage grey, for secondary text and rules.
    static let corporateGrey = SignageColor(hex: 0x838D93)

    /// Near-black for text on light line colours. Slightly blue rather than
    /// pure black, which sits better against the saturated palette.
    static let signageInk = SignageColor(hex: 0x10131A)

    /// Off-white for text on dark line colours.
    static let signageWhite = SignageColor(hex: 0xFAFAFA)

    /// The muted slate of the breathing circle, previously hard-coded
    /// identically in both platforms' `BreatheView`.
    static let calmSlate = SignageColor(hex: 0x6F97A7)

    // MARK: - Surfaces

    // Resolved from SwiftUI's own `ColorScheme` rather than a UIKit dynamic
    // provider, which is not available on watchOS. Views read the scheme
    // from the environment; `signageSurface()` does it for most of them.

    /// Screen background behind signage rows.
    static func surface(_ scheme: ColorScheme) -> Color {
        #if os(watchOS)
        .black
        #else
        scheme == .dark ? SignageColor(hex: 0x12141A).color : SignageColor(hex: 0xF2F2EF).color
        #endif
    }

    /// A raised block sitting on `surface` — the body of a signage row.
    static func block(_ scheme: ColorScheme) -> Color {
        #if os(watchOS)
        Color(white: 0.13)
        #else
        scheme == .dark ? SignageColor(hex: 0x22242C).color : .white
        #endif
    }

    /// Readable text on `surface`/`block`.
    static func ink(_ scheme: ColorScheme) -> Color {
        #if os(watchOS)
        signageWhite.color
        #else
        scheme == .dark ? signageWhite.color : signageInk.color
        #endif
    }
}
