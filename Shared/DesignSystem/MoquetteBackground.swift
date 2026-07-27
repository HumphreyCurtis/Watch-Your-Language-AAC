//
//  MoquetteBackground.swift
//  WatchYourLanguageAAC
//

import SwiftUI

#if os(iOS)

/// The seat-fabric pattern, drawn very quietly behind the phone's home screen.
///
/// Moquette is the woven wool on Underground seats: small repeating geometry
/// in the line colours, chosen originally because it hides wear. It belongs
/// to the same design language as the roundel and the signage type, and it
/// gives the phone a surface with something in it without reaching for the
/// gradients `TransportPalette` rules out — this is pattern, not shading.
///
/// It is decoration, so it defers. At 5–8% opacity it sits well under the
/// row blocks, and it disappears entirely for anyone who has asked the system
/// for more contrast or less transparency. In an app for people with aphasia
/// and low vision, ornament is the first thing that should go.
struct MoquetteBackground: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// One repeat of the motif. Large enough that the geometry reads as a
    /// pattern rather than as noise on a retina screen.
    private let tile: CGFloat = 64

    private var showsPattern: Bool {
        colorSchemeContrast != .increased && !reduceTransparency
    }

    /// Deliberately low. The pattern should be something you notice on the
    /// second look, never something you read past.
    private var patternOpacity: Double {
        colorScheme == .dark ? 0.08 : 0.05
    }

    /// The line colours, in the order they alternate across the weave.
    private var threads: [Color] {
        [
            TransportPalette.central.color,
            TransportPalette.piccadilly.color,
            TransportPalette.district.color,
            TransportPalette.victoria.color,
            TransportPalette.elizabeth.color,
        ]
    }

    var body: some View {
        TransportPalette.surface(colorScheme)
            .overlay {
                if showsPattern {
                    Canvas { context, size in
                        draw(in: &context, size: size)
                    }
                    .opacity(patternOpacity)
                    // Flattened once rather than recomposited while the list
                    // scrolls over it.
                    .drawingGroup()
                }
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    /// Staggered lozenges with a chevron struck through each one — the
    /// half-drop repeat that gives real moquette its diagonal grain.
    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let columns = Int(ceil(size.width / tile)) + 1
        let rows = Int(ceil(size.height / tile)) + 1

        for row in 0..<rows {
            for column in 0..<columns {
                // Every other row steps half a tile sideways, so the motif
                // never lines up into vertical stripes.
                let offsetX = row.isMultiple(of: 2) ? 0 : tile / 2
                let origin = CGPoint(
                    x: CGFloat(column) * tile - offsetX,
                    y: CGFloat(row) * tile
                )

                // Walking the colours by row *and* column keeps any one
                // colour from forming a diagonal run of its own.
                let thread = threads[(row + column) % threads.count]

                context.fill(lozenge(at: origin), with: .color(thread))
                context.stroke(chevron(at: origin), with: .color(thread), lineWidth: 2)
            }
        }
    }

    private func lozenge(at origin: CGPoint) -> Path {
        let inset = tile * 0.22
        let width = tile - inset * 2
        let height = tile * 0.3

        var path = Path()
        path.move(to: CGPoint(x: origin.x + tile / 2, y: origin.y + inset))
        path.addLine(to: CGPoint(x: origin.x + inset + width, y: origin.y + inset + height / 2))
        path.addLine(to: CGPoint(x: origin.x + tile / 2, y: origin.y + inset + height))
        path.addLine(to: CGPoint(x: origin.x + inset, y: origin.y + inset + height / 2))
        path.closeSubpath()
        return path
    }

    private func chevron(at origin: CGPoint) -> Path {
        let inset = tile * 0.18
        let baseline = origin.y + tile * 0.78

        var path = Path()
        path.move(to: CGPoint(x: origin.x + inset, y: baseline))
        path.addLine(to: CGPoint(x: origin.x + tile / 2, y: baseline - tile * 0.16))
        path.addLine(to: CGPoint(x: origin.x + tile - inset, y: baseline))
        return path
    }
}

#Preview {
    MoquetteBackground()
}

#endif
