//
//  GlassCard.swift
//  GentleCare
//
//  Liquid Glass card component
//

import SwiftUI

// MARK: - Glass Card

struct GlassCard<Content: View>: View {

    // MARK: - Configuration

    enum Size {
        case small
        case medium
        case large

        var padding: CGFloat {
            switch self {
            case .small: return GentleCareTheme.Spacing.sm
            case .medium: return GentleCareTheme.Spacing.md
            case .large: return GentleCareTheme.Spacing.lg
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return GentleCareTheme.CornerRadius.md
            case .medium: return GentleCareTheme.CornerRadius.lg
            case .large: return GentleCareTheme.CornerRadius.xl
            }
        }
    }

    // MARK: - Properties

    let size: Size
    let isInteractive: Bool
    let glassStyle: GlassEffectModifier.Style
    @ViewBuilder let content: () -> Content

    @State private var isPressed = false

    // MARK: - Initialization

    init(
        size: Size = .medium,
        isInteractive: Bool = false,
        glassStyle: GlassEffectModifier.Style = .regular,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.size = size
        self.isInteractive = isInteractive
        self.glassStyle = glassStyle
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        content()
            .padding(size.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(style: glassStyle, cornerRadius: size.cornerRadius)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(GentleCareTheme.Animation.spring, value: isPressed)
            .if(isInteractive) { view in
                view
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { } onPressingChanged: { pressing in
                        isPressed = pressing
                    }
            }
    }
}

// MARK: - Conditional Modifier

extension View {

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Interactive Glass Card

struct InteractiveGlassCard<Content: View>: View {

    let action: () -> Void
    let haptic: GCHaptic
    @ViewBuilder let content: () -> Content

    @State private var isPressed = false

    init(
        haptic: GCHaptic = .light,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.haptic = haptic
        self.content = content
    }

    var body: some View {
        Button {
            haptic.trigger()
            action()
        } label: {
            content()
                .padding(GentleCareTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
        }
        .buttonStyle(GlassButtonStyle())
    }
}

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(GentleCareTheme.Animation.spring, value: configuration.isPressed)
    }
}

// MARK: - Stat Card

struct StatCard: View {

    let title: String
    let value: String
    let unit: String?
    let icon: String
    let iconColor: Color
    let trend: Trend?

    enum Trend {
        case up
        case down
        case stable

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: return Color(hex: "FF6B6B")
            case .down: return Color(hex: "5AC8FA")
            case .stable: return Color(hex: "34C759")
            }
        }
    }

    init(
        title: String,
        value: String,
        unit: String? = nil,
        icon: String,
        iconColor: Color = Color(hex: "4A90D9"),
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }

    var body: some View {
        GlassCard(size: .medium) {
            VStack(alignment: .leading, spacing: GentleCareTheme.Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(iconColor)

                    Spacer()

                    if let trend {
                        Image(systemName: trend.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(trend.color)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(value)
                            .font(GCTypography.numericMedium)
                            .foregroundStyle(.white)

                        if let unit {
                            Text(unit)
                                .font(GCTypography.labelMedium)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }

                    Text(title)
                        .font(GCTypography.labelMedium)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 120)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(hex: "1C1C1E")
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: 16) {
                GlassCard(size: .small) {
                    Text("Small Card")
                        .foregroundStyle(.white)
                }

                GlassCard(size: .medium) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medium Card")
                            .font(.headline)
                        Text("With more content and details")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.white)
                }

                GlassCard(size: .large, isInteractive: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Large Interactive Card")
                            .font(.headline)
                        Text("Press and hold to see the interaction effect")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.white)
                }

                HStack(spacing: 12) {
                    StatCard(
                        title: "Presion",
                        value: "120/80",
                        unit: "mmHg",
                        icon: "heart.fill",
                        iconColor: Color(hex: "FF6B6B"),
                        trend: .stable
                    )

                    StatCard(
                        title: "Pulso",
                        value: "72",
                        unit: "lpm",
                        icon: "waveform.path.ecg",
                        iconColor: Color(hex: "FF2D55")
                    )
                }

                InteractiveGlassCard(action: { print("Tapped!") }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "4A90D9"))

                        Text("Agregar medicamento")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding()
        }
    }
}
