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
            TimelineView(.periodic(from: .now, by: 0.5)) { context in
                VStack(spacing: 10) {
                    Text(word(at: context.date))
                        // Atkinson runs wider than SF Pro, so this is a
                        // little smaller than the original 55pt to keep
                        // long words from collapsing to the scale floor.
                        .font(.appDisplay(50))
                        .multilineTextAlignment(.center)
                        // One word, on one line, as large as it will go.
                        // Without the line limit `minimumScaleFactor` never
                        // engages and a long word breaks mid-way instead of
                        // shrinking — unreadable for someone being shown it.
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)

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

            HStack {
                Button {
                    WKInterfaceDevice.current().play(.stop)
                } label: {
                    Image(systemName: "speaker.badge.exclamationmark")
                }
                .accessibilityLabel("Get attention")

                Spacer()

                if showsDisabilityBadge {
                    Button {
                        isShowingDisabilityCard = true
                    } label: {
                        Image(systemName: PhraseLibrary.disabilityCardIcon)
                    }
                    .accessibilityLabel("Show disability card")

                    Spacer()
                }

                Button {
                    isFlipped.toggle()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                }
                .accessibilityLabel("Flip for reader opposite")
            }
            .buttonStyle(.plain)
            .imageScale(.large)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .background(backgroundColor)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .sheet(isPresented: $isShowingDisabilityCard) {
            DisabilityCardView()
        }
    }

    private func word(at date: Date) -> String {
        guard !words.isEmpty else { return phrase.label }
        let tick = Int(date.timeIntervalSinceReferenceDate / 0.5)
        return words[tick % words.count]
    }
}

#Preview {
    DetailView(phrase: PhraseLibrary.defaults[0])
}
