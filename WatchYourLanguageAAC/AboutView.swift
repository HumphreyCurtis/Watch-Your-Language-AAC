//
//  AboutView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// The story behind the app and ways to support it.
struct AboutView: View {
    private let supportDeveloperURL = URL(string: "https://github.com/sponsors/HumphreyCurtis")!
    private let charityURL = URL(string: "https://aphasiareconnect.org/ways-to-help/donate/")!
    private let researchURL = URL(string: "https://dl.acm.org/doi/10.1145/3597638.3608379")!

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        List {
            Section("About") {
                Text("Watch Your Language is a free AAC communication support app. It helps people with aphasia and other communication needs to be understood — showing and speaking phrases from an Apple Watch, right where a conversation happens.")

                Link(destination: researchURL) {
                    Label("Read or cite the research paper", systemImage: "doc.text")
                }
            }

            Section {
                Link(destination: supportDeveloperURL) {
                    Label("Sponsor development", systemImage: "heart.fill")
                }

                Link(destination: charityURL) {
                    Label("Donate to Aphasia Re-Connect", systemImage: "heart.circle.fill")
                }
            } header: {
                Text("Support")
            } footer: {
                Text("The app is free and always will be. Aphasia Re-Connect is UK registered charity 1176125.")
                    .font(.appFootnote)
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(version)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                }
            }
        }
        .signageSurface()
        .navigationTitle("About")
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
