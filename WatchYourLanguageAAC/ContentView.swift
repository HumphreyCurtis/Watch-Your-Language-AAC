//
//  ContentView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Home screen: the app's five main features, mirroring the watch app.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    PhrasesView()
                } label: {
                    HomeRow(
                        title: "Phrases",
                        subtitle: "Speak and customise phrases",
                        systemIcon: "text.bubble.fill"
                    )
                }

                NavigationLink {
                    WordsView()
                } label: {
                    HomeRow(
                        title: "Words",
                        subtitle: "Find, favourite and add single words",
                        systemIcon: "scroll.fill"
                    )
                }

                NavigationLink {
                    BreatheView()
                } label: {
                    HomeRow(
                        title: "Breathing",
                        subtitle: "Calming breathing exercises",
                        systemIcon: "lungs"
                    )
                }

                NavigationLink {
                    AphasiaInfoView()
                } label: {
                    HomeRow(
                        title: "Aphasia",
                        subtitle: "Information for conversation partners",
                        systemIcon: "person.fill.questionmark"
                    )
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    HomeRow(
                        title: "Settings",
                        subtitle: "Voice options",
                        systemIcon: "gear"
                    )
                }
            }
            .navigationTitle("Watch Your Language")
        }
    }
}

private struct HomeRow: View {
    let title: String
    let subtitle: String
    let systemIcon: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemIcon)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
