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
                PlatformHeader(text: "What is aphasia?", tint: TransportPalette.district)
            } footer: {
                Text("Tap a sentence to speak it.")
                    .font(.appFootnote)
            }

            Section {
                ForEach(Array(AphasiaInfo.tips.enumerated()), id: \.offset) { index, tip in
                    SpeakableRow(text: tip, prefix: "\(index + 1).")
                }
            } header: {
                PlatformHeader(text: "Tips for communication", tint: TransportPalette.district)
            }

            Section {
                Link(destination: AphasiaInfo.learnMoreURL) {
                    Label("Read more about aphasia", systemImage: "safari")
                }

                VStack(spacing: 8) {
                    Image("AphasiaQRCode")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .accessibilityLabel("QR code linking to aphasia information from the Stroke Association")

                    Text("Scan to learn more about aphasia.")
                        .font(.appFootnote)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } header: {
                PlatformHeader(text: "Learn more", tint: TransportPalette.district)
            }
        }
        // Otherwise the `Link`'s label falls back to SF.
        .font(.appBody)
        .signageSurface()
        .navigationTitle("Aphasia")
        .navigationBarTitleDisplayMode(.inline)
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
                    .font(.appBody)
                Spacer()
                Image(systemName: "speaker.wave.2")
                    .font(.appFootnote)
                    .foregroundStyle(TransportPalette.corporateGrey.color)
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
