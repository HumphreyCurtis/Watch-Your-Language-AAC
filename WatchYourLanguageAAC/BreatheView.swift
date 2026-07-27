//
//  BreatheView.swift
//  WatchYourLanguageAAC
//

import SwiftUI

struct BreatheView: View {
    var body: some View {
        List {
            Section {
                ForEach(BreathingExercise.all) { exercise in
                    NavigationLink {
                        BreathingSessionView(exercise: exercise)
                    } label: {
                        SignageRow(
                            title: exercise.name,
                            systemIcon: exercise.systemIcon,
                            tint: TransportPalette.victoria
                        )
                    }
                    .signageRowStyle()
                }
            } header: {
                PlatformHeader(text: "Exercises", tint: TransportPalette.victoria)
                    // A `.plain` list gives its headers a tall top inset and
                    // no leading one, which put this lower and further left
                    // than the same header on the grouped screens. Matching
                    // their position by hand keeps the app's headings on one
                    // line as you move between screens.
                    .listRowInsets(EdgeInsets(top: 0, leading: 32, bottom: 4, trailing: 20))
            }
        }
        .listStyle(.plain)
        .signageSurface()
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Runs one exercise: the circle grows and shrinks with each phase, with a
/// gentle haptic marking the transitions — mirroring the watch experience.
struct BreathingSessionView: View {
    let exercise: BreathingExercise

    @State private var phaseLabel = ""
    @State private var scale = 1.0

    var body: some View {
        VStack {
            Text(phaseLabel)
                .font(.appTitle2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Circle()
                        .fill(TransportPalette.calmSlate.color)
                        .frame(width: 130, height: 130)
                        .scaleEffect(scale)
                )
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            var index = 0
            while !Task.isCancelled {
                let phase = exercise.phases[index]
                phaseLabel = phase.label
                haptic(for: phase.kind)
                withAnimation(.easeInOut(duration: phase.duration)) {
                    scale = phase.scale
                }
                try? await Task.sleep(for: .seconds(phase.duration))
                index = (index + 1) % exercise.phases.count
            }
        }
    }

    private func haptic(for kind: BreathingExercise.PhaseKind) {
        switch kind {
        case .inhale:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .exhale:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .hold:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

#Preview {
    NavigationStack {
        BreatheView()
    }
}
