//
//  SettingsView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.prefersFemaleVoice) private var prefersFemaleVoice = false

    private var settings: SettingsStore { .shared }

    private var speechRate: Binding<Double> {
        Binding(
            get: { settings.speechRate },
            set: { settings.setSpeechRate($0) }
        )
    }

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
                #if os(iOS)
                Slider(
                    value: speechRate,
                    in: 0.3...0.7,
                    step: 0.05
                ) {
                    Text("Speaking speed")
                } minimumValueLabel: {
                    Image(systemName: "tortoise.fill")
                        .foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Image(systemName: "hare.fill")
                        .foregroundStyle(.secondary)
                }
                #else
                Slider(value: speechRate, in: 0.3...0.7, step: 0.05) {
                    Text("Speed")
                }
                #endif

                Button("Test voice") {
                    Speaker.shared.speak("Hello, this is how I will speak.")
                }
            } header: {
                Label("Speaking Speed", systemImage: "gauge.with.needle")
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
