//
//  SettingsView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.prefersFemaleVoice) private var prefersFemaleVoice = false

    private var settings: SettingsStore { .shared }

    var body: some View {
        Form {
            Section {
                Toggle("Female voice", isOn: $prefersFemaleVoice)
            } header: {
                #if os(iOS)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Choose the voice the app speaks with and what appears on the watch.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(nil)

                    Label("System Voice", systemImage: "speaker.wave.2.circle.fill")
                }
                #else
                Label("System Voice", systemImage: "speaker.wave.2.circle.fill")
                #endif
            }

            Section {
                Toggle("Disability badge", isOn: Binding(
                    get: { settings.showsDisabilityBadge },
                    set: { settings.setShowsDisabilityBadge($0) }
                ))
            } footer: {
                Text("Show the blue disability card button on the watch phrase screens. Turn off when using the app for general language support.")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
