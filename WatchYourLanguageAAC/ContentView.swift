//
//  ContentView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// Home screen: the app's six main features, mirroring the watch app.
///
/// Each destination keeps one colour wherever it appears, on both devices,
/// so the app can be navigated by colour as much as by reading.
struct ContentView: View {

    private enum Feature {
        case phrases, keywords, breathing, aphasiaInfo, settings, about
    }

    /// One destination and the line colour that identifies it throughout.
    private struct Destination: Identifiable {
        let id = UUID()
        let feature: Feature
        let title: String
        let systemIcon: String
        let tint: SignageColor
    }

    private let destinations: [Destination] = [
        Destination(
            feature: .phrases,
            title: "Phrases",
            systemIcon: "text.bubble.fill",
            tint: TransportPalette.central
        ),
        Destination(
            feature: .keywords,
            title: "Keywords",
            systemIcon: "key.fill",
            tint: TransportPalette.piccadilly
        ),
        Destination(
            feature: .breathing,
            title: "Breathing",
            systemIcon: "lungs",
            tint: TransportPalette.victoria
        ),
        Destination(
            feature: .aphasiaInfo,
            title: "Aphasia Info",
            systemIcon: "person.fill.questionmark",
            tint: TransportPalette.district
        ),
        Destination(
            feature: .settings,
            title: "Settings",
            systemIcon: "gear",
            tint: TransportPalette.corporateGrey
        ),
        Destination(
            feature: .about,
            title: "About",
            systemIcon: "info.circle.fill",
            tint: TransportPalette.elizabeth
        ),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(destinations) { destination in
                        NavigationLink {
                            view(for: destination.feature)
                        } label: {
                            SignageRow(
                                title: destination.title,
                                systemIcon: destination.systemIcon,
                                tint: destination.tint
                            )
                        }
                        .signageRowStyle()
                    }
                } header: {
                    introduction
                }
            }
            .listStyle(.plain)
            .signageSurface()
            .navigationTitle("Watch Your Language")
        }
    }

    /// Two lines saying what the app is for, above the menu. Short by
    /// design: it is read once, and the rows below are the point.
    private var introduction: some View {
        Text("Show and speak phrases from your Apple Watch.\nMade with and for people with aphasia.")
            .font(.appSubheadline)
            .foregroundStyle(TransportPalette.corporateGrey.color)
            .textCase(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
    }

    @ViewBuilder
    private func view(for feature: Feature) -> some View {
        switch feature {
        case .phrases: PhrasesView()
        case .keywords: KeywordsView()
        case .breathing: BreatheView()
        case .aphasiaInfo: AphasiaInfoView()
        case .settings: SettingsView()
        case .about: AboutView()
        }
    }
}

#Preview {
    ContentView()
}
