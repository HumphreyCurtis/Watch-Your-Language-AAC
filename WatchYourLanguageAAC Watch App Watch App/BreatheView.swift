//
//  BreatheView.swift
//  WatchYourLanguageAAC Watch App Watch App
//

import SwiftUI
import WatchKit

struct BreatheView: View {
    var body: some View {
        List(BreathingExercise.all) { exercise in
            NavigationLink {
                BreathingSessionView(exercise: exercise)
            } label: {
                PhraseRow(title: exercise.name, systemIcon: exercise.systemIcon)
            }
        }
        .listStyle(.carousel)
        .navigationTitle("Breathing")
    }
}

/// Runs one exercise: the circle grows and shrinks with each phase, and a
/// directional haptic marks the transitions so the exercise can be followed
/// without looking.
struct BreathingSessionView: View {
    let exercise: BreathingExercise

    @State private var phaseLabel = ""
    @State private var scale = 1.0

    var body: some View {
        VStack {
            Text(phaseLabel)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Circle()
                        .fill(Color(red: 111 / 255, green: 151 / 255, blue: 167 / 255))
                        .frame(width: 60, height: 60)
                        .scaleEffect(scale)
                )
        }
        .navigationTitle(exercise.name)
        .task {
            var index = 0
            while !Task.isCancelled {
                let phase = exercise.phases[index]
                phaseLabel = phase.label
                WKInterfaceDevice.current().play(haptic(for: phase.kind))
                withAnimation(.easeInOut(duration: phase.duration)) {
                    scale = phase.scale
                }
                try? await Task.sleep(for: .seconds(phase.duration))
                index = (index + 1) % exercise.phases.count
            }
        }
    }

    private func haptic(for kind: BreathingExercise.PhaseKind) -> WKHapticType {
        switch kind {
        case .inhale: .directionUp
        case .exhale: .directionDown
        case .hold: .click
        }
    }
}

#Preview {
    NavigationStack {
        BreatheView()
    }
}
