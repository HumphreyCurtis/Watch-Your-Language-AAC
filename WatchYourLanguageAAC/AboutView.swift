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
            Section {
                Text("Watch Your Language is a free AAC communication support app. It helps people with aphasia and other communication needs to be understood — showing and speaking phrases from an Apple Watch, right where a conversation happens.")

                Link(destination: researchURL) {
                    Label("Read or cite the research paper", systemImage: "doc.text")
                }
            } header: {
                PlatformHeader(text: "About", tint: TransportPalette.elizabeth)
            }

            Section {
                Link(destination: supportDeveloperURL) {
                    Label("Sponsor development", systemImage: "heart.fill")
                }

                Link(destination: charityURL) {
                    Label("Donate to Aphasia Re-Connect", systemImage: "heart.circle.fill")
                }
            } header: {
                PlatformHeader(text: "Support", tint: TransportPalette.elizabeth)
            } footer: {
                Text("The app is free and always will be. Aphasia Re-Connect is UK registered charity 1176125.")
                    .font(.appFootnote)
            }

            Section {
                ForEach(CoDesignMoment.all) { moment in
                    CoDesignCard(moment: moment)
                }
            } header: {
                PlatformHeader(text: "Co-design", tint: TransportPalette.elizabeth)
            } footer: {
                Text("The app was designed with people with aphasia, in workshops run with Aphasia Re-Connect - almost everything here started on one of these tables.")
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
        // System controls — `Link`, `Label`, plain `Text` — default to SF.
        // Setting the font on the list is what makes them Atkinson too,
        // rather than annotating every row.
        .font(.appBody)
        .signageSurface()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A moment from the co-design workshops, shown on the About screen.
///
/// Ordered as the work happened: the room, then what was drawn in it, then
/// the drawings being tried on a real watch.
private struct CoDesignMoment: Identifiable {
    let id = UUID()
    let asset: String
    let caption: String

    /// How tall the image may be drawn. The default suits a landscape
    /// photograph or a worksheet; the tall sequence needs more, or it ends up
    /// too narrow to make out.
    var maxHeight: CGFloat = 300

    static let all: [CoDesignMoment] = [
        CoDesignMoment(
            asset: "CoDesignWorkshop",
            caption: "A co-design workshop at Aphasia Re-Connect. The app was designed with the people who would go on to use it."
        ),
        CoDesignMoment(
            asset: "CoDesignStrokePhrases",
            caption: "Workshop sketch: the phrases the app still ships with — and the tortoise that became “please speak slowly”."
        ),
        CoDesignMoment(
            asset: "CoDesignSavedWords",
            caption: "“Saved common forgotten words”, and a note to display them large - this became Keywords."
        ),
        CoDesignMoment(
            asset: "CoDesignShowingWatch",
            caption: "Showing a phrase across a table — the moment the whole app is built around.",
            maxHeight: 460
        ),
        CoDesignMoment(
            asset: "CoDesignScanningQR",
            caption: "Testing the code on the watch that explains aphasia to the person opposite."
        ),
    ]
}

private struct CoDesignCard: View {
    let moment: CoDesignMoment

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(moment.asset)
                .resizable()
                // Fitted, not filled: these are documents and photographs
                // where the content runs to the edges, and cropping them to a
                // uniform rectangle would cut out the very thing being shown.
                // The cap stops a tall image taking a whole screen to itself.
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: moment.maxHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(moment.caption)
                .font(.appFootnote)
                .foregroundStyle(TransportPalette.corporateGrey.color)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(moment.caption)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
