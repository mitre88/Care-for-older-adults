//
//  Typography.swift
//  GentleCare
//
//  San Francisco Pro typography system for elderly users
//

import SwiftUI

// MARK: - Typography

enum GCTypography {

    // MARK: - Display (Hero text)

    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 34, weight: .bold, design: .default)

    // MARK: - Headlines

    static let headline1 = Font.system(size: 28, weight: .bold, design: .default)
    static let headline2 = Font.system(size: 24, weight: .semibold, design: .default)
    static let headline3 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: - Titles

    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Body Text (Primary reading)

    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Labels

    static let labelLarge = Font.system(size: 16, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)

    // MARK: - Captions

    static let captionLarge = Font.system(size: 14, weight: .regular, design: .default)
    static let captionMedium = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Numerics (For vital signs, times, etc.)

    static let numericLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let numericMedium = Font.system(size: 36, weight: .bold, design: .rounded)
    static let numericSmall = Font.system(size: 28, weight: .semibold, design: .rounded)

    // MARK: - Button Text

    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)
}

// MARK: - Font Extensions

extension Font {

    /// Standard body font optimized for elderly reading
    static var gcBody: Font { GCTypography.bodyLarge }

    /// Large readable title
    static var gcTitle: Font { GCTypography.titleLarge }

    /// Primary headline
    static var gcHeadline: Font { GCTypography.headline2 }

    /// Large numeric display (vitals, time)
    static var gcNumeric: Font { GCTypography.numericMedium }

    /// Button text
    static var gcButton: Font { GCTypography.buttonLarge }

    /// Secondary/caption text
    static var gcCaption: Font { GCTypography.captionLarge }

    /// Label text
    static var gcLabel: Font { GCTypography.labelMedium }
}

// MARK: - Text Style Modifiers

struct GCTextStyle: ViewModifier {

    enum Style {
        case displayLarge
        case displayMedium
        case headline1
        case headline2
        case headline3
        case titleLarge
        case titleMedium
        case bodyLarge
        case bodyMedium
        case labelLarge
        case labelMedium
        case caption
        case numericLarge
        case numericMedium
        case button
    }

    let style: Style
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font(for: style))
            .foregroundStyle(color)
    }

    private func font(for style: Style) -> Font {
        switch style {
        case .displayLarge: return GCTypography.displayLarge
        case .displayMedium: return GCTypography.displayMedium
        case .headline1: return GCTypography.headline1
        case .headline2: return GCTypography.headline2
        case .headline3: return GCTypography.headline3
        case .titleLarge: return GCTypography.titleLarge
        case .titleMedium: return GCTypography.titleMedium
        case .bodyLarge: return GCTypography.bodyLarge
        case .bodyMedium: return GCTypography.bodyMedium
        case .labelLarge: return GCTypography.labelLarge
        case .labelMedium: return GCTypography.labelMedium
        case .caption: return GCTypography.captionLarge
        case .numericLarge: return GCTypography.numericLarge
        case .numericMedium: return GCTypography.numericMedium
        case .button: return GCTypography.buttonLarge
        }
    }
}

extension View {

    func gcTextStyle(_ style: GCTextStyle.Style, color: Color = .gcTextPrimary) -> some View {
        modifier(GCTextStyle(style: style, color: color))
    }
}

// MARK: - Accessible Text Component

struct AccessibleText: View {

    let text: String
    let style: GCTextStyle.Style
    var color: Color = .gcTextPrimary
    var lineLimit: Int? = nil
    var alignment: TextAlignment = .leading

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Text(text)
            .gcTextStyle(style, color: color)
            .lineLimit(lineLimit)
            .multilineTextAlignment(alignment)
            .minimumScaleFactor(0.8)
            .accessibilityLabel(text)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("Display Large")
                    .font(GCTypography.displayLarge)

                Text("Headline 1")
                    .font(GCTypography.headline1)

                Text("Headline 2")
                    .font(GCTypography.headline2)

                Text("Title Large")
                    .font(GCTypography.titleLarge)

                Text("Body Large - Main reading text for elderly users")
                    .font(GCTypography.bodyLarge)

                Text("Label Medium")
                    .font(GCTypography.labelMedium)

                Text("Caption")
                    .font(GCTypography.captionLarge)
            }

            Divider()

            Group {
                Text("120/80")
                    .font(GCTypography.numericLarge)

                Text("72 BPM")
                    .font(GCTypography.numericMedium)

                Text("98%")
                    .font(GCTypography.numericSmall)
            }
        }
        .padding()
        .foregroundStyle(.white)
    }
    .background(Color(hex: "1C1C1E"))
}
