//
//  BreathingExercise.swift
//  WatchYourLanguageAAC
//

import Foundation

/// A guided breathing pattern: each phase scales the animated circle for its
/// duration. Phase kinds are semantic so each platform can map them to its
/// own haptics.
struct BreathingExercise: Identifiable {
    enum PhaseKind {
        case inhale, hold, exhale
    }

    struct Phase {
        let kind: PhaseKind
        let label: String
        let duration: Double
        /// Circle scale at the end of the phase (1 = contracted, 2 = expanded).
        let scale: Double
    }

    let id: String
    let name: String
    let systemIcon: String
    let phases: [Phase]

    private static func inhale(_ seconds: Double) -> Phase {
        Phase(kind: .inhale, label: "Breathe in", duration: seconds, scale: 2)
    }

    private static func exhale(_ seconds: Double) -> Phase {
        Phase(kind: .exhale, label: "Breathe out", duration: seconds, scale: 1)
    }

    private static func hold(_ seconds: Double, scale: Double) -> Phase {
        Phase(kind: .hold, label: "Hold", duration: seconds, scale: scale)
    }

    static let all: [BreathingExercise] = [
        BreathingExercise(
            id: "deep",
            name: "Deep Breaths",
            systemIcon: "lungs",
            phases: [inhale(3), exhale(3)]
        ),
        BreathingExercise(
            id: "box",
            name: "Box Breathing",
            systemIcon: "square",
            phases: [inhale(4), hold(4, scale: 2), exhale(4), hold(4, scale: 1)]
        ),
        BreathingExercise(
            id: "relax",
            name: "4-7-8 Relax",
            systemIcon: "moon.zzz",
            phases: [inhale(4), hold(7, scale: 2), exhale(8)]
        ),
    ]
}
