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
                        Label(exercise.name, systemImage: exercise.systemIcon)
                            .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Slow, guided breathing to ease communication anxiety before or during a conversation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
        }
        .navigationTitle("Breathing")
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
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Circle()
                        .fill(Color(red: 111 / 255, green: 151 / 255, blue: 167 / 255))
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
