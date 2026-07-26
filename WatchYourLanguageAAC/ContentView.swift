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
                Section {
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
                        KeywordsView()
                    } label: {
                        HomeRow(
                            title: "Keywords",
                            subtitle: "Names, addresses and places - ready to store and speak",
                            systemIcon: "key.fill"
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
                            title: "Aphasia Info",
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

                    NavigationLink {
                        AboutView()
                    } label: {
                        HomeRow(
                            title: "About",
                            subtitle: "The story behind the app and ways to support it",
                            systemIcon: "info.circle.fill"
                        )
                    }
                } header: {
                    Text("Co-designed with communities with aphasia and ready for communication in other languages too!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
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
