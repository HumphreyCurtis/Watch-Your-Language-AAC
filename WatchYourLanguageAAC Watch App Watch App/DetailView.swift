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

    @AppStorage(SettingsKeys.showsDisabilityBadge) private var showsDisabilityBadge = true

    @State private var isFlipped = false
    @State private var isShowingDisabilityCard = false

    private var words: [String] {
        phrase.spokenText.split(separator: " ").map(String.init)
    }

    private var backgroundColor: Color {
        PhraseColor.color(named: phrase.colorName)
    }

    var body: some View {
        VStack(spacing: 0) {
            TimelineView(.periodic(from: .now, by: 0.5)) { context in
                VStack(spacing: 10) {
                    Text(word(at: context.date))
                        .font(.system(size: 55, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)

                    if let emoji = phrase.emoji {
                        Text(emoji)
                            .font(.system(size: 30))
                    } else {
                        Image(systemName: phrase.systemIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                }
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
