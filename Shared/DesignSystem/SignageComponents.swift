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

    var body: some View {
        HStack(spacing: 14) {
            RoundelBadge(systemIcon: systemIcon, emoji: emoji, tint: tint, size: badgeSize)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundStyle(TransportPalette.ink(colorScheme))

                if let subtitle {
                    Text(subtitle)
                        .font(.appSubheadline)
                        .foregroundStyle(TransportPalette.corporateGrey.color)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .leading)
        .background(TransportPalette.block(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // The watch stays compact — every row competes for a very small screen.
    // The phone has room to breathe, and generous targets are easier to hit
    // for someone with limited dexterity.

    private var badgeSize: CGFloat {
        #if os(watchOS)
        28
        #else
        38
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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text.uppercased())
                .font(.appCaption)
                .kerning(1.4)
                .foregroundStyle(TransportPalette.corporateGrey.color)

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
    func signageSurface() -> some View {
        modifier(SignageSurface())
    }
}

private struct SignageSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(TransportPalette.surface(colorScheme))
    }
}

/// Strips the default list-row inset and background so a `SignageRow` fills
/// the row and controls its own edges.
extension View {
    func signageRowStyle() -> some View {
        // `listRowSeparator` is iOS-only; watchOS lists draw no separators.
        #if os(watchOS)
        self
            .listRowInsets(EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4))
            .listRowBackground(Color.clear)
        #else
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .listRowBackground(Color.clear)
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
