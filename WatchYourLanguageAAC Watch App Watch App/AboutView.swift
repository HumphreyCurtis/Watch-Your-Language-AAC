//
//  AboutView.swift
//  WatchYourLanguageAAC Watch App Watch App
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
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("A free communication support app for people with aphasia and other communication needs, based on accessibility research.")
                    .multilineTextAlignment(.center)

                Divider()

                Text("Ways to support the app are in the iPhone app.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("Version \(version)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
