//
//  AphasiaInfoView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI

/// Explains aphasia to a conversation partner. Each block is tappable to be
/// spoken aloud; the QR code links to stroke.org.uk's aphasia explainer.
struct AphasiaInfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image("AphasiaQRCode")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .padding(.bottom)
                    .accessibilityLabel("QR code linking to aphasia information from the Stroke Association")

                Divider()

                ForEach(AphasiaInfo.explainers, id: \.self) { line in
                    Text(line)
                        .multilineTextAlignment(.center)
                        .padding()
                        .font(.title3)
                        .fontWeight(.bold)
                        .onTapGesture {
                            Speaker.shared.speak(line)
                        }

                    Divider()
                }

                Text("Tips")
                    .padding(.bottom)
                    .font(.title3)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(AphasiaInfo.tips.enumerated()), id: \.offset) { index, tip in
                        Text("\(index + 1). \(tip)")
                            .fontWeight(.bold)
                    }
                }
                .onTapGesture {
                    Speaker.shared.speak(AphasiaInfo.tipsSpokenText)
                }
            }
        }
        .navigationTitle("Aphasia Info")
    }
}

#Preview {
    NavigationStack {
        AphasiaInfoView()
    }
}
