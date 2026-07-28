//
//  SignageComponents.swift
//  WatchYourLanguageAAC
//

import SwiftUI

/// A circular icon badge in a line colour.
///
/// Colour is carried by this one small element rather than by blocks and
/// rules, so a screen reads as mostly white with a single point of colour —
/// the restraint of a good sign, not the whole livery.
struct RoundelBadge: View {
    let systemIcon: String
    var emoji: String?
    var tint: SignageColor = TransportPalette.roundelBlue
    var size: CGFloat = 40

    /// Overrides the computed icon colour. Used where the badge sits on a
    /// coloured screen and is reversed out of it.
    var iconColor: Color?

    private var foreground: Color {
        iconColor ?? tint.readableForeground.color
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.color)
                .frame(width: size, height: size)

            if let emoji {
                Text(emoji)
                    .font(.system(size: size * 0.5))
            } else {
                Image(systemName: systemIcon)
                    .font(.system(size: size * 0.44, weight: .semibold))
                    .foregroundStyle(foreground)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// A destination row: a coloured badge, a bold title, and nothing else
/// competing for attention.
struct SignageRow: View {
    let title: String
    var subtitle: String?
    let systemIcon: String
    var emoji: String?
    var tint: SignageColor = TransportPalette.roundelBlue

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // The badge grows with the text. Someone who has turned type up needs
    // the icon bigger too — a 38pt circle beside 90pt text reads as an
    // afterthought and loses the colour cue that identifies the row.
    #if os(watchOS)
    @ScaledMetric(relativeTo: .title2) private var scaledBadge: CGFloat = 28
    #else
    @ScaledMetric(relativeTo: .headline) private var scaledBadge: CGFloat = 38
    #endif

    /// Side by side normally; badge above text at accessibility sizes.
    ///
    /// Beyond a point the badge and the text cannot share a line — the text
    /// column gets so narrow that single words break mid-word. Stacking
    /// gives the title the full width instead.
    private var layout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
            : AnyLayout(HStackLayout(spacing: 14))
    }

    var body: some View {
        layout {
            RoundelBadge(systemIcon: systemIcon, emoji: emoji, tint: tint, size: badgeSize)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundStyle(TransportPalette.ink(colorScheme))

                if let subtitle {
                    Text(subtitle)
                        // One line normally, but at accessibility sizes a
                        // single line shows almost nothing of a sentence.
                        .font(.appSubheadline)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .leading)
        // No background of its own: `signageRowStyle()` puts the block behind
        // the whole list row instead, so it reaches under the disclosure
        // chevron rather than stopping short of it and leaving the arrow
        // stranded on the surface outside the block.
    }

    // The watch stays compact — every row competes for a very small screen.
    // The phone has room to breathe, and generous targets are easier to hit
    // for someone with limited dexterity.

    /// Capped so the badge stays a marker beside the text rather than
    /// growing into a competing block at the largest settings.
    private var badgeSize: CGFloat {
        #if os(watchOS)
        min(scaledBadge, 40)
        #else
        min(scaledBadge, 58)
        #endif
    }

    private var verticalPadding: CGFloat {
        #if os(watchOS)
        8
        #else
        18
        #endif
    }

    private var horizontalPadding: CGFloat {
        #if os(watchOS)
        12
        #else
        16
        #endif
    }

    private var minimumHeight: CGFloat {
        #if os(watchOS)
        0
        #else
        72
        #endif
    }

    private var cornerRadius: CGFloat {
        #if os(watchOS)
        10
        #else
        14
        #endif
    }
}

/// A quiet section heading: small letterspaced capitals over a hairline rule
/// in the section's colour. The signage reference without the paint.
struct PlatformHeader: View {
    let text: String
    var tint: SignageColor = TransportPalette.roundelBlue

    /// An optional symbol before the text, for screens like Settings where
    /// the icon is doing real work telling one section from another.
    var systemIcon: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Baseline-aligned, so a heading that wraps keeps its icon
            // beside the first line rather than floating to the middle.
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.appCaption)
                        .foregroundStyle(tint.color)
                        .accessibilityHidden(true)
                }

                Text(text.uppercased())
                    .font(.appCaption)
                    .kerning(1.4)
                    .foregroundStyle(TransportPalette.corporateGrey.color)
            }

            Rectangle()
                .fill(tint.color)
                .frame(width: 28, height: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
        .accessibilityLabel(text)
    }
}

extension View {
    /// Puts a view on the signage surface, hiding the system list chrome so
    /// custom row blocks read as flat panels rather than inset cards.
    ///
    /// - Parameter moquette: draws the seat-fabric pattern behind the
    ///   surface. On by default on iPhone, so the app has one surface
    ///   throughout rather than a decorated home screen and plain rooms off
    ///   it. Pass `false` for a screen that needs a dead-flat background.
    ///   Ignored on the watch, where the pattern is never drawn.
    func signageSurface(moquette: Bool = true) -> some View {
        modifier(SignageSurface(moquette: moquette))
    }
}

private struct SignageSurface: ViewModifier {
    var moquette = true

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                #if os(iOS)
                if moquette {
                    MoquetteBackground()
                } else {
                    TransportPalette.surface(colorScheme)
                }
                #else
                TransportPalette.surface(colorScheme)
                #endif
            }
    }
}

/// Puts a `SignageRow` on a full-width signage block.
///
/// The block is the row's background rather than the row content's, so it
/// spans the whole width the list gives the row — including the disclosure
/// chevron, which a `NavigationLink` lays out as part of the row. Drawn
/// inside the content, the block stopped short and left the arrow sitting on
/// the surface beside it.
extension View {
    func signageRowStyle() -> some View {
        modifier(SignageRowStyle())
    }
}

private struct SignageRowStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        // `listRowSeparator` is iOS-only; watchOS lists draw no separators.
        #if os(watchOS)
        content
            .listRowInsets(EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 10)
                    .fill(TransportPalette.block(colorScheme))
            )
        #else
        content
            // No leading inset: `SignageRow` carries its own padding, so the
            // block can run to the edge of the row. The trailing inset is
            // what keeps the chevron off the block's right edge.
            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 16))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 14)
                    .fill(TransportPalette.block(colorScheme))
                    .padding(.vertical, 6)
            )
            .listRowSeparator(.hidden)
        #endif
    }
}

#Preview {
    VStack(spacing: 8) {
        PlatformHeader(text: "Phrases")
        SignageRow(title: "Phrases", systemIcon: "text.bubble.fill", tint: TransportPalette.central)
        SignageRow(title: "Keywords", systemIcon: "key.fill", tint: TransportPalette.piccadilly)
        SignageRow(
            title: "Seat",
            subtitle: "Could you please let me have your seat?",
            systemIcon: "chair.fill",
            tint: TransportPalette.district
        )
    }
    .padding()
}
