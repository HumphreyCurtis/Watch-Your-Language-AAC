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

    /// The word pace, mirrored so the slider runs slow-to-fast like the voice
    /// one above it.
    ///
    /// What is stored is a duration — how long each word is held — so a
    /// bigger number means a *slower* read. Binding the slider to the raw
    /// value would make it run backwards next to the speech slider, which is
    /// exactly the kind of inconsistency this app cannot afford.
    private var wordSpeed: Binding<Double> {
        Binding(
            get: { WordPace.slowest + WordPace.fastest - settings.wordInterval },
            set: { settings.setWordInterval(WordPace.slowest + WordPace.fastest - $0) }
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
                        .font(.appSubheadline)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
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
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                } maximumValueLabel: {
                    Image(systemName: "hare.fill")
                        .foregroundStyle(TransportPalette.corporateGrey.color)
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
                #if os(iOS)
                Slider(
                    value: wordSpeed,
                    in: WordPace.fastest...WordPace.slowest,
                    step: 0.1
                ) {
                    Text("Word speed")
                } minimumValueLabel: {
                    Image(systemName: "tortoise.fill")
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                } maximumValueLabel: {
                    Image(systemName: "hare.fill")
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                }
                #else
                Slider(value: wordSpeed, in: WordPace.fastest...WordPace.slowest, step: 0.1) {
                    Text("Speed")
                }
                #endif
            } header: {
                Label("Words On Screen", systemImage: "timer")
            } footer: {
                Text("How long each word of a phrase is held on the watch before the next one.")
                    .font(.appFootnote)
            }

            Section {
                Toggle("Disability badge", isOn: Binding(
                    get: { settings.showsDisabilityBadge },
                    set: { settings.setShowsDisabilityBadge($0) }
                ))
            } footer: {
                Text("Adds a button to the watch phrase screens that shows a disability card.")
                    .font(.appFootnote)
            }
        }
        // `Toggle`, `Slider` and `Button` labels are system controls and
        // default to SF; the form-wide font is what brings them into
        // Atkinson with the rest of the app.
        .font(.appBody)
        .signageSurface()
        .navigationTitle("Settings")
        // This file builds for the watch too, where the modifier does not
        // exist and the title is left to the system.
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
