//
//  SettingsView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

struct SettingsView: View {
    private var settings: SettingsStore { .shared }

    /// Through the store, not `@AppStorage`: this was the one setting that
    /// stayed on the device it was set on, so the phone and the watch could
    /// disagree about the voice.
    private var prefersFemaleVoice: Binding<Bool> {
        Binding(
            get: { settings.prefersFemaleVoice },
            set: { settings.setPrefersFemaleVoice($0) }
        )
    }

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
            // Switches first, then the sliders. The two kinds of control
            // read very differently at a glance, and keeping them apart
            // makes the screen scannable rather than a mixed list.
            Section {
                Toggle("Female voice", isOn: prefersFemaleVoice)

                Toggle("Disability badge", isOn: Binding(
                    get: { settings.showsDisabilityBadge },
                    set: { settings.setShowsDisabilityBadge($0) }
                ))
            } header: {
                // The sentence is the heading, as on the other screens,
                // rather than a label with a sentence above it.
                PlatformHeader(
                    text: "Choose the voice and what shows on the watch",
                    tint: TransportPalette.corporateGrey,
                    systemIcon: "switch.2"
                )
            } footer: {
                Text("The disability badge adds a button to the watch phrase screens that shows a disability card.")
                    .font(.appFootnote)
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
                PlatformHeader(
                    text: "Words on screen",
                    tint: TransportPalette.corporateGrey,
                    systemIcon: "timer"
                )
            } footer: {
                Text("How long each word of a phrase is held on the watch before the next one.")
                    .font(.appFootnote)
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
                PlatformHeader(
                    text: "Speaking speed",
                    tint: TransportPalette.corporateGrey,
                    systemIcon: "gauge.with.needle"
                )
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
