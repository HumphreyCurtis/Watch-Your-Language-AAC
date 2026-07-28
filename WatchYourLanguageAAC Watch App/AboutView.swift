//
//  AboutView.swift
//  WatchYourLanguageAAC Watch App
//

import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Watch Your Language")
                    .font(.appTitle2)
                    .multilineTextAlignment(.center)

                Text("A free communication support app for people with aphasia and other communication needs, based on accessibility research.")
                    .font(.appBody)
                    .multilineTextAlignment(.center)

                Divider()

                Text("Ways to support the app are in the iPhone app.")
                    .font(.appFootnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(TransportPalette.corporateGrey.color)

                Text("Version \(version)")
                    .font(.appCaption)
                    .foregroundStyle(TransportPalette.corporateGrey.color)
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
