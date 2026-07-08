//
//  AboutView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The story behind the app and ways to support it.
struct AboutView: View {
    // TODO: Replace with your real Buy Me a Coffee (or similar) page before release.
    private let supportDeveloperURL = URL(string: "https://www.buymeacoffee.com/humphreycurtis")!
    private let charityURL = URL(string: "https://aphasiareconnect.org/")!
    private let researchURL = URL(string: "https://dl.acm.org/doi/10.1145/3597638.3608379")!

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        List {
            Section("About") {
                Text("Watch Your Language is a free communication support app. It helps people with aphasia and other communication needs to be understood — showing and speaking phrases from an Apple Watch, right where a conversation happens.")

                Text("It began as published accessibility research into how smartwatches can support communication, and is developed in that spirit: simple, glanceable, and designed with people with aphasia.")

                Link(destination: researchURL) {
                    Label("Read the research (ASSETS 2023)", systemImage: "doc.text")
                }
            }

            Section {
                Link(destination: supportDeveloperURL) {
                    Label("Buy me a coffee", systemImage: "cup.and.saucer.fill")
                }

                Link(destination: charityURL) {
                    Label("Donate to Aphasia Re-Connect", systemImage: "heart.circle.fill")
                }
            } header: {
                Text("Support")
            } footer: {
                Text("The app is free and always will be. If it helps you, you can support its development, or donate to Aphasia Re-Connect (UK registered charity 1176125), which runs services with and for people with aphasia.")
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(version)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
