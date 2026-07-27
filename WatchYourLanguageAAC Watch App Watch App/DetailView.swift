//
//  DetailView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI
import WatchKit

/// Full-screen phrase display: cycles through the phrase one large word at a
/// time so a conversation partner can read it, and speaks it aloud on tap.
struct DetailView: View {
    let phrase: Phrase

    // Must match `SettingsStore`'s default, or the button and the settings
    // toggle disagree until the setting is written for the first time.
    @AppStorage(SettingsKeys.showsDisabilityBadge) private var showsDisabilityBadge = false

    // Read live, so changing the pace in Settings takes effect on the next
    // phrase without the app being relaunched.
    @AppStorage(SettingsKeys.wordInterval) private var wordInterval = WordPace.default

    @State private var isFlipped = false
    @State private var isShowingDisabilityCard = false

    private var words: [String] {
        phrase.spokenText.split(separator: " ").map(String.init)
    }

    private var backgroundColor: Color {
        PhraseColor.color(named: phrase.colorName)
    }

    /// White on most line colours, dark ink on the light ones (Overground
    /// orange, Hammersmith pink) where white would be unreadable. Resolved
    /// by contrast rather than assumed — this text is read at arm's length
    /// by someone who has never seen the phrase before.
    private var foregroundColor: Color {
        PhraseColor.foreground(named: phrase.colorName)
    }

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.periodic(from: .now, by: wordInterval)) { context in
                VStack(spacing: 10) {
                    Text(word(at: context.date))
                        .font(.appDisplay(56))
                        .multilineTextAlignment(.center)
                        // One word, on one line, as large as it will go.
                        // Without the line limit `minimumScaleFactor` never
                        // engages and a long word breaks mid-way instead of
                        // shrinking — unreadable for someone being shown it.
                        //
                        // The floor is 0.5 rather than 0.4: short words like
                        // "Help" and "Yes" are the common case and should be
                        // as big as the screen allows, and a word that needs
                        // to go below half of 56pt is too long to read at
                        // arm's length anyway.
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    if let emoji = phrase.emoji {
                        Text(emoji)
                            .font(.system(size: 30))
                    } else {
                        // Reversed out of the phrase colour: the badge takes
                        // the text colour and the symbol the background's.
                        RoundelBadge(
                            systemIcon: phrase.systemIcon,
                            tint: PhraseColor.signageColor(named: phrase.colorName).readableForeground,
                            size: 30,
                            iconColor: backgroundColor
                        )
                    }
                }
                .foregroundStyle(foregroundColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Flipped, the person opposite can read the watch face.
            .rotationEffect(.degrees(isFlipped ? 180 : 0))
            .contentShape(Rectangle())
            .onTapGesture {
                Speaker.shared.speak(phrase)
            }

            // Each control takes an equal share of the width. Previously
            // these were bare glyphs spaced apart, so the tap target was the
            // symbol itself — a few points across, next to a full-screen
            // target that speaks the phrase. Every near miss said the phrase
            // again instead of ringing the bell or flipping the screen.
            HStack(spacing: 6) {
                ControlButton(
                    systemIcon: "speaker.badge.exclamationmark",
                    label: "Get attention",
                    tint: foregroundColor
                ) {
                    WKInterfaceDevice.current().play(.stop)
                }

                if showsDisabilityBadge {
                    ControlButton(
                        systemIcon: PhraseLibrary.disabilityCardIcon,
                        label: "Show disability card",
                        tint: foregroundColor
                    ) {
                        isShowingDisabilityCard = true
                    }
                }

                ControlButton(
                    systemIcon: "arrow.triangle.2.circlepath.camera",
                    label: "Flip for reader opposite",
                    tint: foregroundColor
                ) {
                    isFlipped.toggle()
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 6)
            // Enough to clear the corner curve — the capsules are wide, so
            // their ends are exactly where the screen starts rounding away.
            .padding(.bottom, 10)
        }
        .background(backgroundColor)
        // watchOS reserves an inset along the bottom that held the row well
        // clear of the bezel. The screen is a full-bleed sign with nothing
        // to protect down there, and the very bottom of the watch is the
        // easiest place to hit, so the row is allowed into it.
        .ignoresSafeArea(.container, edges: .bottom)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .sheet(isPresented: $isShowingDisabilityCard) {
            DisabilityCardView()
        }
    }

    private func word(at date: Date) -> String {
        guard !words.isEmpty else { return phrase.label }
        let tick = Int(date.timeIntervalSinceReferenceDate / wordInterval)
        return words[tick % words.count]
    }
}

/// One of the phrase screen's bottom controls.
///
/// The capsule is not decoration: it shows where the target is. Reversed out
/// of the phrase colour at low opacity it stays quiet against the sign while
/// still telling someone with limited dexterity where to aim.
private struct ControlButton: View {
    let systemIcon: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemIcon)
                .imageScale(.large)
                .foregroundStyle(tint)
                // The whole slot is the target, not the glyph.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Capsule().fill(tint.opacity(0.18)))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    DetailView(phrase: PhraseLibrary.defaults[0])
}
