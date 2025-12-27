//
//  GentleCareTheme.swift
//  GentleCare
//
//  Main theme configuration with Liquid Glass design
//

import SwiftUI

// MARK: - Theme Configuration

struct GentleCareTheme {

    // MARK: - Spacing

    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let full: CGFloat = 9999
    }

    // MARK: - Touch Targets (Elderly-friendly: minimum 60pt)

    struct TouchTarget {
        static let minimum: CGFloat = 60
        static let standard: CGFloat = 64
        static let large: CGFloat = 72
        static let extraLarge: CGFloat = 80
    }

    // MARK: - Shadows

    struct Shadow {
        static let sm = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let md = ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let lg = ShadowStyle(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        static let xl = ShadowStyle(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)

        // Glow effects
        static let primaryGlow = ShadowStyle(color: Color(hex: "4A90D9").opacity(0.4), radius: 16, x: 0, y: 0)
        static let successGlow = ShadowStyle(color: Color(hex: "34C759").opacity(0.4), radius: 16, x: 0, y: 0)
        static let errorGlow = ShadowStyle(color: Color(hex: "FF6B6B").opacity(0.4), radius: 16, x: 0, y: 0)
    }

    // MARK: - Animation

    struct Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.25
        static let slow: Double = 0.4
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let springSmooth = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.8)
    }

    // MARK: - Glass Effect Parameters

    struct Glass {
        static let blurRadius: CGFloat = 20
        static let tintOpacity: Double = 0.1
        static let borderOpacity: Double = 0.2
        static let highlightOpacity: Double = 0.3
    }

    // MARK: - Icon Sizes

    struct IconSize {
        static let xs: CGFloat = 16
        static let sm: CGFloat = 20
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 40
        static let xxl: CGFloat = 56
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Shadow Modifier

extension View {

    func gcShadow(_ style: ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Environment Values

private struct ThemeSpacingKey: EnvironmentKey {
    static let defaultValue = GentleCareTheme.Spacing.self
}

extension EnvironmentValues {
    var gcSpacing: GentleCareTheme.Spacing.Type {
        get { self[ThemeSpacingKey.self] }
        set { self[ThemeSpacingKey.self] = newValue }
    }
}

// MARK: - Haptic Feedback

enum GCHaptic {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection

    func trigger() {
        switch self {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Haptic Modifier

struct HapticFeedbackModifier: ViewModifier {
    let haptic: GCHaptic
    let trigger: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    haptic.trigger()
                }
            }
    }
}

extension View {

    func hapticFeedback(_ haptic: GCHaptic, trigger: Bool) -> some View {
        modifier(HapticFeedbackModifier(haptic: haptic, trigger: trigger))
    }

    func hapticOnTap(_ haptic: GCHaptic = .light) -> some View {
        simultaneousGesture(
            TapGesture().onEnded { _ in
                haptic.trigger()
            }
        )
    }
}

// MARK: - Transition Definitions

extension AnyTransition {

    static var gcSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    static var gcScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }

    static var gcFade: AnyTransition {
        .opacity.animation(GentleCareTheme.Animation.spring)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: GentleCareTheme.Spacing.lg) {
        Text("Theme Preview")
            .font(GCTypography.headline1)
            .foregroundStyle(.white)

        HStack(spacing: GentleCareTheme.Spacing.md) {
            Circle()
                .fill(Color(hex: "4A90D9"))
                .frame(width: 60, height: 60)

            Circle()
                .fill(Color(hex: "5BB381"))
                .frame(width: 60, height: 60)

            Circle()
                .fill(Color(hex: "E8846B"))
                .frame(width: 60, height: 60)
        }

        RoundedRectangle(cornerRadius: GentleCareTheme.CornerRadius.lg)
            .fill(Color(hex: "2C2C2E"))
            .frame(height: 100)
            .overlay(
                Text("Surface")
                    .foregroundStyle(.white)
            )
    }
    .padding(GentleCareTheme.Spacing.lg)
    .background(Color(hex: "1C1C1E"))
}
