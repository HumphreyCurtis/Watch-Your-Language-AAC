//
//  Typography.swift
//  WatchYourLanguageAAC
//

import CoreText
import SwiftUI

/// Atkinson Hyperlegible, the app's typeface on both platforms.
///
/// Designed by the Braille Institute for low-vision legibility: letterforms
/// that are hard to confuse (`I`, `l`, `1`) and a slashed zero. That matters
/// more here than house style — the watch screen is read at a glance, at
/// distance, by someone who has not seen the phrase before.
///
/// The project generates its `Info.plist` (`GENERATE_INFOPLIST_FILE = YES`)
/// and there is no `INFOPLIST_KEY_*` equivalent for the `UIAppFonts` array,
/// so the fonts are registered at launch instead of being declared.
enum AppFont {

    static let regular = "AtkinsonHyperlegible-Regular"
    static let bold = "AtkinsonHyperlegible-Bold"

    private static var hasRegistered = false

    /// Registers the bundled fonts with Core Text. Safe to call more than once.
    ///
    /// Call before any view renders — from each app's `init()`. If this fails,
    /// `Font.custom` silently falls back to the system font and the app still
    /// looks plausible, so the outcome is logged rather than ignored.
    static func registerIfNeeded() {
        guard !hasRegistered else { return }
        hasRegistered = true

        for name in [regular, bold] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("[AppFont] Missing \(name).ttf in the bundle — falling back to the system font.")
                continue
            }

            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let reason = error?.takeRetainedValue().localizedDescription ?? "unknown error"
                print("[AppFont] Failed to register \(name): \(reason)")
            }
        }
    }

    /// A scaling Atkinson font.
    ///
    /// Always resolved through `relativeTo:` so Dynamic Type keeps working —
    /// a plain `Font.custom(_:size:)` would freeze text at one size, which is
    /// not acceptable in an app used by people with low vision.
    static func scaled(_ size: CGFloat, relativeTo style: Font.TextStyle, bold isBold: Bool = false) -> Font {
        .custom(isBold ? bold : regular, size: size, relativeTo: style)
    }
}

extension Font {

    // Base sizes at the default content size; `relativeTo:` scales from
    // there. watchOS runs smaller than iOS, so the two are listed separately
    // rather than sharing one table and looking oversized on the watch.
    //
    // The watch table sits deliberately a step *above* the platform's own
    // text-style sizes. On device the stock sizes read small for the people
    // this app is for, and a watch screen is glanced at, not studied — this
    // is a considered choice, not a table that drifted. Please don't
    // "correct" it back to Apple's numbers.
    #if os(watchOS)
    private enum Size {
        static let largeTitle: CGFloat = 33
        static let title: CGFloat = 26
        static let title2: CGFloat = 21
        static let title3: CGFloat = 18
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 14
        static let caption: CGFloat = 13
    }
    #else
    private enum Size {
        static let largeTitle: CGFloat = 34
        static let title: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption: CGFloat = 12
    }
    #endif

    static let appLargeTitle = AppFont.scaled(Size.largeTitle, relativeTo: .largeTitle, bold: true)
    static let appTitle = AppFont.scaled(Size.title, relativeTo: .title, bold: true)
    static let appTitle2 = AppFont.scaled(Size.title2, relativeTo: .title2, bold: true)
    static let appTitle3 = AppFont.scaled(Size.title3, relativeTo: .title3)
    static let appHeadline = AppFont.scaled(Size.headline, relativeTo: .headline, bold: true)
    static let appBody = AppFont.scaled(Size.body, relativeTo: .body)
    static let appCallout = AppFont.scaled(Size.callout, relativeTo: .callout)
    static let appSubheadline = AppFont.scaled(Size.subheadline, relativeTo: .subheadline)
    static let appFootnote = AppFont.scaled(Size.footnote, relativeTo: .footnote)
    static let appCaption = AppFont.scaled(Size.caption, relativeTo: .caption)

    /// Oversized signage type — the phrase word on the watch and its preview
    /// on the phone. Scales from `.largeTitle` so it still responds to
    /// Dynamic Type instead of being pinned to one size.
    static func appDisplay(_ size: CGFloat) -> Font {
        AppFont.scaled(size, relativeTo: .largeTitle, bold: true)
    }
}
