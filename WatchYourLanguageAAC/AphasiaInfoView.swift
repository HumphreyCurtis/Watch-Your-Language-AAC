//
//  AphasiaInfoView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Explains aphasia to a conversation partner, laid out for the iPhone:
/// grouped sections with tap-to-speak rows, a link, and the QR code the
/// watch also shows.
struct AphasiaInfoView: View {
    var body: some View {
        List {
            Section {
                ForEach(AphasiaInfo.explainers, id: \.self) { line in
                    SpeakableRow(text: line)
                }
            } header: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Helps conversation partners understand aphasia and communicate well.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(nil)

                    Text("What is aphasia?")
                }
            } footer: {
                Text("Tap a sentence to speak it aloud.")
            }

            Section("Tips for communication") {
                ForEach(Array(AphasiaInfo.tips.enumerated()), id: \.offset) { index, tip in
                    SpeakableRow(text: tip, prefix: "\(index + 1).")
                }
            }

            Section("Learn more") {
                Link(destination: AphasiaInfo.learnMoreURL) {
                    Label("Aphasia and its effects — Stroke Association", systemImage: "safari")
                }

                VStack(spacing: 8) {
                    Image("AphasiaQRCode")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .accessibilityLabel("QR code linking to aphasia information from the Stroke Association")

                    Text("Show this code so a conversation partner can scan it and learn more.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Aphasia")
    }
}

private struct SpeakableRow: View {
    let text: String
    var prefix: String?

    var body: some View {
        Button {
            Speaker.shared.speak(text)
        } label: {
            HStack {
                Text(prefix.map { "\($0) \(text)" } ?? text)
                Spacer()
                Image(systemName: "speaker.wave.2")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .tint(.primary)
    }
}

#Preview {
    NavigationStack {
        AphasiaInfoView()
    }
}
